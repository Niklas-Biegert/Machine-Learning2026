###############################################################################
# Testskript für die DGP-Funktionen
# Datei: R/scratch/test_dgps.R
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))

###############################################################################
# 1. Testparameter setzen
###############################################################################

set.seed(123)

T <- 250
sigma <- 1


###############################################################################
# 2. Drei Zeitreihen simulieren
###############################################################################

y_ar <- simulate_ar1(
  T = T,
  phi = 0.7,
  sigma = sigma
)

y_ma <- simulate_ma1(
  T = T,
  theta = 0.6,
  sigma = sigma
)

y_arma <- simulate_arma11(
  T = T,
  phi = 0.6,
  theta = 0.5,
  sigma = sigma
)


###############################################################################
# 3. Struktur prüfen
###############################################################################

is.numeric(y_ar)
is.numeric(y_ma)
is.numeric(y_arma)

length(y_ar)
length(y_ma)
length(y_arma)

head(y_ar)
head(y_ma)
head(y_arma)


###############################################################################
# 4. Dataframes erstellen
###############################################################################

ar_data <- data.frame(
  time = 1:T,
  y = y_ar,
  dgp = "AR(1)"
)

ma_data <- data.frame(
  time = 1:T,
  y = y_ma,
  dgp = "MA(1)"
)

arma_data <- data.frame(
  time = 1:T,
  y = y_arma,
  dgp = "ARMA(1,1)"
)


###############################################################################
# 5. Zeitreihen plotten
###############################################################################

par(mfrow = c(3, 1))

plot(
  ar_data$time,
  ar_data$y,
  type = "l",
  main = "Simulierte AR(1)-Zeitreihe",
  xlab = "Zeit",
  ylab = "y"
)

plot(
  ma_data$time,
  ma_data$y,
  type = "l",
  main = "Simulierte MA(1)-Zeitreihe",
  xlab = "Zeit",
  ylab = "y"
)

plot(
  arma_data$time,
  arma_data$y,
  type = "l",
  main = "Simulierte ARMA(1,1)-Zeitreihe",
  xlab = "Zeit",
  ylab = "y"
)

par(mfrow = c(1, 1))


###############################################################################
# 6. ACF-Plots anschauen
###############################################################################

par(mfrow = c(3, 1))

acf(
  ar_data$y,
  lag.max = 30,
  main = "ACF AR(1)"
)

acf(
  ma_data$y,
  lag.max = 30,
  main = "ACF MA(1)"
)

acf(
  arma_data$y,
  lag.max = 30,
  main = "ACF ARMA(1,1)"
)

par(mfrow = c(1, 1))

