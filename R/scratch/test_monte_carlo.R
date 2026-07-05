###############################################################################
# Testskript für Monte-Carlo-Simulation
###############################################################################

library(here)

source(here("R", "06_monte_carlo.R"))


###############################################################################
# 1. Kleine Monte-Carlo-Simulation starten
###############################################################################

mc_results <- run_monte_carlo(
  R = 20,
  dgp_names = c("AR(1)", "MA(1)", "ARMA(1,1)")
)


###############################################################################
# 2. Erste Ergebnisse anschauen
###############################################################################

head(mc_results)

dim(mc_results)

mc_results


###############################################################################
# 3. Durchschnittliche Fehler und Bias berechnen
###############################################################################

mc_summary <- summarise_monte_carlo(
  results = mc_results
)

mc_summary


###############################################################################
# 4. Modellwahlhäufigkeiten berechnen
###############################################################################

model_selection_summary <- summarise_model_selection(
  results = mc_results
)

model_selection_summary













