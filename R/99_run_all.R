###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/99_run_all.R
#
# Zweck:
# Vollstaendiger reproduzierbarer Abgabelauf aus einer leeren R-Sitzung.
###############################################################################

start_time <- Sys.time()

required_packages <- c("here", "glmnet")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Folgende R-Pakete fehlen: ",
    paste(missing_packages, collapse = ", "),
    ". Bitte manuell installieren; der Abgabelauf installiert keine Pakete automatisch."
  )
}

suppressPackageStartupMessages({
  library(here)
})

source(here("R", "project_config.R"))

config <- get_project_config()
set.seed(config$seed)

dir.create(here("results"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("results", "lasso"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("results", "final_comparison"), recursive = TRUE, showWarnings = FALSE)

executed_scripts <- c(
  "R/project_config.R",
  "R/01_simulate_dgp.R",
  "R/02_create_lags.R",
  "R/03_train_test_split.R",
  "R/10_lasso_lag30.R",
  "R/11_final_model_comparison.R"
)

message("Starte vollstaendigen Abgabelauf...")
message("Seed: ", config$seed)

source(here("R", "10_lasso_lag30.R"))
lasso_result <- run_lasso_lag30(
  dgp_name = config$dgp_name,
  T = config$T,
  sigma = config$sigma,
  seed = config$seed,
  train_prop = derive_train_prop(config),
  n_splits = config$n_cv_splits,
  max_lag = config$max_lag
)

source(here("R", "11_final_model_comparison.R"))
comparison_result <- run_final_model_comparison(
  dgp_name = config$dgp_name,
  T = config$T,
  sigma = config$sigma,
  seed = config$seed,
  train_prop = derive_train_prop(config),
  n_splits = config$n_cv_splits,
  max_lag = config$max_lag
)

metrics <- read.csv(here("results", "final_comparison", "model_comparison_metrics.csv"))
predictions <- read.csv(here("results", "final_comparison", "model_test_predictions.csv"))
checks <- read.csv(here("results", "final_comparison", "tables", "final_model_comparison_checks.csv"))
split_table <- read.csv(here("results", "final_comparison", "tables", "final_comparison_time_cv_splits.csv"))

expected_tables <- c(
  here("results", "lasso", "tables", "lasso_predictions.csv"),
  here("results", "lasso", "tables", "lasso_metrics.csv"),
  here("results", "lasso", "tables", "lasso_selected_lags.csv"),
  here("results", "lasso", "tables", "lasso_all_coefficients.csv"),
  here("results", "lasso", "tables", "lasso_lambda_values.csv"),
  here("results", "lasso", "tables", "lasso_time_cv_splits.csv"),
  here("results", "final_comparison", "model_comparison_metrics.csv"),
  here("results", "final_comparison", "model_test_predictions.csv"),
  here("results", "final_comparison", "final_model_summary.txt"),
  here("results", "final_comparison", "tables", "final_model_comparison_checks.csv"),
  here("results", "final_comparison", "tables", "model_coefficients_lag1_to_lag30.csv")
)

expected_figures <- c(
  here("results", "lasso", "figures", "lasso_cv_plot.png"),
  here("results", "lasso", "figures", "lasso_coefficient_path.png"),
  here("results", "final_comparison", "figures", "01_test_rmse_mae_comparison.png"),
  here("results", "final_comparison", "figures", "02_cv_mse_vs_test_mse.png"),
  here("results", "final_comparison", "figures", "03_test_predictions_over_time.png"),
  here("results", "final_comparison", "figures", "04_coefficients_ols_ridge_lasso.png"),
  here("results", "final_comparison", "figures", "05_absolute_errors_over_time.png")
)

prediction_columns <- grep("^prediction_", names(predictions), value = TRUE)

if (!all(predictions$time == seq(config$test_start, config$test_end))) {
  stop("Validierungsfehler: Testzeitpunkte sind nicht exakt ", config$test_start, " bis ", config$test_end, ".")
}

if (!all(vapply(predictions[prediction_columns], function(x) length(x) == 66, logical(1)))) {
  stop("Validierungsfehler: Mindestens ein Modell hat nicht exakt 66 Testvorhersagen.")
}

if (!all(is.finite(as.matrix(metrics[, c("cv_mse", "test_mse", "test_rmse", "test_mae")])))) {
  stop("Validierungsfehler: Modellkennzahlen enthalten NA oder unendliche Werte.")
}

if (!all(split_table$train_end < split_table$validation_start)) {
  stop("Validierungsfehler: Rolling-Origin-Training liegt nicht vollstaendig vor der Validierung.")
}

if (!all(split_table$validation_start == split_table$train_end + 1) ||
    !all(split_table$train_end[-1] == head(split_table$validation_end, -1)) ||
    !all(split_table$validation_start[-1] == head(split_table$validation_end, -1) + 1)) {
  stop("Validierungsfehler: Validierungsbloecke sind nicht lueckenlos.")
}

if (max(split_table$validation_end) >= config$test_start) {
  stop("Validierungsfehler: Testdaten wurden fuer die Lambda-Auswahl verwendet.")
}

ridge_row <- metrics[metrics$model == "ridge_lag30", ]
lasso_row <- metrics[metrics$model == "lasso_lag30", ]

if (!is.finite(ridge_row$lambda_min) || !is.finite(ridge_row$lambda_1se) ||
    !is.finite(lasso_row$lambda_min) || !is.finite(lasso_row$lambda_1se)) {
  stop("Validierungsfehler: Ridge oder Lasso besitzen keine gueltigen Lambda-Werte.")
}

if (!all(file.exists(expected_tables)) || !all(file.exists(expected_figures))) {
  missing_outputs <- c(expected_tables, expected_figures)[!file.exists(c(expected_tables, expected_figures))]
  stop("Validierungsfehler: Erwartete Ergebnisdateien fehlen: ", paste(missing_outputs, collapse = ", "))
}

if (!all(checks$passed)) {
  stop("Validierungsfehler: Nicht alle finalen Modellvergleichschecks sind TRUE.")
}

best_rmse <- metrics$model[which.min(metrics$test_rmse)]
best_mae <- metrics$model[which.min(metrics$test_mae)]
end_time <- Sys.time()

run_log <- c(
  "Machine-Learning2026 run log",
  paste0("Start time: ", format(start_time, "%Y-%m-%d %H:%M:%S %Z")),
  paste0("End time: ", format(end_time, "%Y-%m-%d %H:%M:%S %Z")),
  paste0("Seed: ", config$seed),
  "Configuration:",
  paste0("  max_lag: ", config$max_lag),
  paste0("  train_start: ", config$train_start),
  paste0("  train_end: ", config$train_end),
  paste0("  test_start: ", config$test_start),
  paste0("  test_end: ", config$test_end),
  paste0("  n_cv_splits: ", config$n_cv_splits),
  paste0("  dgp_name: ", config$dgp_name),
  paste0("  T: ", config$T),
  paste0("  sigma: ", config$sigma),
  paste0("Training observations: ", config$train_end - config$train_start + 1),
  paste0("Test observations: ", config$test_end - config$test_start + 1),
  "Executed scripts:",
  paste0("  ", executed_scripts),
  "Final model metrics:",
  paste(capture.output(print(metrics, row.names = FALSE)), collapse = "\n"),
  paste0("Best model by RMSE: ", best_rmse),
  paste0("Best model by MAE: ", best_mae),
  "Validation checks:",
  paste(capture.output(print(checks, row.names = FALSE)), collapse = "\n")
)

writeLines(run_log, here("results", "run_log.txt"))
writeLines(capture.output(sessionInfo()), here("results", "session_info.txt"))

message("Abgabelauf erfolgreich abgeschlossen.")
message("Bestes Modell nach RMSE: ", best_rmse)
message("Bestes Modell nach MAE: ", best_mae)
