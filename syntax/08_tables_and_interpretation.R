###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/08_tables_and_interpretation.R
#
# Zweck:
# Zentrale Tabellen, Rankings und Validierungschecks für die CV-Monte-Carlo-Studie.
###############################################################################

suppressPackageStartupMessages({
  library(here)
})

source(here("syntax", "project_config.R"))
source(here("syntax", "06_monte_carlo.R"))

add_check <- function(checks, check_name, passed, details = "") {
  rbind(checks, data.frame(
    check_name = check_name,
    passed = as.logical(passed),
    details = as.character(details)
  ))
}

summarise_cv_results <- function(config = get_project_config(), run_label = "final") {
  raw_dir <- here("output", "cv_comparison", "raw")
  table_dir <- here("output", "cv_comparison", "tables")
  dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

  results_path <- if (run_label == "final") {
    file.path(raw_dir, "cv_simulation_results.csv")
  } else {
    file.path(raw_dir, paste0("cv_simulation_results_", run_label, ".csv"))
  }
  splits_path <- if (run_label == "final") {
    file.path(raw_dir, "cv_split_definitions.csv")
  } else {
    file.path(raw_dir, paste0("cv_split_definitions_", run_label, ".csv"))
  }
  predictions_path <- if (run_label == "final") {
    file.path(raw_dir, "cv_validation_predictions.csv")
  } else {
    file.path(raw_dir, paste0("cv_validation_predictions_", run_label, ".csv"))
  }

  results <- read.csv(results_path, stringsAsFactors = FALSE)
  splits <- read.csv(splits_path, stringsAsFactors = FALSE)
  predictions <- read.csv(predictions_path, stringsAsFactors = FALSE)

  successful <- results[results$success == TRUE, ]

  group_key <- list(dgp = successful$dgp, cv_method = successful$cv_method)
  summary_table <- aggregate(
    cbind(cv_mse, test_mse, estimation_error, squared_estimation_error,
          absolute_estimation_error, runtime_seconds) ~ dgp + cv_method,
    data = successful,
    FUN = mean
  )
  names(summary_table) <- c(
    "dgp", "cv_method", "mean_cv_mse", "mean_test_mse", "bias",
    "mean_squared_estimation_error", "mae_estimation_error", "mean_runtime_seconds"
  )

  variance_table <- aggregate(estimation_error ~ dgp + cv_method, data = successful, FUN = var)
  names(variance_table)[3] <- "var_estimation_error"

  sd_cv_table <- aggregate(cv_mse ~ dgp + cv_method, data = successful, FUN = sd)
  names(sd_cv_table)[3] <- "sd_cv_mse"

  optimistic_table <- aggregate((cv_mse < test_mse) ~ dgp + cv_method, data = successful, FUN = mean)
  names(optimistic_table)[3] <- "optimistic_share"

  count_success <- aggregate(success ~ dgp + cv_method, data = results, FUN = sum)
  names(count_success)[3] <- "n_success"

  count_total <- aggregate(success ~ dgp + cv_method, data = results, FUN = length)
  names(count_total)[3] <- "n_total"
  count_table <- merge(count_total, count_success, by = c("dgp", "cv_method"), all = TRUE)
  count_table$n_failed <- count_table$n_total - count_table$n_success

  n_val_table <- aggregate(n_validation_predictions ~ dgp + cv_method, data = successful, FUN = mean)
  names(n_val_table)[3] <- "mean_validation_predictions"

  summary_table <- merge(summary_table, variance_table, by = c("dgp", "cv_method"))
  summary_table <- merge(summary_table, sd_cv_table, by = c("dgp", "cv_method"))
  summary_table <- merge(summary_table, optimistic_table, by = c("dgp", "cv_method"))
  summary_table <- merge(summary_table, count_table, by = c("dgp", "cv_method"))
  summary_table <- merge(summary_table, n_val_table, by = c("dgp", "cv_method"))
  summary_table$rmse_estimation_error <- sqrt(summary_table$mean_squared_estimation_error)
  summary_table$abs_bias <- abs(summary_table$bias)

  summary_table <- summary_table[order(summary_table$dgp, summary_table$cv_method), c(
    "dgp", "cv_method", "mean_cv_mse", "mean_test_mse", "bias", "abs_bias",
    "var_estimation_error", "rmse_estimation_error", "mae_estimation_error",
    "optimistic_share", "sd_cv_mse", "mean_runtime_seconds",
    "mean_validation_predictions", "n_success", "n_failed", "n_total"
  )]

  ranking <- data.frame()
  for (dgp_name in unique(summary_table$dgp)) {
    sub <- summary_table[summary_table$dgp == dgp_name, ]
    ranking <- rbind(ranking, data.frame(
      dgp = dgp_name,
      best_abs_bias = sub$cv_method[which.min(sub$abs_bias)],
      best_rmse_estimation_error = sub$cv_method[which.min(sub$rmse_estimation_error)],
      best_variance = sub$cv_method[which.min(sub$var_estimation_error)],
      fastest_method = sub$cv_method[which.min(sub$mean_runtime_seconds)]
    ))
  }

  checks <- data.frame()
  expected_repetitions <- length(unique(results$simulation_id))
  expected_combinations <- length(config$dgp_names) * length(config$cv_methods) * expected_repetitions
  checks <- add_check(checks, "all_expected_result_rows_present", nrow(results) == expected_combinations, paste("rows=", nrow(results), "expected_repetitions=", expected_repetitions))
  checks <- add_check(checks, "all_five_dgps_present", setequal(unique(results$dgp), config$dgp_names), paste(unique(results$dgp), collapse = ", "))
  checks <- add_check(checks, "all_four_cv_methods_present", setequal(unique(results$cv_method), config$cv_methods), paste(unique(results$cv_method), collapse = ", "))
  checks <- add_check(checks, "all_runs_successful", all(results$success), paste("failed=", sum(!results$success)))
  checks <- add_check(checks, "finite_error_values", all(is.finite(successful$cv_mse) & is.finite(successful$test_mse) & is.finite(successful$estimation_error)), "cv_mse, test_mse, estimation_error")
  checks <- add_check(checks, "same_train_and_test_size", all(successful$n_train == 154 & successful$n_test == 66), paste(unique(successful$n_train), unique(successful$n_test), collapse = "/"))
  checks <- add_check(checks, "no_test_data_in_cv", max(splits$validation_time_max, na.rm = TRUE) < config$test_start, paste("max_cv_time=", max(splits$validation_time_max, na.rm = TRUE)))

  rolling <- splits[splits$cv_method == "rolling_origin", ]
  checks <- add_check(checks, "rolling_origin_uses_no_future_training", all(!rolling$uses_future_training & rolling$train_time_max < rolling$validation_time_min), "train max < validation min")

  hblock <- splits[splits$cv_method == "hblock", ]
  expected_removed_min <- pmax(config$train_start, hblock$validation_time_min - config$h_block)
  expected_removed_max <- pmin(config$train_end, hblock$validation_time_max + config$h_block)
  checks <- add_check(checks, "hblock_removes_configured_buffer", all(hblock$h == config$h_block & hblock$removed_time_min == expected_removed_min & hblock$removed_time_max == expected_removed_max), paste("h=", config$h_block))

  blocked <- splits[splits$cv_method == "blocked", ]
  checks <- add_check(checks, "blocked_cv_validation_blocks_contiguous", all(blocked$validation_contiguous), "blocked validation blocks")

  kfold_a <- run_one_cv_simulation(1, config$dgp_names[1], config)$predictions
  kfold_b <- run_one_cv_simulation(1, config$dgp_names[1], config)$predictions
  kfold_a <- kfold_a[kfold_a$cv_method == "kfold", c("time", "split_id")]
  kfold_b <- kfold_b[kfold_b$cv_method == "kfold", c("time", "split_id")]
  checks <- add_check(checks, "kfold_assignment_reproducible", identical(kfold_a, kfold_b), "same seed gives same fold assignment")

  pooled <- aggregate(squared_error ~ simulation_id + dgp + cv_method, data = predictions, FUN = mean)
  names(pooled)[4] <- "pooled_cv_mse_from_predictions"
  compare <- merge(successful, pooled, by = c("simulation_id", "dgp", "cv_method"))
  checks <- add_check(checks, "pooled_mse_matches_saved_cv_mse", all(abs(compare$cv_mse - compare$pooled_cv_mse_from_predictions) < 1e-10), paste("checked rows=", nrow(compare)))

  lasso_files <- c(
    here("output", "lasso", "tables", "lasso_metrics.csv"),
    here("output", "final_comparison", "model_comparison_metrics.csv"),
    here("output", "final_comparison", "tables", "final_model_comparison_checks.csv")
  )
  checks <- add_check(checks, "lasso_case_study_files_present", all(file.exists(lasso_files)), paste(lasso_files[!file.exists(lasso_files)], collapse = "; "))

  write.csv(summary_table, here("output", "cv_comparison", "tables", "cv_method_summary.csv"), row.names = FALSE)
  write.csv(ranking, here("output", "cv_comparison", "tables", "cv_method_ranking.csv"), row.names = FALSE)
  write.csv(checks, here("output", "cv_comparison", "tables", "cv_validation_checks.csv"), row.names = FALSE)

  list(summary = summary_table, ranking = ranking, checks = checks)
}


