###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/06_monte_carlo.R
#
# Zweck:
# Zentrale Monte-Carlo-Studie zum Vergleich von vier CV-Methoden über fünf DGPs.
###############################################################################

suppressPackageStartupMessages({
  library(here)
})

source(here("syntax", "project_config.R"))
source(here("syntax", "01_simulate_dgp.R"))
source(here("syntax", "02_create_lags.R"))
source(here("syntax", "04_models.R"))
source(here("syntax", "05_cv_methods.R"))

prepare_primary_split <- function(y, config) {
  lag_data <- create_lags(y = y, max_lag = config$primary_max_lag)

  train_data <- lag_data[
    lag_data$time >= config$train_start & lag_data$time <= config$train_end,
  ]
  test_data <- lag_data[
    lag_data$time >= config$test_start & lag_data$time <= config$test_end,
  ]

  rownames(train_data) <- NULL
  rownames(test_data) <- NULL

  if (nrow(train_data) != config$train_end - config$train_start + 1) {
    stop("Unerwartete Zahl an Trainingsbeobachtungen.")
  }
  if (nrow(test_data) != config$test_end - config$test_start + 1) {
    stop("Unerwartete Zahl an Testbeobachtungen.")
  }

  list(train = train_data, test = test_data)
}

normalize_split_columns <- function(split_table) {
  wanted <- c(
    "simulation_id", "seed", "dgp", "cv_method", "split_id",
    "train_n", "validation_n", "train_time_min", "train_time_max",
    "validation_time_min", "validation_time_max", "validation_contiguous",
    "uses_future_training", "h", "removed_time_min", "removed_time_max"
  )

  for (col in wanted) {
    if (!(col %in% names(split_table))) {
      split_table[[col]] <- NA
    }
  }

  split_table[wanted]
}

run_one_cv_simulation <- function(simulation_id, dgp_name, config) {
  dgp_index <- match(dgp_name, config$dgp_names)
  seed <- config$seed + simulation_id * 1000 + dgp_index * 100
  set.seed(seed)

  y <- simulate_dgp(dgp_name, config)
  split <- prepare_primary_split(y, config)
  train_data <- split$train
  test_data <- split$test

  final_model <- fit_primary_model(train_data, config)
  test_predictions <- predict_model(final_model, test_data)
  test_mse <- mse(test_data$y, test_predictions)

  result_rows <- data.frame()
  split_rows <- data.frame()
  prediction_rows <- data.frame()

  for (method in config$cv_methods) {
    cv_seed <- seed + match(method, config$cv_methods)
    cv_result <- tryCatch(
      run_cv_method(method = method, data = train_data, config = config, seed = cv_seed),
      error = function(e) e
    )

    if (inherits(cv_result, "error")) {
      row <- data.frame(
        simulation_id = simulation_id,
        seed = seed,
        dgp = dgp_name,
        cv_method = method,
        cv_mse = NA_real_,
        test_mse = test_mse,
        estimation_error = NA_real_,
        squared_estimation_error = NA_real_,
        absolute_estimation_error = NA_real_,
        runtime_seconds = NA_real_,
        n_train = nrow(train_data),
        n_test = nrow(test_data),
        n_validation_predictions = NA_integer_,
        k = config$n_cv_splits,
        h = ifelse(method == "hblock", config$h_block, NA_integer_),
        success = FALSE,
        error_message = conditionMessage(cv_result)
      )
      result_rows <- rbind(result_rows, row)
      next
    }

    estimation_error <- cv_result$cv_mse - test_mse
    row <- data.frame(
      simulation_id = simulation_id,
      seed = seed,
      dgp = dgp_name,
      cv_method = method,
      cv_mse = cv_result$cv_mse,
      test_mse = test_mse,
      estimation_error = estimation_error,
      squared_estimation_error = estimation_error^2,
      absolute_estimation_error = abs(estimation_error),
      runtime_seconds = cv_result$runtime_seconds,
      n_train = nrow(train_data),
      n_test = nrow(test_data),
      n_validation_predictions = cv_result$n_validation_predictions,
      k = cv_result$k,
      h = cv_result$h,
      success = TRUE,
      error_message = ""
    )
    result_rows <- rbind(result_rows, row)

    splits <- cv_result$splits
    splits$simulation_id <- simulation_id
    splits$seed <- seed
    splits$dgp <- dgp_name
    splits <- normalize_split_columns(splits)
    split_rows <- rbind(split_rows, splits)

    preds <- cv_result$predictions
    preds$simulation_id <- simulation_id
    preds$seed <- seed
    preds$dgp <- dgp_name
    preds$cv_method <- method
    prediction_rows <- rbind(prediction_rows, preds)
  }

  list(results = result_rows, splits = split_rows, predictions = prediction_rows)
}

run_cv_monte_carlo <- function(R = NULL, config = get_project_config(), run_label = "final") {
  if (is.null(R)) {
    R <- config$n_mc_final
  }

  raw_dir <- here("output", "cv_comparison", "raw")
  table_dir <- here("output", "cv_comparison", "tables")
  dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

  all_results <- data.frame()
  all_splits <- data.frame()
  all_predictions <- data.frame()
  start_time <- Sys.time()

  for (dgp_name in config$dgp_names) {
    for (simulation_id in seq_len(R)) {
      message("CV-MC ", run_label, " | DGP: ", dgp_name, " | Simulation: ", simulation_id, "/", R)
      one <- run_one_cv_simulation(simulation_id, dgp_name, config)
      all_results <- rbind(all_results, one$results)
      all_splits <- rbind(all_splits, one$splits)
      all_predictions <- rbind(all_predictions, one$predictions)
    }
  }

  end_time <- Sys.time()
  runtime <- as.numeric(difftime(end_time, start_time, units = "secs"))

  if (run_label != "final") {
    write.csv(all_results, file.path(raw_dir, paste0("cv_simulation_results_", run_label, ".csv")), row.names = FALSE)
    write.csv(all_splits, file.path(raw_dir, paste0("cv_split_definitions_", run_label, ".csv")), row.names = FALSE)
    write.csv(all_predictions, file.path(raw_dir, paste0("cv_validation_predictions_", run_label, ".csv")), row.names = FALSE)
  }

  if (run_label == "final") {
    write.csv(all_results, file.path(raw_dir, "cv_simulation_results.csv"), row.names = FALSE)
    write.csv(all_splits, file.path(raw_dir, "cv_split_definitions.csv"), row.names = FALSE)
    write.csv(all_predictions, file.path(raw_dir, "cv_validation_predictions.csv"), row.names = FALSE)
  }

  run_info <- data.frame(
    run_label = run_label,
    repetitions_per_dgp = R,
    start_time = format(start_time, "%Y-%m-%d %H:%M:%S %Z"),
    end_time = format(end_time, "%Y-%m-%d %H:%M:%S %Z"),
    runtime_seconds = runtime,
    n_rows = nrow(all_results),
    n_split_rows = nrow(all_splits),
    n_prediction_rows = nrow(all_predictions)
  )
  write.csv(run_info, file.path(table_dir, paste0("cv_run_info_", run_label, ".csv")), row.names = FALSE)

  list(results = all_results, splits = all_splits, predictions = all_predictions, run_info = run_info)
}


