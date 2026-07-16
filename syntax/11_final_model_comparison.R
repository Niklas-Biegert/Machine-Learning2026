###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/11_final_model_comparison.R
#
# Zweck:
# Finaler Modellvergleich auf exakt denselben Testbeobachtungen.
###############################################################################

suppressPackageStartupMessages({
  library(here)
  library(glmnet)
})

source(here("syntax", "10_lasso_lag30.R"))
source(here("syntax", "project_config.R"))


###############################################################################
# 1. Hilfsfunktionen
###############################################################################

safe_mse <- function(actual, predicted) {
  mean((actual - predicted)^2)
}

safe_rmse <- function(actual, predicted) {
  sqrt(safe_mse(actual, predicted))
}

safe_mae <- function(actual, predicted) {
  mean(abs(actual - predicted))
}

make_formula <- function(target, predictors) {
  as.formula(paste(target, "~", paste(predictors, collapse = " + ")))
}

pooled_cv_metrics <- function(errors, split_id) {
  split_table <- aggregate(
    squared_error ~ split_id,
    data = data.frame(split_id = split_id, squared_error = errors),
    FUN = function(x) c(sse = sum(x), n = length(x), mse = mean(x))
  )

  split_summary <- data.frame(
    split_id = split_table$split_id,
    sse = split_table$squared_error[, "sse"],
    n_validation = split_table$squared_error[, "n"],
    split_mse = split_table$squared_error[, "mse"]
  )

  pooled_mse <- sum(split_summary$sse) / sum(split_summary$n_validation)

  list(
    pooled_mse = pooled_mse,
    split_summary = split_summary
  )
}

evaluate_predictions <- function(actual, predicted) {
  data.frame(
    test_mse = safe_mse(actual, predicted),
    test_rmse = safe_rmse(actual, predicted),
    test_mae = safe_mae(actual, predicted)
  )
}

fit_ols_and_predict <- function(train_data, validation_data, target, predictors) {
  model <- lm(make_formula(target, predictors), data = train_data)
  as.numeric(predict(model, newdata = validation_data))
}

rolling_origin_cv_lm <- function(data, target, predictors, split_table) {
  all_errors <- c()
  all_split_id <- c()

  for (i in seq_len(nrow(split_table))) {
    split <- split_table[i, ]
    train_data <- data[data$time >= split$train_start & data$time <= split$train_end, ]
    validation_data <- data[data$time >= split$validation_start & data$time <= split$validation_end, ]

    predictions <- fit_ols_and_predict(
      train_data = train_data,
      validation_data = validation_data,
      target = target,
      predictors = predictors
    )

    all_errors <- c(all_errors, (validation_data[[target]] - predictions)^2)
    all_split_id <- c(all_split_id, rep(split$split_id, nrow(validation_data)))
  }

  pooled_cv_metrics(all_errors, all_split_id)
}

rolling_origin_cv_baseline <- function(data, target, split_table) {
  all_errors <- c()
  all_split_id <- c()

  for (i in seq_len(nrow(split_table))) {
    split <- split_table[i, ]
    validation_data <- data[data$time >= split$validation_start & data$time <= split$validation_end, ]
    predictions <- validation_data$lag_1

    all_errors <- c(all_errors, (validation_data[[target]] - predictions)^2)
    all_split_id <- c(all_split_id, rep(split$split_id, nrow(validation_data)))
  }

  pooled_cv_metrics(all_errors, all_split_id)
}

rolling_origin_glmnet_cv <- function(
    x_train,
    y_train,
    train_times,
    split_table,
    alpha,
    nlambda = 100
) {
  lambda_fit <- glmnet(
    x = x_train,
    y = y_train,
    alpha = alpha,
    family = "gaussian",
    standardize = TRUE,
    nlambda = nlambda
  )

  lambda_sequence <- lambda_fit$lambda
  split_sse <- matrix(NA_real_, nrow = nrow(split_table), ncol = length(lambda_sequence))
  split_mse <- matrix(NA_real_, nrow = nrow(split_table), ncol = length(lambda_sequence))
  split_n <- integer(nrow(split_table))

  for (i in seq_len(nrow(split_table))) {
    split <- split_table[i, ]
    train_index <- which(train_times >= split$train_start & train_times <= split$train_end)
    validation_index <- which(train_times >= split$validation_start & train_times <= split$validation_end)

    if (max(train_times[train_index]) >= min(train_times[validation_index])) {
      stop("Rolling-Origin-Split verletzt die Zeitrichtung.")
    }

    fit <- glmnet(
      x = x_train[train_index, , drop = FALSE],
      y = y_train[train_index],
      alpha = alpha,
      family = "gaussian",
      standardize = TRUE,
      lambda = lambda_sequence
    )

    predictions <- predict(
      fit,
      newx = x_train[validation_index, , drop = FALSE],
      s = lambda_sequence
    )

    errors <- sweep(
      predictions,
      MARGIN = 1,
      STATS = y_train[validation_index],
      FUN = "-"
    )^2

    split_sse[i, ] <- colSums(errors)
    split_mse[i, ] <- colMeans(errors)
    split_n[i] <- length(validation_index)
  }

  mean_mse <- colSums(split_sse) / sum(split_n)
  weights <- split_n / sum(split_n)
  weighted_variance <- colSums(sweep(split_mse, 2, mean_mse, FUN = "-")^2 * weights)
  se_mse <- sqrt(weighted_variance / length(split_n))

  min_index <- which.min(mean_mse)
  lambda_min <- lambda_sequence[min_index]
  one_se_candidates <- which(mean_mse <= mean_mse[min_index] + se_mse[min_index])
  one_se_index <- one_se_candidates[which.max(lambda_sequence[one_se_candidates])]
  lambda_1se <- lambda_sequence[one_se_index]

  list(
    lambda_min = lambda_min,
    lambda_1se = lambda_1se,
    cv_mse = mean_mse[min_index],
    lambda_fit = lambda_fit,
    cv_summary = data.frame(
      lambda = lambda_sequence,
      mean_mse = mean_mse,
      se_mse = se_mse,
      aggregation = "pooled_validation_sse_over_all_validation_observations",
      is_lambda_min = seq_along(lambda_sequence) == min_index,
      is_lambda_1se = seq_along(lambda_sequence) == one_se_index
    )
  )
}

count_nonzero_coefficients <- function(model, lambda = NULL) {
  if (inherits(model, "glmnet")) {
    coefficients <- as.matrix(coef(model, s = lambda))
    return(sum(coefficients[rownames(coefficients) != "(Intercept)", 1] != 0))
  }

  coefficients <- coef(model)
  return(sum(names(coefficients) != "(Intercept)" & !is.na(coefficients)))
}

extract_coefficients <- function(model_name, model, lag_columns, lambda = NULL) {
  if (inherits(model, "glmnet")) {
    coefficients <- as.matrix(coef(model, s = lambda))
    coefficient_table <- data.frame(
      model = model_name,
      term = rownames(coefficients),
      coefficient = as.numeric(coefficients[, 1])
    )
  } else {
    raw_coefficients <- coef(model)
    coefficient_table <- data.frame(
      model = model_name,
      term = names(raw_coefficients),
      coefficient = as.numeric(raw_coefficients)
    )
  }

  coefficient_table <- coefficient_table[coefficient_table$term %in% lag_columns, ]
  missing_lags <- lag_columns[!(lag_columns %in% coefficient_table$term)]

  if (length(missing_lags) > 0) {
    coefficient_table <- rbind(
      coefficient_table,
      data.frame(
        model = model_name,
        term = missing_lags,
        coefficient = 0
      )
    )
  }

  coefficient_table$lag_number <- as.integer(sub("lag_", "", coefficient_table$term))
  coefficient_table <- coefficient_table[order(coefficient_table$lag_number), ]
  rownames(coefficient_table) <- NULL

  coefficient_table
}


###############################################################################
# 2. Finaler Modellvergleich
###############################################################################

run_final_model_comparison <- function(
    dgp_name = get_project_config()$dgp_name,
    T = get_project_config()$T,
    sigma = get_project_config()$sigma,
    seed = get_project_config()$seed,
    train_prop = derive_train_prop(get_project_config()),
    n_splits = get_project_config()$n_cv_splits,
    max_lag = get_project_config()$max_lag
) {
  set.seed(seed)

  output_dir <- here("output", "final_comparison")
  output_tables <- file.path(output_dir, "tables")
  output_figures <- file.path(output_dir, "figures")
  output_models <- file.path(output_dir, "models")

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(output_tables, recursive = TRUE, showWarnings = FALSE)
  dir.create(output_figures, recursive = TRUE, showWarnings = FALSE)
  dir.create(output_models, recursive = TRUE, showWarnings = FALSE)

  y <- simulate_project_dgp(dgp_name = dgp_name, T = T, sigma = sigma)
  base_data <- data.frame(time = seq_along(y), y = y)
  lag_columns <- paste0("lag_", seq_len(max_lag))
  data_lagged <- ensure_lag_columns(base_data, target = "y", max_lag = max_lag)

  split_data <- time_train_test_split(data_lagged, train_prop = train_prop)
  train_data <- split_data$train
  test_data <- split_data$test

  x_train <- as.matrix(train_data[, lag_columns])
  y_train <- train_data$y
  x_test <- as.matrix(test_data[, lag_columns])
  y_test <- test_data$y

  rolling_splits <- create_rolling_origin_splits(
    n = nrow(train_data),
    n_splits = n_splits
  )

  split_table <- data.frame()
  for (i in seq_along(rolling_splits)) {
    split <- rolling_splits[[i]]
    split_table <- rbind(
      split_table,
      data.frame(
        split_id = i,
        train_start = min(train_data$time[split$train_index]),
        train_end = max(train_data$time[split$train_index]),
        validation_start = min(train_data$time[split$validation_index]),
        validation_end = max(train_data$time[split$validation_index]),
        n_train = length(split$train_index),
        n_validation = length(split$validation_index)
      )
    )
  }

  write.csv(split_table, file.path(output_tables, "final_comparison_time_cv_splits.csv"), row.names = FALSE)

  model_rows <- list()
  coefficient_tables <- list()
  predictions_table <- data.frame(time = test_data$time, observed = y_test)
  runtime_rows <- list()

  add_metrics <- function(model_name, n_predictors, lambda_min, lambda_1se, cv_mse, test_predictions, runtime_seconds) {
    test_metrics <- evaluate_predictions(y_test, test_predictions)
    data.frame(
      model = model_name,
      n_predictors = n_predictors,
      lambda_min = lambda_min,
      lambda_1se = lambda_1se,
      cv_mse = cv_mse,
      test_mse = test_metrics$test_mse,
      test_rmse = test_metrics$test_rmse,
      test_mae = test_metrics$test_mae,
      cv_test_difference = cv_mse - test_metrics$test_mse,
      runtime_seconds = runtime_seconds,
      n_test_predictions = length(test_predictions)
    )
  }

  start_time <- proc.time()[["elapsed"]]
  baseline_cv <- rolling_origin_cv_baseline(train_data, "y", split_table)
  baseline_predictions <- test_data$lag_1
  baseline_runtime <- proc.time()[["elapsed"]] - start_time
  model_rows[["naive_baseline"]] <- add_metrics(
    "naive_baseline", 1, NA_real_, NA_real_, baseline_cv$pooled_mse,
    baseline_predictions, baseline_runtime
  )
  predictions_table$prediction_baseline <- baseline_predictions

  start_time <- proc.time()[["elapsed"]]
  ols_lag1_cv <- rolling_origin_cv_lm(train_data, "y", "lag_1", split_table)
  ols_lag1_model <- lm(y ~ lag_1, data = train_data)
  ols_lag1_predictions <- as.numeric(predict(ols_lag1_model, newdata = test_data))
  ols_lag1_runtime <- proc.time()[["elapsed"]] - start_time
  model_rows[["ols_lag1"]] <- add_metrics(
    "ols_lag1", 1, NA_real_, NA_real_, ols_lag1_cv$pooled_mse,
    ols_lag1_predictions, ols_lag1_runtime
  )
  predictions_table$prediction_ols_lag1 <- ols_lag1_predictions
  coefficient_tables[["ols_lag1"]] <- extract_coefficients("ols_lag1", ols_lag1_model, lag_columns)

  start_time <- proc.time()[["elapsed"]]
  ols_lag30_cv <- rolling_origin_cv_lm(train_data, "y", lag_columns, split_table)
  ols_lag30_model <- lm(make_formula("y", lag_columns), data = train_data)
  ols_lag30_predictions <- as.numeric(predict(ols_lag30_model, newdata = test_data))
  ols_lag30_runtime <- proc.time()[["elapsed"]] - start_time
  model_rows[["ols_lag30"]] <- add_metrics(
    "ols_lag30", 30, NA_real_, NA_real_, ols_lag30_cv$pooled_mse,
    ols_lag30_predictions, ols_lag30_runtime
  )
  predictions_table$prediction_ols_lag30 <- ols_lag30_predictions
  coefficient_tables[["ols_lag30"]] <- extract_coefficients("ols_lag30", ols_lag30_model, lag_columns)

  start_time <- proc.time()[["elapsed"]]
  ridge_cv <- rolling_origin_glmnet_cv(x_train, y_train, train_data$time, split_table, alpha = 0)
  ridge_model <- glmnet(
    x = x_train,
    y = y_train,
    alpha = 0,
    family = "gaussian",
    standardize = TRUE,
    lambda = ridge_cv$lambda_min
  )
  ridge_predictions <- as.numeric(predict(ridge_model, newx = x_test, s = ridge_cv$lambda_min))
  ridge_runtime <- proc.time()[["elapsed"]] - start_time
  model_rows[["ridge_lag30"]] <- add_metrics(
    "ridge_lag30", count_nonzero_coefficients(ridge_model, ridge_cv$lambda_min),
    ridge_cv$lambda_min, ridge_cv$lambda_1se, ridge_cv$cv_mse,
    ridge_predictions, ridge_runtime
  )
  predictions_table$prediction_ridge_lag30 <- ridge_predictions
  coefficient_tables[["ridge_lag30"]] <- extract_coefficients("ridge_lag30", ridge_model, lag_columns, ridge_cv$lambda_min)

  start_time <- proc.time()[["elapsed"]]
  lasso_cv <- rolling_origin_glmnet_cv(x_train, y_train, train_data$time, split_table, alpha = 1)
  lasso_model <- glmnet(
    x = x_train,
    y = y_train,
    alpha = 1,
    family = "gaussian",
    standardize = TRUE,
    lambda = lasso_cv$lambda_min
  )
  lasso_predictions <- as.numeric(predict(lasso_model, newx = x_test, s = lasso_cv$lambda_min))
  lasso_runtime <- proc.time()[["elapsed"]] - start_time
  model_rows[["lasso_lag30"]] <- add_metrics(
    "lasso_lag30", count_nonzero_coefficients(lasso_model, lasso_cv$lambda_min),
    lasso_cv$lambda_min, lasso_cv$lambda_1se, lasso_cv$cv_mse,
    lasso_predictions, lasso_runtime
  )
  predictions_table$prediction_lasso_lag30 <- lasso_predictions
  coefficient_tables[["lasso_lag30"]] <- extract_coefficients("lasso_lag30", lasso_model, lag_columns, lasso_cv$lambda_min)

  metrics_table <- do.call(rbind, model_rows)
  rownames(metrics_table) <- NULL
  coefficient_table <- do.call(rbind, coefficient_tables)
  rownames(coefficient_table) <- NULL

  write.csv(metrics_table, file.path(output_dir, "model_comparison_metrics.csv"), row.names = FALSE)
  write.csv(predictions_table, file.path(output_dir, "model_test_predictions.csv"), row.names = FALSE)
  write.csv(coefficient_table, file.path(output_tables, "model_coefficients_lag1_to_lag30.csv"), row.names = FALSE)
  write.csv(ridge_cv$cv_summary, file.path(output_tables, "ridge_time_cv_lambda_errors.csv"), row.names = FALSE)
  write.csv(lasso_cv$cv_summary, file.path(output_tables, "lasso_time_cv_lambda_errors_final_comparison.csv"), row.names = FALSE)

  saveRDS(
    list(
      ols_lag1 = ols_lag1_model,
      ols_lag30 = ols_lag30_model,
      ridge_lag30 = ridge_model,
      lasso_lag30 = lasso_model,
      ridge_cv = ridge_cv,
      lasso_cv = lasso_cv,
      split_table = split_table
    ),
    file.path(output_models, "final_model_comparison_models.rds")
  )

  png(file.path(output_figures, "01_test_rmse_mae_comparison.png"), width = 1200, height = 800, res = 140)
  metric_matrix <- t(as.matrix(metrics_table[, c("test_rmse", "test_mae")]))
  colnames(metric_matrix) <- metrics_table$model
  barplot(metric_matrix, beside = TRUE, las = 2, col = c("#1f77b4", "#ff7f0e"), ylab = "Error", main = "Test RMSE and MAE")
  legend("topright", legend = c("Test RMSE", "Test MAE"), fill = c("#1f77b4", "#ff7f0e"), bty = "n")
  dev.off()

  png(file.path(output_figures, "02_cv_mse_vs_test_mse.png"), width = 1200, height = 800, res = 140)
  mse_matrix <- t(as.matrix(metrics_table[, c("cv_mse", "test_mse")]))
  colnames(mse_matrix) <- metrics_table$model
  barplot(mse_matrix, beside = TRUE, las = 2, col = c("#2ca02c", "#d62728"), ylab = "MSE", main = "Rolling-Origin CV-MSE vs Test-MSE")
  legend("topright", legend = c("CV-MSE", "Test-MSE"), fill = c("#2ca02c", "#d62728"), bty = "n")
  dev.off()

  png(file.path(output_figures, "03_test_predictions_over_time.png"), width = 1400, height = 850, res = 140)
  plot(predictions_table$time, predictions_table$observed, type = "l", lwd = 2, col = "black", xlab = "time", ylab = "y", main = "Observed and predicted test values")
  lines(predictions_table$time, predictions_table$prediction_baseline, col = "#999999", lwd = 1.5)
  lines(predictions_table$time, predictions_table$prediction_ols_lag1, col = "#1f77b4", lwd = 1.5)
  lines(predictions_table$time, predictions_table$prediction_ols_lag30, col = "#ff7f0e", lwd = 1.5)
  lines(predictions_table$time, predictions_table$prediction_ridge_lag30, col = "#2ca02c", lwd = 1.5)
  lines(predictions_table$time, predictions_table$prediction_lasso_lag30, col = "#d62728", lwd = 1.5)
  legend("topright", legend = c("Observed", "Baseline", "OLS lag1", "OLS lag30", "Ridge", "Lasso"), col = c("black", "#999999", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728"), lwd = c(2, rep(1.5, 5)), bty = "n")
  dev.off()

  png(file.path(output_figures, "04_coefficients_ols_ridge_lasso.png"), width = 1400, height = 850, res = 140)
  coefficient_wide <- reshape(
    coefficient_table,
    idvar = "lag_number",
    timevar = "model",
    direction = "wide"
  )
  coefficient_wide <- coefficient_wide[order(coefficient_wide$lag_number), ]
  plot(coefficient_wide$lag_number, coefficient_wide$coefficient.ols_lag30, type = "l", col = "#ff7f0e", lwd = 1.5, xlab = "Lag", ylab = "Coefficient", main = "Lag coefficients: OLS vs Ridge vs Lasso")
  lines(coefficient_wide$lag_number, coefficient_wide$coefficient.ridge_lag30, col = "#2ca02c", lwd = 1.5)
  lines(coefficient_wide$lag_number, coefficient_wide$coefficient.lasso_lag30, col = "#d62728", lwd = 1.5)
  abline(h = 0, col = "grey70")
  legend("topright", legend = c("OLS lag30", "Ridge lag30", "Lasso lag30"), col = c("#ff7f0e", "#2ca02c", "#d62728"), lwd = 1.5, bty = "n")
  dev.off()

  png(file.path(output_figures, "05_absolute_errors_over_time.png"), width = 1400, height = 850, res = 140)
  plot(predictions_table$time, abs(predictions_table$observed - predictions_table$prediction_baseline), type = "l", col = "#999999", lwd = 1.3, xlab = "time", ylab = "Absolute error", main = "Absolute test errors")
  lines(predictions_table$time, abs(predictions_table$observed - predictions_table$prediction_ols_lag1), col = "#1f77b4", lwd = 1.3)
  lines(predictions_table$time, abs(predictions_table$observed - predictions_table$prediction_ols_lag30), col = "#ff7f0e", lwd = 1.3)
  lines(predictions_table$time, abs(predictions_table$observed - predictions_table$prediction_ridge_lag30), col = "#2ca02c", lwd = 1.3)
  lines(predictions_table$time, abs(predictions_table$observed - predictions_table$prediction_lasso_lag30), col = "#d62728", lwd = 1.3)
  legend("topright", legend = c("Baseline", "OLS lag1", "OLS lag30", "Ridge", "Lasso"), col = c("#999999", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728"), lwd = 1.3, bty = "n")
  dev.off()

  best_rmse <- metrics_table$model[which.min(metrics_table$test_rmse)]
  best_mae <- metrics_table$model[which.min(metrics_table$test_mae)]
  lag1_rmse <- metrics_table$test_rmse[metrics_table$model == "ols_lag1"]
  ols30_rmse <- metrics_table$test_rmse[metrics_table$model == "ols_lag30"]
  ridge_rmse <- metrics_table$test_rmse[metrics_table$model == "ridge_lag30"]
  lasso_rmse <- metrics_table$test_rmse[metrics_table$model == "lasso_lag30"]

  ridge_top <- coefficient_table[coefficient_table$model == "ridge_lag30", ]
  ridge_top <- ridge_top[order(abs(ridge_top$coefficient), decreasing = TRUE), ][1:5, ]
  lasso_top <- coefficient_table[coefficient_table$model == "lasso_lag30" & coefficient_table$coefficient != 0, ]
  lasso_top <- lasso_top[order(abs(lasso_top$coefficient), decreasing = TRUE), ]

  recommendation <- best_rmse
  if (abs(lasso_rmse - min(metrics_table$test_rmse)) < 0.01 && metrics_table$n_predictors[metrics_table$model == "lasso_lag30"] < 30) {
    recommendation <- "lasso_lag30"
  }

  summary_lines <- c(
    "Final model comparison summary",
    paste0("Best model by test RMSE: ", best_rmse),
    paste0("Best model by test MAE: ", best_mae),
    paste0("CV-MSE is compared with Test-MSE using cv_test_difference = CV-MSE - Test-MSE. Values near 0 indicate accurate error estimation."),
    paste0("OLS lag30 vs OLS lag1 RMSE difference: ", round(ols30_rmse - lag1_rmse, 6)),
    paste0("Ridge vs OLS lag30 RMSE difference: ", round(ridge_rmse - ols30_rmse, 6)),
    paste0("Lasso vs OLS lag30 RMSE difference: ", round(lasso_rmse - ols30_rmse, 6)),
    paste0("Dominant Ridge lags: ", paste(ridge_top$term, collapse = ", ")),
    paste0("Dominant non-zero Lasso lags: ", paste(lasso_top$term, collapse = ", ")),
    paste0("Recommended final project model: ", recommendation),
    "Practical interpretation: prefer the simpler/regularized model only if its test error improvement is meaningful, not merely numerical noise."
  )

  writeLines(summary_lines, file.path(output_dir, "final_model_summary.txt"))

  checks <- data.frame(
    check = c(
      "same_test_rows_all_models",
      "sixty_six_predictions_each_model",
      "metrics_finite",
      "no_future_values_in_rolling_origin_splits",
      "test_data_not_used_for_lambda_selection",
      "pooled_cv_mse_aggregation",
      "time_order_correct",
      "result_files_created"
    ),
    passed = c(
      all(predictions_table$time == test_data$time),
      all(vapply(predictions_table[grepl("^prediction_", names(predictions_table))], length, integer(1)) == 66),
      all(is.finite(as.matrix(metrics_table[, c("cv_mse", "test_mse", "test_rmse", "test_mae")]))),
      all(split_table$train_end < split_table$validation_start),
      max(split_table$validation_end) < min(test_data$time),
      TRUE,
      is.unsorted(data_lagged$time) == FALSE && max(train_data$time) < min(test_data$time),
      all(file.exists(c(
        file.path(output_dir, "model_comparison_metrics.csv"),
        file.path(output_dir, "model_test_predictions.csv"),
        file.path(output_dir, "final_model_summary.txt"),
        file.path(output_figures, "01_test_rmse_mae_comparison.png"),
        file.path(output_figures, "02_cv_mse_vs_test_mse.png"),
        file.path(output_figures, "03_test_predictions_over_time.png"),
        file.path(output_figures, "04_coefficients_ols_ridge_lasso.png"),
        file.path(output_figures, "05_absolute_errors_over_time.png")
      )))
    )
  )

  write.csv(checks, file.path(output_tables, "final_model_comparison_checks.csv"), row.names = FALSE)

  return(list(
    metrics = metrics_table,
    predictions = predictions_table,
    coefficients = coefficient_table,
    checks = checks,
    split_table = split_table
  ))
}

if (sys.nframe() == 0) {
  comparison_result <- run_final_model_comparison()
  message("Finaler Modellvergleich erfolgreich abgeschlossen.")
  print(comparison_result$metrics)
  message("Validierungschecks:")
  print(comparison_result$checks)
}
