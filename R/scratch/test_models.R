###############################################################################
# Testskript für Forecasting-Modelle
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))
source(here("R", "03_train_test_split.R"))
source(here("R", "04_models.R"))


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
# 4. Modelle fitten
###############################################################################

model_lag1 <- fit_lm_lag1(train_data)
model_lag5 <- fit_lm_lag5(train_data)


###############################################################################
# 5. Modelle auf Testdaten bewerten
###############################################################################

rmse_lag1 <- evaluate_model(
  model = model_lag1,
  test_data = test_data
)

rmse_lag5 <- evaluate_model(
  model = model_lag5,
  test_data = test_data
)


###############################################################################
# 6. Ergebnisse anzeigen
###############################################################################

rmse_lag1
rmse_lag5

results <- data.frame(
  model = c("LM-lag1", "LM-lag5"),
  test_rmse = c(rmse_lag1, rmse_lag5)
)

results

