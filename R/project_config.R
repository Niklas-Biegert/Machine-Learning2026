###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/project_config.R
#
# Zweck:
# Zentrale technische Konfiguration fuer reproduzierbare Abgabelaeufe.
###############################################################################

get_project_config <- function() {
  list(
    seed = 20260716,
    max_lag = 30,
    train_start = 31,
    train_end = 184,
    test_start = 185,
    test_end = 250,
    n_cv_splits = 5,
    dgp_name = "ARMA(1,1)",
    T = 250,
    sigma = 1
  )
}

derive_train_prop <- function(config) {
  n_after_lags <- config$test_end - config$train_start + 1
  n_train <- config$train_end - config$train_start + 1
  n_train / n_after_lags
}

