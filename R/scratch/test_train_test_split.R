###############################################################################
# Testskript für Train/Test-Split
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))
source(here("R", "03_train_test_split.R"))

set.seed(123)

# 1. ARMA-Zeitreihe simulieren
y_arma <- simulate_arma11(
  T = 250,
  phi = 0.6,
  theta = 0.5,
  sigma = 1
)

# 2. Lag-Features bauen
lag_data <- create_lags(
  y = y_arma,
  max_lag = 5
)

# 3. Train/Test-Split machen
split_data <- time_train_test_split(
  data = lag_data,
  train_prop = 0.7
)

train_data <- split_data$train
test_data <- split_data$test

# 4. Ergebnis prüfen
dim(lag_data)
dim(train_data)
dim(test_data)

head(train_data)
tail(train_data)

head(test_data)
tail(test_data)
