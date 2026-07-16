###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/99_run_all.R
#
# Zweck:
# Vollständiger reproduzierbarer Abgabelauf aus einer leeren R-Sitzung.
###############################################################################

start_time <- Sys.time()

if (dir.exists(".r-lib")) {
  .libPaths(c(normalizePath(".r-lib"), .libPaths()))
}

required_packages <- c("here", "ggplot2", "glmnet")
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

source(here("syntax", "project_config.R"))
source(here("syntax", "06_monte_carlo.R"))
source(here("syntax", "08_tables_and_interpretation.R"))
source(here("syntax", "07_plots.R"))

config <- get_project_config()
set.seed(config$seed)

dir.create(here("output"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "cv_comparison", "raw"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "cv_comparison", "tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "cv_comparison", "figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "lasso"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "final_comparison"), recursive = TRUE, showWarnings = FALSE)

executed_scripts <- c(
  "syntax/project_config.R",
  "syntax/01_simulate_dgp.R",
  "syntax/02_create_lags.R",
  "syntax/04_models.R",
  "syntax/05_cv_methods.R",
  "syntax/06_monte_carlo.R",
  "syntax/08_tables_and_interpretation.R",
  "syntax/07_plots.R",
  "syntax/10_lasso_lag30.R",
  "syntax/11_final_model_comparison.R"
)

message("Starte Teil A: zentrale CV-Monte-Carlo-Studie")
message("Pilotlauf mit ", config$n_mc_pilot, " Wiederholungen pro DGP")
pilot_result <- run_cv_monte_carlo(R = config$n_mc_pilot, config = config, run_label = "pilot")
pilot_summary <- summarise_cv_results(config = config, run_label = "pilot")

if (!all(pilot_summary$checks$passed)) {
  print(pilot_summary$checks)
  stop("Pilotlauf hat mindestens einen Validierungscheck nicht bestanden.")
}

# Der Pilotlauf ist nur ein technischer Vorabcheck. Nach bestandenem Check
# werden seine Zwischenresultate entfernt, damit die Abgabe nur finale Outputs enthält.
unlink(here("output", "cv_comparison", "raw", c(
  "cv_simulation_results_pilot.csv",
  "cv_split_definitions_pilot.csv",
  "cv_validation_predictions_pilot.csv"
)))
unlink(here("output", "cv_comparison", "tables", "cv_run_info_pilot.csv"))

message("Finaler Lauf mit ", config$n_mc_final, " Wiederholungen pro DGP")
final_result <- run_cv_monte_carlo(R = config$n_mc_final, config = config, run_label = "final")
cv_outputs <- summarise_cv_results(config = config, run_label = "final")
plot_cv_results(config = config, run_label = "final")

if (!all(cv_outputs$checks$passed)) {
  print(cv_outputs$checks)
  stop("Finale CV-Studie hat mindestens einen Validierungscheck nicht bestanden.")
}

message("Prüfe Teil B: bestehende ARMA(1,1)-Fallstudie mit OLS, Ridge und Lasso")
case_required_files <- c(
  here("output", "lasso", "tables", "lasso_metrics.csv"),
  here("output", "final_comparison", "model_comparison_metrics.csv"),
  here("output", "final_comparison", "tables", "final_model_comparison_checks.csv")
)
if (!all(file.exists(case_required_files))) {
  stop("Bestehende ARMA-Fallstudienoutputs fehlen: ", paste(case_required_files[!file.exists(case_required_files)], collapse = ", "))
}
case_checks <- read.csv(here("output", "final_comparison", "tables", "final_model_comparison_checks.csv"))
if (!all(case_checks$passed)) {
  stop("Die ARMA-Fallstudie hat mindestens einen Validierungscheck nicht bestanden.")
}

end_time <- Sys.time()
summary_table <- read.csv(here("output", "cv_comparison", "tables", "cv_method_summary.csv"))
ranking <- read.csv(here("output", "cv_comparison", "tables", "cv_method_ranking.csv"))
cv_checks <- read.csv(here("output", "cv_comparison", "tables", "cv_validation_checks.csv"))
case_metrics <- read.csv(here("output", "final_comparison", "model_comparison_metrics.csv"))

run_log <- c(
  "Machine-Learning2026 run log",
  paste0("Start time: ", format(start_time, "%Y-%m-%d %H:%M:%S %Z")),
  paste0("End time: ", format(end_time, "%Y-%m-%d %H:%M:%S %Z")),
  paste0("Runtime seconds: ", round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)),
  paste0("Seed: ", config$seed),
  "Teil A: zentrale CV-Monte-Carlo-Studie",
  paste0("  DGPs: ", paste(config$dgp_names, collapse = ", ")),
  paste0("  CV methods: ", paste(config$cv_methods, collapse = ", ")),
  paste0("  primary model: ", config$primary_model_name),
  paste0("  final repetitions per DGP: ", config$n_mc_final),
  paste0("  train window: ", config$train_start, "-", config$train_end),
  paste0("  test window: ", config$test_start, "-", config$test_end),
  "Teil A ranking:",
  paste(capture.output(print(ranking, row.names = FALSE)), collapse = "\n"),
  "Teil A validation checks:",
  paste(capture.output(print(cv_checks, row.names = FALSE)), collapse = "\n"),
  "Teil B: bestehende ARMA(1,1)-Fallstudie mit OLS, Ridge und Lasso",
  paste(capture.output(print(case_metrics, row.names = FALSE)), collapse = "\n"),
  "Executed scripts:",
  paste0("  ", executed_scripts)
)

writeLines(run_log, here("output", "run_log.txt"))
writeLines(capture.output(sessionInfo()), here("output", "session_info.txt"))

message("Abgabelauf erfolgreich abgeschlossen.")
message("CV-Studie und ARMA-Fallstudie wurden getrennt erzeugt und validiert.")

