###############################################################################
# Testskript für Lag-Feature-Funktion
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))

set.seed(123)

# Beispiel-Zeitreihe simulieren
y_arma <- simulate_arma11(
  T = 250,
  phi = 0.6,
  theta = 0.5,
  sigma = 1
)

# Lag-Features erzeugen
lag_data <- create_lags(
  y = y_arma,
  max_lag = 5
)

# Ergebnis anschauen
head(lag_data, 10)
dim(lag_data)