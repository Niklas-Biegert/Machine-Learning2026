###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/04_models.R
#
# Zweck:
# Forecasting-Modelle für Zeitreihendaten mit Lag-Features definieren.
#
# Erste Modelle:
# 1. LM-lag1: lineare Regression mit lag_1
# 2. LM-lag5: lineare Regression mit lag_1 bis lag_5
###############################################################################


###############################################################################
# Hilfsfunktion: RMSE berechnen
###############################################################################

# RMSE = Root Mean Squared Error
# Also: Wurzel aus dem mittleren quadratischen Fehler.
#
# Je kleiner der RMSE, desto besser die Vorhersage.

rmse <- function(actual, predicted) {
  
  sqrt(mean((actual - predicted)^2))
  
}


###############################################################################
# Modell 1: Lineare Regression mit lag_1
###############################################################################

fit_lm_lag1 <- function(train_data) {
  
  # Sicherheitsprüfung
  if (!("lag_1" %in% names(train_data))) {
    stop("train_data muss eine Spalte 'lag_1' enthalten.")
  }
  
  model <- lm(
    y ~ lag_1,
    data = train_data
  )
  
  return(model)
}


###############################################################################
# Modell 2: Lineare Regression mit lag_1 bis lag_5
###############################################################################

fit_lm_lag5 <- function(train_data) {
  
  required_lags <- paste0("lag_", 1:5)
  
  missing_lags <- required_lags[!required_lags %in% names(train_data)]
  
  if (length(missing_lags) > 0) {
    stop(
      "Folgende Lag-Spalten fehlen: ",
      paste(missing_lags, collapse = ", ")
    )
  }
  
  model <- lm(
    y ~ lag_1 + lag_2 + lag_3 + lag_4 + lag_5,
    data = train_data
  )
  
  return(model)
}


###############################################################################
# Vorhersagen erzeugen
###############################################################################

predict_model <- function(model, new_data) {
  
  predictions <- predict(
    model,
    newdata = new_data
  )
  
  return(as.numeric(predictions))
}


###############################################################################
# Modell auf Testdaten bewerten
###############################################################################

evaluate_model <- function(model, test_data) {
  
  predicted <- predict_model(
    model = model,
    new_data = test_data
  )
  
  error <- rmse(
    actual = test_data$y,
    predicted = predicted
  )
  
  return(error)
}

