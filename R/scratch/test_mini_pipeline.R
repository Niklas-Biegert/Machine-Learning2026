###############################################################################
# Mini-Pipeline-Test
# Datei: R/scratch/test_mini_pipeline.R
#
# Zweck:
# Ein kompletter Durchlauf des Projekts mit:
# - einem DGP
# - zwei Modellen
# - zwei CV-Methoden
# - einem echten Testfehler
# - Bias-Berechnung
###############################################################################


###############################################################################
# 0. Pakete und Funktionen laden
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))
source(here("R", "03_train_test_split.R"))
source(here("R", "04_models.R"))
source(here("R", "05_cv_methods.R"))


###############################################################################
# 1. Einstellungen
###############################################################################

set.seed(123)

T <- 250
sigma <- 1
max_lag <- 5
train_prop <- 0.7

model_names <- c(
  "LM-lag1",
  "LM-lag5"
)


###############################################################################
# 2. Zeitreihe simulieren
###############################################################################

y <- simulate_arma11(
  T = T,
  phi = 0.6,
  theta = 0.5,
  sigma = sigma
)


###############################################################################
# 3. Lag-Features bauen
###############################################################################

lag_data <- create_lags(
  y = y,
  max_lag = max_lag
)


###############################################################################
# 4. Train/Test-Split
###############################################################################

split_data <- time_train_test_split(
  data = lag_data,
  train_prop = train_prop
)

train_data <- split_data$train
test_data <- split_data$test


###############################################################################
# 5. Cross-Validation: k-fold
###############################################################################

results_kfold <- compare_models_cv(
  data = train_data,
  model_names = model_names,
  cv_method = "kfold"
)

selected_kfold <- results_kfold$model[results_kfold$selected_model]
cv_error_kfold <- results_kfold$cv_error[results_kfold$selected_model]


###############################################################################
# 6. Cross-Validation: rolling-origin
###############################################################################

results_rolling <- compare_models_cv(
  data = train_data,
  model_names = model_names,
  cv_method = "rolling_origin"
)

selected_rolling <- results_rolling$model[results_rolling$selected_model]
cv_error_rolling <- results_rolling$cv_error[results_rolling$selected_model]


###############################################################################
# 7. Gewählte Modelle auf gesamtem Training fitten
###############################################################################

final_model_kfold <- fit_model_by_name(
  model_name = selected_kfold,
  train_data = train_data
)

final_model_rolling <- fit_model_by_name(
  model_name = selected_rolling,
  train_data = train_data
)


###############################################################################
# 8. Echte Testfehler berechnen
###############################################################################

test_error_kfold <- evaluate_model(
  model = final_model_kfold,
  test_data = test_data
)

test_error_rolling <- evaluate_model(
  model = final_model_rolling,
  test_data = test_data
)


###############################################################################
# 9. Bias berechnen
###############################################################################

# Bias = geschätzter CV-Fehler - echter Testfehler
#
# negativer Bias:
# CV war zu optimistisch
#
# positiver Bias:
# CV war zu pessimistisch

bias_kfold <- cv_error_kfold - test_error_kfold
bias_rolling <- cv_error_rolling - test_error_rolling


###############################################################################
# 10. Ergebnisse zusammenfassen
###############################################################################

mini_results <- data.frame(
  dgp = c("ARMA(1,1)", "ARMA(1,1)"),
  cv_method = c("k-fold", "rolling-origin"),
  selected_model = c(selected_kfold, selected_rolling),
  cv_error = c(cv_error_kfold, cv_error_rolling),
  test_error = c(test_error_kfold, test_error_rolling),
  bias = c(bias_kfold, bias_rolling)
)

mini_results

