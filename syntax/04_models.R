###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/04_models.R
#
# Zweck:
# Forecasting-Modelle für Zeitreihendaten mit Lag-Features definieren.
###############################################################################

mse <- function(actual, predicted) {
  mean((actual - predicted)^2)
}

rmse <- function(actual, predicted) {
  sqrt(mse(actual, predicted))
}

mae <- function(actual, predicted) {
  mean(abs(actual - predicted))
}

fit_lm_lag1 <- function(train_data) {
  if (!("lag_1" %in% names(train_data))) {
    stop("train_data muss eine Spalte 'lag_1' enthalten.")
  }

  lm(y ~ lag_1, data = train_data)
}

fit_lm_lag5 <- function(train_data) {
  fit_lm_lags(train_data = train_data, max_lag = 5)
}

fit_lm_lags <- function(train_data, max_lag = 5) {
  required_lags <- paste0("lag_", seq_len(max_lag))
  missing_lags <- required_lags[!required_lags %in% names(train_data)]

  if (length(missing_lags) > 0) {
    stop("Folgende Lag-Spalten fehlen: ", paste(missing_lags, collapse = ", "))
  }

  formula <- as.formula(paste("y ~", paste(required_lags, collapse = " + ")))
  lm(formula, data = train_data)
}

fit_primary_model <- function(train_data, config) {
  fit_lm_lags(train_data = train_data, max_lag = config$primary_max_lag)
}

predict_model <- function(model, new_data) {
  as.numeric(predict(model, newdata = new_data))
}

evaluate_model <- function(model, test_data) {
  predicted <- predict_model(model = model, new_data = test_data)
  rmse(actual = test_data$y, predicted = predicted)
}

evaluate_model_mse <- function(model, test_data) {
  predicted <- predict_model(model = model, new_data = test_data)
  mse(actual = test_data$y, predicted = predicted)
}

fit_model_by_name <- function(model_name, train_data) {
  if (model_name == "LM-lag1") {
    return(fit_lm_lag1(train_data))
  }

  if (model_name == "LM-lag5") {
    return(fit_lm_lag5(train_data))
  }

  stop("Unbekanntes Modell: ", model_name)
}

