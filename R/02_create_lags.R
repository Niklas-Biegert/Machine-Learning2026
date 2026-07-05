###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/02_create_lags.R
#
# Zweck:
# Aus einer simulierten Zeitreihe Lag-Features erzeugen.
#
# Beispiel:
# y_t soll durch vergangene Werte y_{t-1}, y_{t-2}, ... vorhergesagt werden.
###############################################################################


###############################################################################
# Funktion: Lag-Features erzeugen
###############################################################################

create_lags <- function(y, max_lag = 5) {
  
  # Sicherheitsprüfung
  if (!is.numeric(y)) {
    stop("y muss ein numerischer Vektor sein.")
  }
  
  if (max_lag < 1) {
    stop("max_lag muss mindestens 1 sein.")
  }
  
  if (length(y) <= max_lag) {
    stop("Die Zeitreihe muss länger sein als max_lag.")
  }
  
  # Dataframe mit Zielvariable y erstellen
  data <- data.frame(
    time = 1:length(y),
    y = y
  )
  
  # Lag-Spalten hinzufügen
  for (lag in 1:max_lag) {
    data[[paste0("lag_", lag)]] <- c(
      rep(NA, lag),
      y[1:(length(y) - lag)]
    )
  }
  
  # Zeilen mit NA entfernen
  data <- na.omit(data)
  
  # Zeilennamen zurücksetzen
  rownames(data) <- NULL
  
  return(data)
}
