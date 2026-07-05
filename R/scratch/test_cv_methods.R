###############################################################################
# Testskript für Cross-Validation-Methoden
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))
source(here("R", "03_train_test_split.R"))
source(here("R", "04_models.R"))
source(here("R", "05_cv_methods.R"))


###############################################################################
# 1. Beispiel-Zeitreihe simulieren
###############################################################################

set.seed(123)

y_arma <- simulate_arma11(
  T = 250,
  phi = 0.6,
  theta = 0.5,
  sigma = 1
)


###############################################################################
# 2. Lag-Features bauen
###############################################################################

lag_data <- create_lags(
  y = y_arma,
  max_lag = 5
)


###############################################################################
# 3. Train/Test-Split
###############################################################################

split_data <- time_train_test_split(
  data = lag_data,
  train_prop = 0.7
)

train_data <- split_data$train
test_data <- split_data$test


###############################################################################
# 4. Kandidatenmodelle festlegen
###############################################################################

model_names <- c(
  "LM-lag1",
  "LM-lag5"
)


###############################################################################
# 5. k-fold CV durchführen
###############################################################################

results_kfold <- compare_models_cv(
  data = train_data,
  model_names = model_names,
  cv_method = "kfold"
)

results_kfold


###############################################################################
# 6. rolling-origin CV durchführen
###############################################################################

results_rolling <- compare_models_cv(
  data = train_data,
  model_names = model_names,
  cv_method = "rolling_origin"
)

results_rolling


###############################################################################
# 7. Gewählte Modelle anschauen
###############################################################################

selected_kfold <- results_kfold$model[results_kfold$selected_model]
selected_rolling <- results_rolling$model[results_rolling$selected_model]

selected_kfold
selected_rolling

