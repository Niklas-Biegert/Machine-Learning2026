###############################################################################
# Finale Monte-Carlo-Simulation mit R = 500 und allen CV-Methoden
# Datei: R/scratch/run_monte_carlo_500.R
#
# Zweck:
# Führt die Monte-Carlo-Simulation mit 500 Wiederholungen aus
# und speichert die Ergebnisse im Ordner results/tables.
###############################################################################


###############################################################################
# 0. Pakete und Funktionen laden
###############################################################################

library(here)

source(here("R", "06_monte_carlo.R"))


###############################################################################
# 1. Ergebnisordner erstellen, falls er noch nicht existiert
###############################################################################

dir.create(
  here("results"),
  showWarnings = FALSE
)

dir.create(
  here("results", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)


###############################################################################
# 2. Monte-Carlo-Simulation mit 500 Wiederholungen starten
###############################################################################

runtime_500_all_cv <- system.time({
  
  mc_results_500_all_cv <- run_monte_carlo(
    R = 500,
    dgp_names = c("AR(1)", "MA(1)", "ARMA(1,1)")
  )
  
})


###############################################################################
# 3. Ergebnisse zusammenfassen
###############################################################################

mc_summary_500_all_cv <- summarise_monte_carlo(
  results = mc_results_500_all_cv
)

model_selection_500_all_cv <- summarise_model_selection(
  results = mc_results_500_all_cv
)


###############################################################################
# 4. Ergebnisse kurz prüfen
###############################################################################

head(mc_results_500_all_cv)

dim(mc_results_500_all_cv)

mc_summary_500_all_cv

model_selection_500_all_cv

runtime_500_all_cv


###############################################################################
# 5. Ergebnisse als RDS-Dateien speichern
###############################################################################

saveRDS(
  mc_results_500_all_cv,
  here("results", "tables", "mc_results_500_all_cv.rds")
)

saveRDS(
  mc_summary_500_all_cv,
  here("results", "tables", "mc_summary_500_all_cv.rds")
)

saveRDS(
  model_selection_500_all_cv,
  here("results", "tables", "model_selection_500_all_cv.rds")
)

saveRDS(
  runtime_500_all_cv,
  here("results", "tables", "runtime_500_all_cv.rds")
)


###############################################################################
# 6. Ergebnisse zusätzlich als CSV-Dateien speichern
###############################################################################

write.csv(
  mc_results_500_all_cv,
  here("results", "tables", "mc_results_500_all_cv.csv"),
  row.names = FALSE
)

write.csv(
  mc_summary_500_all_cv,
  here("results", "tables", "mc_summary_500_all_cv.csv"),
  row.names = FALSE
)

write.csv(
  model_selection_500_all_cv,
  here("results", "tables", "model_selection_500_all_cv.csv"),
  row.names = FALSE
)


###############################################################################
# 7. Kontrolle: Welche Dateien wurden gespeichert?
###############################################################################

list.files(
  here("results", "tables")
)

