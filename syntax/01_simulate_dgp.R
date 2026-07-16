###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/01_simulate_dgp.R
#
# Zweck:
# Funktionen zur Simulation der daten-generierenden Prozesse für die zentrale
# Monte-Carlo-Studie und die ARMA(1,1)-Fallstudie.
###############################################################################

simulate_ar1 <- function(T = 250, phi = 0.7, sigma = 1, burn_in = 0) {
  if (abs(phi) >= 1) {
    stop("AR(1) ist nicht stationär, da |phi| >= 1 gilt.")
  }

  total_T <- T + burn_in
  epsilon <- rnorm(total_T, mean = 0, sd = sigma)
  y <- numeric(total_T)
  y[1] <- epsilon[1]

  for (i in 2:total_T) {
    y[i] <- phi * y[i - 1] + epsilon[i]
  }

  tail(y, T)
}

simulate_ma1 <- function(T = 250, theta = 0.6, sigma = 1, burn_in = 0) {
  total_T <- T + burn_in
  epsilon <- rnorm(total_T, mean = 0, sd = sigma)
  y <- numeric(total_T)
  y[1] <- epsilon[1]

  for (i in 2:total_T) {
    y[i] <- epsilon[i] + theta * epsilon[i - 1]
  }

  tail(y, T)
}

simulate_arma11 <- function(T = 250, phi = 0.6, theta = 0.5, sigma = 1, burn_in = 0) {
  if (abs(phi) >= 1) {
    stop("ARMA(1,1) ist nicht stationär, da |phi| >= 1 gilt.")
  }

  total_T <- T + burn_in
  epsilon <- rnorm(total_T, mean = 0, sd = sigma)
  y <- numeric(total_T)
  y[1] <- epsilon[1]

  for (i in 2:total_T) {
    y[i] <- phi * y[i - 1] + epsilon[i] + theta * epsilon[i - 1]
  }

  tail(y, T)
}

simulate_trend <- function(T = 250, beta0 = 0, beta1 = 0.03, sigma = 1) {
  time <- seq_len(T)
  beta0 + beta1 * time + rnorm(T, mean = 0, sd = sigma)
}

simulate_seasonal <- function(T = 250, amplitude = 2, period = 12, sigma = 1) {
  time <- seq_len(T)
  amplitude * sin(2 * pi * time / period) + rnorm(T, mean = 0, sd = sigma)
}

simulate_dgp <- function(dgp_name, config) {
  if (dgp_name == "AR(1)") {
    return(simulate_ar1(
      T = config$T,
      phi = config$ar_phi,
      sigma = config$sigma,
      burn_in = config$burn_in
    ))
  }

  if (dgp_name == "MA(1)") {
    return(simulate_ma1(
      T = config$T,
      theta = config$ma_theta,
      sigma = config$sigma,
      burn_in = config$burn_in
    ))
  }

  if (dgp_name == "ARMA(1,1)") {
    return(simulate_arma11(
      T = config$T,
      phi = config$arma_phi,
      theta = config$arma_theta,
      sigma = config$sigma,
      burn_in = config$burn_in
    ))
  }

  if (dgp_name == "Trend") {
    return(simulate_trend(
      T = config$T,
      beta0 = config$trend_beta0,
      beta1 = config$trend_beta1,
      sigma = config$sigma
    ))
  }

  if (dgp_name == "Seasonal") {
    return(simulate_seasonal(
      T = config$T,
      amplitude = config$seasonal_amplitude,
      period = config$seasonal_period,
      sigma = config$sigma
    ))
  }

  stop("Unbekannter DGP: ", dgp_name)
}

