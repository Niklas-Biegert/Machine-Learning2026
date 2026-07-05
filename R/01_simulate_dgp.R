###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/01_simulate_dgp.R
#
# Zweck:
# Funktionen zur Simulation der daten-generierenden Prozesse:
# 1. AR(1)
# 2. MA(1)
# 3. ARMA(1,1)
#
# Hinweis:
# Diese Datei definiert nur Funktionen.
# Sie setzt keinen Working Directory und nutzt keine festen Dateipfade.
###############################################################################


###############################################################################
# 1. AR(1)-Prozess simulieren
###############################################################################

simulate_ar1 <- function(T = 250, phi = 0.7, sigma = 1) {
  
  if (abs(phi) >= 1) {
    stop("AR(1) ist nicht stationär, da |phi| >= 1 gilt.")
  }
  
  epsilon <- rnorm(T, mean = 0, sd = sigma)
  y <- numeric(T)
  
  y[1] <- epsilon[1]
  
  for (i in 2:T) {
    y[i] <- phi * y[i - 1] + epsilon[i]
  }
  
  return(y)
}


###############################################################################
# 2. MA(1)-Prozess simulieren
###############################################################################

simulate_ma1 <- function(T = 250, theta = 0.6, sigma = 1) {
  
  epsilon <- rnorm(T, mean = 0, sd = sigma)
  y <- numeric(T)
  
  y[1] <- epsilon[1]
  
  for (i in 2:T) {
    y[i] <- epsilon[i] + theta * epsilon[i - 1]
  }
  
  return(y)
}


###############################################################################
# 3. ARMA(1,1)-Prozess simulieren
###############################################################################

simulate_arma11 <- function(T = 250, phi = 0.6, theta = 0.5, sigma = 1) {
  
  if (abs(phi) >= 1) {
    stop("ARMA(1,1) ist nicht stationär, da |phi| >= 1 gilt.")
  }
  
  epsilon <- rnorm(T, mean = 0, sd = sigma)
  y <- numeric(T)
  
  y[1] <- epsilon[1]
  
  for (i in 2:T) {
    y[i] <- phi * y[i - 1] + epsilon[i] + theta * epsilon[i - 1]
  }
  
  return(y)
}
