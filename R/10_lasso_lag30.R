###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/10_lasso_lag30.R
#
# Zweck:
# Vollstaendiges Lasso-Modell mit 30 Lag-Variablen.
#
# Methodische Leitplanken:
# - keine zufaellige Vermischung der Zeitreihe
# - Lambda-Auswahl nur innerhalb der Trainingsdaten
# - Rolling-Origin-CV fuer Lambda-Auswahl
# - echter Testzeitraum bleibt bis zur finalen Evaluation unberuehrt
###############################################################################


###############################################################################
# 0. Pakete und vorhandene Projektfunktionen laden
###############################################################################

suppressPackageStartupMessages({
  library(here)
  library(glmnet)
})

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))
source(here("R", "03_train_test_split.R"))
source(here("R", "project_config.R"))


###############################################################################
# 1. Hilfsfunktionen
###############################################################################

mse <- function(actual, predicted) {
  mean((actual - predicted)^2)
}

mae <- function(actual, predicted) {
  mean(abs(actual - predicted))
}

rmse_lasso <- function(actual, predicted) {
  sqrt(mse(actual, predicted))
}

create_rolling_origin_splits <- function(n, initial_train_size = NULL, validation_size = NULL, n_splits = 5) {
  if (n_splits < 1) {
    stop("n_splits muss mindestens 1 sein.")
  }

  if (is.null(initial_train_size)) {
    initial_train_size <- floor(0.5 * n)
  }

  if (is.null(validation_size)) {
    validation_size <- ceiling((n - initial_train_size) / n_splits)
  }

  if (initial_train_size < 30) {
    stop("initial_train_size ist zu klein fuer ein stabiles Lasso-Modell.")
  }

  if (initial_train_size + validation_size > n) {
    stop("initial_train_size + validation_size darf n nicht ueberschreiten.")
  }

  splits <- list()
  train_end <- initial_train_size

  for (i in seq_len(n_splits)) {
    validation_start <- train_end + 1

    if (validation_start > n) {
      break
    }

    validation_end <- min(train_end + validation_size, n)

    splits[[length(splits) + 1]] <- list(
      split_id = i,
      train_index = seq_len(train_end),
      validation_index = validation_start:validation_end
    )

    train_end <- validation_end
  }

  if (length(splits) == 0) {
    stop("Keine Rolling-Origin-Splits erzeugt.")
  }

  return(splits)
}

rolling_origin_lasso_cv <- function(
    x_train,
    y_train,
    train_times,
    n_splits = 5,
    initial_train_size = NULL,
    validation_size = NULL,
    nlambda = 100
) {
  lambda_fit <- glmnet(
    x = x_train,
    y = y_train,
    alpha = 1,
    family = "gaussian",
    standardize = TRUE,
    nlambda = nlambda
  )

  lambda_sequence <- lambda_fit$lambda

  splits <- create_rolling_origin_splits(
    n = nrow(x_train),
    initial_train_size = initial_train_size,
    validation_size = validation_size,
    n_splits = n_splits
  )

  split_mse <- matrix(
    NA_real_,
    nrow = length(splits),
    ncol = length(lambda_sequence)
  )
  split_sse <- matrix(
    NA_real_,
    nrow = length(splits),
    ncol = length(lambda_sequence)
  )
  split_n <- integer(length(splits))

  split_table <- data.frame()

  for (split_id in seq_along(splits)) {
    split <- splits[[split_id]]

    train_index <- split$train_index
    validation_index <- split$validation_index

    if (max(train_index) >= min(validation_index)) {
      stop("Rolling-Origin-Split verletzt die Zeitrichtung.")
    }

    split_fit <- glmnet(
      x = x_train[train_index, , drop = FALSE],
      y = y_train[train_index],
      alpha = 1,
      family = "gaussian",
      standardize = TRUE,
      lambda = lambda_sequence
    )

    validation_predictions <- predict(
      split_fit,
      newx = x_train[validation_index, , drop = FALSE],
      s = lambda_sequence
    )

    validation_errors <- sweep(
      validation_predictions,
      MARGIN = 1,
      STATS = y_train[validation_index],
      FUN = "-"
    )^2

    split_mse[split_id, ] <- colMeans(validation_errors)
    split_sse[split_id, ] <- colSums(validation_errors)
    split_n[split_id] <- length(validation_index)

    split_table <- rbind(
      split_table,
      data.frame(
        split_id = split_id,
        train_start = min(train_times[train_index]),
        train_end = max(train_times[train_index]),
        validation_start = min(train_times[validation_index]),
        validation_end = max(train_times[validation_index]),
        n_train = length(train_index),
        n_validation = length(validation_index)
      )
    )
  }

  mean_mse <- colSums(split_sse) / sum(split_n)
  split_weights <- split_n / sum(split_n)
  weighted_variance <- colSums(
    sweep(split_mse, 2, mean_mse, FUN = "-")^2 * split_weights
  )
  se_mse <- sqrt(weighted_variance / length(split_n))

  min_index <- which.min(mean_mse)
  lambda_min <- lambda_sequence[min_index]
  mse_min <- mean_mse[min_index]
  se_min <- se_mse[min_index]

  one_se_candidates <- which(mean_mse <= mse_min + se_min)
  one_se_index <- one_se_candidates[which.max(lambda_sequence[one_se_candidates])]
  lambda_1se <- lambda_sequence[one_se_index]

  cv_summary <- data.frame(
    lambda = lambda_sequence,
    mean_mse = mean_mse,
    se_mse = se_mse,
    aggregation = "pooled_validation_sse_over_all_validation_observations",
    is_lambda_min = seq_along(lambda_sequence) == min_index,
    is_lambda_1se = seq_along(lambda_sequence) == one_se_index
  )

  return(list(
    lambda_sequence = lambda_sequence,
    lambda_min = lambda_min,
    lambda_1se = lambda_1se,
    min_index = min_index,
    one_se_index = one_se_index,
    cv_summary = cv_summary,
    split_mse = split_mse,
    split_sse = split_sse,
    split_n = split_n,
    split_table = split_table,
    lambda_fit = lambda_fit
  ))
}

ensure_lag_columns <- function(data, target = "y", max_lag = 30, time_column = "time") {
  if (!is.data.frame(data)) {
    stop("data muss ein Dataframe sein.")
  }

  if (!(target %in% names(data))) {
    stop("Zielvariable fehlt: ", target)
  }

  if (time_column %in% names(data)) {
    data <- data[order(data[[time_column]]), ]
  }

  if (!is.numeric(data[[target]])) {
    stop("Die Zielvariable muss numerisch sein.")
  }

  if (nrow(data) <= max_lag) {
    stop("Der Datensatz muss mehr Zeilen enthalten als max_lag.")
  }

  lag_columns <- paste0("lag_", seq_len(max_lag))

  for (lag in seq_len(max_lag)) {
    lag_name <- paste0("lag_", lag)

    if (!(lag_name %in% names(data))) {
      data[[lag_name]] <- c(
        rep(NA_real_, lag),
        data[[target]][seq_len(nrow(data) - lag)]
      )
    }
  }

  complete_columns <- c(target, lag_columns)
  data <- data[complete.cases(data[, complete_columns]), ]
  rownames(data) <- NULL

  for (column in lag_columns) {
    data[[column]] <- as.numeric(data[[column]])
  }

  return(data)
}

simulate_project_dgp <- function(dgp_name = "ARMA(1,1)", T = 250, sigma = 1) {
  if (dgp_name == "AR(1)") {
    return(simulate_ar1(T = T, phi = 0.7, sigma = sigma))
  }

  if (dgp_name == "MA(1)") {
    return(simulate_ma1(T = T, theta = 0.6, sigma = sigma))
  }

  if (dgp_name == "ARMA(1,1)") {
    return(simulate_arma11(T = T, phi = 0.6, theta = 0.5, sigma = sigma))
  }

  stop("Unbekannter DGP: ", dgp_name)
}


###############################################################################
# 2. Wiederverwendbare Lasso-Funktion
###############################################################################

fit_lasso_model <- function(
    data,
    target = "y",
    lag_columns = paste0("lag_", 1:30),
    train_prop = 0.7,
    n_splits = 5,
    initial_train_size = NULL,
    validation_size = NULL,
    output_dir = here("results", "lasso"),
    create_plots = TRUE
) {
  max_lag <- length(lag_columns)

  data_lagged <- ensure_lag_columns(
    data = data,
    target = target,
    max_lag = max_lag
  )

  missing_lags <- lag_columns[!(lag_columns %in% names(data_lagged))]

  if (length(missing_lags) > 0) {
    stop("Folgende Lag-Spalten fehlen: ", paste(missing_lags, collapse = ", "))
  }

  non_numeric_lags <- lag_columns[!vapply(data_lagged[lag_columns], is.numeric, logical(1))]

  if (length(non_numeric_lags) > 0) {
    stop("Folgende Lag-Spalten sind nicht numerisch: ", paste(non_numeric_lags, collapse = ", "))
  }

  split_data <- time_train_test_split(
    data = data_lagged,
    train_prop = train_prop
  )

  train_data <- split_data$train
  test_data <- split_data$test

  train_time_max <- max(train_data$time)
  test_time_min <- min(test_data$time)

  if (!is.na(train_time_max) && !is.na(test_time_min) && train_time_max >= test_time_min) {
    stop("Train/Test-Split ist zeitlich nicht korrekt getrennt.")
  }

  x_train <- as.matrix(train_data[, lag_columns])
  y_train <- train_data[[target]]
  x_test <- as.matrix(test_data[, lag_columns])
  y_test <- test_data[[target]]

  previous_cv_audit <- data.frame(
    previous_method = "cv.glmnet with contiguous blocked foldid",
    previous_training_rule = "For each validation fold, cv.glmnet trains on all other folds.",
    future_training_values_possible = TRUE,
    reason = paste(
      "Contiguous fold IDs preserve validation blocks, but cv.glmnet does not enforce",
      "that training observations are earlier than the validation block."
    ),
    replacement_method = "custom rolling-origin lambda validation",
    replacement_split_rule = paste(
      "Each validation block starts immediately after the current training window;",
      "the next training end equals the previous validation end."
    ),
    test_period_used_for_lambda_selection = FALSE
  )

  time_cv <- rolling_origin_lasso_cv(
    x_train = x_train,
    y_train = y_train,
    train_times = train_data$time,
    n_splits = n_splits,
    initial_train_size = initial_train_size,
    validation_size = validation_size
  )

  final_model <- glmnet(
    x = x_train,
    y = y_train,
    alpha = 1,
    family = "gaussian",
    standardize = TRUE,
    lambda = time_cv$lambda_min
  )

  predictions <- as.numeric(
    predict(
      final_model,
      newx = x_test,
      s = time_cv$lambda_min
    )
  )

  metrics <- data.frame(
    metric = c("MSE", "RMSE", "MAE"),
    value = c(
      mse(y_test, predictions),
      rmse_lasso(y_test, predictions),
      mae(y_test, predictions)
    )
  )

  if (any(!is.finite(metrics$value))) {
    stop("Mindestens eine Testkennzahl ist nicht endlich.")
  }

  coefficients_matrix <- as.matrix(coef(final_model, s = time_cv$lambda_min))

  all_coefficients <- data.frame(
    term = rownames(coefficients_matrix),
    coefficient = as.numeric(coefficients_matrix[, 1])
  )

  selected_lags <- all_coefficients[
    all_coefficients$term != "(Intercept)" &
      all_coefficients$coefficient != 0,
  ]

  rownames(selected_lags) <- NULL

  predictions_table <- data.frame(
    time = test_data$time,
    actual = y_test,
    predicted = predictions,
    error = y_test - predictions
  )

  lambda_values <- data.frame(
    cv_method = "rolling_origin_forward_validation",
    previous_cv_method = "cv.glmnet_blocked_foldid",
    previous_future_training_values_possible = TRUE,
    lambda_min = time_cv$lambda_min,
    lambda_1se = time_cv$lambda_1se,
    n_selected_lags = nrow(selected_lags),
    train_n = nrow(train_data),
    test_n = nrow(test_data),
    n_splits = n_splits,
    train_time_min = min(train_data$time),
    train_time_max = max(train_data$time),
    test_time_min = min(test_data$time),
    test_time_max = max(test_data$time)
  )

  output_tables <- file.path(output_dir, "tables")
  output_figures <- file.path(output_dir, "figures")
  output_models <- file.path(output_dir, "models")

  dir.create(output_tables, recursive = TRUE, showWarnings = FALSE)
  dir.create(output_figures, recursive = TRUE, showWarnings = FALSE)
  dir.create(output_models, recursive = TRUE, showWarnings = FALSE)

  saveRDS(
    object = list(
      final_model = final_model,
      time_cv = time_cv,
      lambda_min = time_cv$lambda_min,
      lambda_1se = time_cv$lambda_1se,
      target = target,
      lag_columns = lag_columns,
      train_prop = train_prop,
      n_splits = n_splits,
      initial_train_size = initial_train_size,
      validation_size = validation_size
    ),
    file = file.path(output_models, "lasso_model.rds")
  )

  write.csv(predictions_table, file.path(output_tables, "lasso_predictions.csv"), row.names = FALSE)
  write.csv(metrics, file.path(output_tables, "lasso_metrics.csv"), row.names = FALSE)
  write.csv(selected_lags, file.path(output_tables, "lasso_selected_lags.csv"), row.names = FALSE)
  write.csv(all_coefficients, file.path(output_tables, "lasso_all_coefficients.csv"), row.names = FALSE)
  write.csv(lambda_values, file.path(output_tables, "lasso_lambda_values.csv"), row.names = FALSE)
  write.csv(time_cv$split_table, file.path(output_tables, "lasso_time_cv_splits.csv"), row.names = FALSE)
  write.csv(time_cv$cv_summary, file.path(output_tables, "lasso_time_cv_lambda_errors.csv"), row.names = FALSE)
  write.csv(previous_cv_audit, file.path(output_tables, "lasso_cv_method_audit.csv"), row.names = FALSE)

  if (create_plots) {
    png(file.path(output_figures, "lasso_cv_plot.png"), width = 1200, height = 800, res = 140)
    plot(
      log(time_cv$cv_summary$lambda),
      time_cv$cv_summary$mean_mse,
      type = "b",
      pch = 19,
      col = "red",
      xlab = "log(lambda)",
      ylab = "Mean validation MSE",
      main = "Lasso: rolling-origin CV over lambda"
    )
    arrows(
      x0 = log(time_cv$cv_summary$lambda),
      y0 = time_cv$cv_summary$mean_mse - time_cv$cv_summary$se_mse,
      x1 = log(time_cv$cv_summary$lambda),
      y1 = time_cv$cv_summary$mean_mse + time_cv$cv_summary$se_mse,
      angle = 90,
      code = 3,
      length = 0.02,
      col = "grey70"
    )
    abline(v = log(time_cv$lambda_min), col = "red", lty = 2)
    abline(v = log(time_cv$lambda_1se), col = "blue", lty = 2)
    legend(
      "topright",
      legend = c("lambda.min", "lambda.1se"),
      col = c("red", "blue"),
      lty = 2,
      bty = "n"
    )
    dev.off()

    png(file.path(output_figures, "lasso_coefficient_path.png"), width = 1200, height = 800, res = 140)
    plot(time_cv$lambda_fit, xvar = "lambda", label = TRUE)
    abline(v = log(time_cv$lambda_min), col = "red", lty = 2)
    abline(v = log(time_cv$lambda_1se), col = "blue", lty = 2)
    legend(
      "topright",
      legend = c("lambda.min", "lambda.1se"),
      col = c("red", "blue"),
      lty = 2,
      bty = "n"
    )
    title("Lasso coefficient path")
    dev.off()
  }

  checks <- data.frame(
    check = c(
      "all_30_lags_numeric",
      "time_split_train_before_test",
      "lambda_cv_uses_training_only",
      "rolling_origin_has_no_future_training",
      "rolling_origin_validation_blocks_contiguous",
      "test_period_not_used_for_lambda_selection",
      "predictions_for_all_test_rows",
      "metrics_finite",
      "files_created"
    ),
    passed = c(
      all(vapply(data_lagged[lag_columns], is.numeric, logical(1))),
      max(train_data$time) < min(test_data$time),
      max(time_cv$split_table$validation_end) <= max(train_data$time),
      all(time_cv$split_table$train_end < time_cv$split_table$validation_start),
      all(time_cv$split_table$validation_start == time_cv$split_table$train_end + 1) &&
        (
          nrow(time_cv$split_table) == 1 ||
            all(time_cv$split_table$train_end[-1] == head(time_cv$split_table$validation_end, -1))
        ) &&
        (
          nrow(time_cv$split_table) == 1 ||
            all(time_cv$split_table$validation_start[-1] == head(time_cv$split_table$validation_end, -1) + 1)
        ) &&
        max(time_cv$split_table$validation_end) == max(train_data$time),
      min(test_data$time) > max(time_cv$split_table$validation_end),
      nrow(predictions_table) == nrow(test_data) && all(is.finite(predictions_table$predicted)),
      all(is.finite(metrics$value)) && !any(is.na(metrics$value)),
      all(file.exists(c(
        file.path(output_models, "lasso_model.rds"),
        file.path(output_tables, "lasso_predictions.csv"),
        file.path(output_tables, "lasso_metrics.csv"),
        file.path(output_tables, "lasso_selected_lags.csv"),
        file.path(output_tables, "lasso_all_coefficients.csv"),
        file.path(output_tables, "lasso_time_cv_splits.csv"),
        file.path(output_tables, "lasso_cv_method_audit.csv"),
        file.path(output_figures, "lasso_cv_plot.png"),
        file.path(output_figures, "lasso_coefficient_path.png")
      )))
    )
  )

  write.csv(checks, file.path(output_tables, "lasso_validation_checks.csv"), row.names = FALSE)

  return(list(
    model = final_model,
    time_cv = time_cv,
    predictions = predictions_table,
    metrics = metrics,
    all_coefficients = all_coefficients,
    selected_lags = selected_lags,
    lambda_values = lambda_values,
    previous_cv_audit = previous_cv_audit,
    checks = checks,
    train_data = train_data,
    test_data = test_data
  ))
}


###############################################################################
# 3. Standardlauf fuer das Projekt
###############################################################################

run_lasso_lag30 <- function(
    dgp_name = get_project_config()$dgp_name,
    T = get_project_config()$T,
    sigma = get_project_config()$sigma,
    seed = get_project_config()$seed,
    train_prop = derive_train_prop(get_project_config()),
    n_splits = get_project_config()$n_cv_splits,
    max_lag = get_project_config()$max_lag
) {
  set.seed(seed)

  y <- simulate_project_dgp(
    dgp_name = dgp_name,
    T = T,
    sigma = sigma
  )

  base_data <- data.frame(
    time = seq_along(y),
    y = y
  )

  result <- fit_lasso_model(
    data = base_data,
    target = "y",
    lag_columns = paste0("lag_", seq_len(max_lag)),
    train_prop = train_prop,
    n_splits = n_splits,
    output_dir = here("results", "lasso"),
    create_plots = TRUE
  )

  write.csv(
    data.frame(
      dgp_name = dgp_name,
      T = T,
      sigma = sigma,
      seed = seed,
      max_lag = max_lag,
      train_start = get_project_config()$train_start,
      train_end = get_project_config()$train_end,
      test_start = get_project_config()$test_start,
      test_end = get_project_config()$test_end,
      train_prop = train_prop,
      n_splits = n_splits
    ),
    here("results", "lasso", "tables", "lasso_run_config.csv"),
    row.names = FALSE
  )

  return(result)
}


###############################################################################
# 4. Ausfuehren, wenn dieses Skript direkt mit Rscript gestartet wird
###############################################################################

if (sys.nframe() == 0) {
  lasso_result <- run_lasso_lag30()

  message("Lasso-Modell erfolgreich geschaetzt.")
  message("lambda.min: ", signif(lasso_result$lambda_values$lambda_min, 6))
  message("lambda.1se: ", signif(lasso_result$lambda_values$lambda_1se, 6))
  message("Anzahl ausgewaehlter Lags: ", lasso_result$lambda_values$n_selected_lags)
  message("Testkennzahlen:")
  print(lasso_result$metrics)
  message("Ausgewaehlte Lags:")
  print(lasso_result$selected_lags)
  message("Validierungschecks:")
  print(lasso_result$checks)
}
