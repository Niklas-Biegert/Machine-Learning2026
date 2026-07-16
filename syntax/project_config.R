###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/project_config.R
#
# Zweck:
# Zentrale technische Konfiguration für reproduzierbare Abgabeläufe.
###############################################################################

get_project_config <- function() {
  list(
    seed = 20260716,

    # Gemeinsame Zeitreihenlänge und Holdout-Design
    T = 250,
    sigma = 1,
    train_start = 31,
    train_end = 184,
    test_start = 185,
    test_end = 250,

    # Teil A: zentrale Monte-Carlo-CV-Studie
    primary_max_lag = 5,
    primary_model_name = "LM-lag5",
    cv_methods = c("kfold", "blocked", "hblock", "rolling_origin"),
    dgp_names = c("AR(1)", "MA(1)", "ARMA(1,1)", "Trend", "Seasonal"),
    n_mc_pilot = 5,
    n_mc_final = 200,
    n_cv_splits = 5,
    h_block = 5,
    burn_in = 100,
    ar_phi = 0.7,
    ma_theta = 0.6,
    arma_phi = 0.6,
    arma_theta = 0.5,
    trend_beta0 = 0,
    trend_beta1 = 0.03,
    seasonal_amplitude = 2,
    seasonal_period = 12,

    # Teil B: bestehende ARMA(1,1)-Fallstudie mit 30 Lags
    max_lag = 30,
    dgp_name = "ARMA(1,1)"
  )
}

derive_train_prop <- function(config) {
  n_after_lags <- config$test_end - config$train_start + 1
  n_train <- config$train_end - config$train_start + 1
  n_train / n_after_lags
}

get_primary_formula <- function(config) {
  lags <- paste0("lag_", seq_len(config$primary_max_lag))
  as.formula(paste("y ~", paste(lags, collapse = " + ")))
}

