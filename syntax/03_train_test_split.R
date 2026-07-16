###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/03_train_test_split.R
#
# Zweck:
# Zeitlich korrekter Train/Test-Split für Zeitreihendaten.
#
# Wichtig:
# Bei Zeitreihen wird nicht zufällig gesplittet.
# Die Vergangenheit wird als Training verwendet,
# die Zukunft als echter Testbereich.
###############################################################################


###############################################################################
# Funktion: Zeitlicher Train/Test-Split
###############################################################################

time_train_test_split <- function(data, train_prop = 0.7) {
  
  # Sicherheitsprüfungen
  if (!is.data.frame(data)) {
    stop("data muss ein Dataframe sein.")
  }
  
  if (!("y" %in% names(data))) {
    stop("data muss eine Spalte namens 'y' enthalten.")
  }
  
  if (train_prop <= 0 || train_prop >= 1) {
    stop("train_prop muss zwischen 0 und 1 liegen.")
  }
  
  # Anzahl der Beobachtungen
  n <- nrow(data)
  
  # Anzahl Trainingsbeobachtungen
  n_train <- floor(train_prop * n)
  
  # Zeitlicher Split:
  # erste Beobachtungen = Training
  # letzte Beobachtungen = Test
  train_data <- data[1:n_train, ]
  test_data <- data[(n_train + 1):n, ]
  
  # Zeilennamen zurücksetzen
  rownames(train_data) <- NULL
  rownames(test_data) <- NULL
  
  # Ergebnis als Liste zurückgeben
  return(list(
    train = train_data,
    test = test_data
  ))
}
