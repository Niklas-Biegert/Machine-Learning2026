simulate_ar1 <- function(n = 250, phi = 0.6, sigma = 1, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  innovations <- rnorm(n, mean = 0, sd = sigma)
  y <- numeric(n)
  y[1] <- innovations[1] / sqrt(1 - phi^2)

  for (t in 2:n) {
    y[t] <- phi * y[t - 1] + innovations[t]
  }

  data.frame(t = seq_len(n), y = y)
}

simulate_trend_seasonal <- function(n = 250, trend = 0.02, period = 12, amplitude = 1, sigma = 1, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  time <- seq_len(n)
  y <- trend * time + amplitude * sin(2 * pi * time / period) + rnorm(n, sd = sigma)

  data.frame(t = time, y = y)
}
