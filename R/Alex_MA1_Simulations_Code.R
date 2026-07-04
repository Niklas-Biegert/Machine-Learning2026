###############################################################################
# Simulationsteil: Daten-generierender Prozess
# Ziel: Eine einfache MA(1)-Zeitreihe simulieren
###############################################################################

rm(list = ls())

###############################################################################
# Schritt 1: benötigte Pakete istallieren und laden
###############################################################################

### bisherige Auswahl an Pakten muss evtl. erweitert werden ### 

required_packages <- c(
  "tidyverse",
  "forecast",
  "glmnet",
  "ranger",
  "rsample",
  "yardstick",
  "styler"
)

missing_packages <- required_packages[!vapply(required_packages, 
                    requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  message("Missing R packages: ", paste(missing_packages, collapse = ", "))
  message("Install them with install.packages(missing_packages).")
}

invisible(lapply(required_packages, require, character.only = TRUE))


###############################################################################
# Schritt 2: DGP: MA(1)-Prozess simulieren
###############################################################################

# Zur Reproduzierbarkeit wird ein Seed festgelegt 
set.seed(123)

# Anzahl der Observationen (Vorschlag fuer den ersten Testlauf)
n_obs <- 250

# Selbstgewählter Wert für theta 
theta <- 0.6

# Zufallsschocks erzeugen
epsilon <- rnorm(n_obs, mean = 0, sd = 1)

# "Speicherplatz" über leeren Vektor erzeugen 
y_sim <- numeric(n_obs)

# Simulierte MA(1)-Werte Schritt für Schritt erzeugen 
# Für t=1 gibt es noch keinen vorherigen Schock ε0,
# Deshalb Wert  auf den ersten Schock setzen.
y_sim[1] <- epsilon[1]

# MA(1) DGP
for (t in 2:n_obs) {
  y_sim[t] <- epsilon[t] + theta * epsilon[t - 1]
}

head(y_sim)


###############################################################################
# Schritt 3: Zeitreihen in Dataframe umwandeln / Erster Plot 
###############################################################################

sim_data <- data.frame(
  time = 1:n_obs,
  y_sim = y_sim,
  epsilon = epsilon
)

head(sim_data)

### Plot der MA-Zeitreihe ### 

plot(
  sim_data$time,
  sim_data$y,
  type = "l",
  main = "Simulated MA(1) time series",
  xlab = "Time index",
  ylab = "y"
)

###############################################################################
# Schritt 4: Autokorrelation der simulierten MA(1)-Zeitreihe anschauen
###############################################################################


# Lag heißt hier man überprüft den Zusammenhang zwischen einzelnen Werten der 
# Zeitreihe. Lag_1 hier: Zusammenhang zwischen yt und yt-1 (also dem benachbarten
# Wert). Bis lag_30 (also einem Wert im Vergleich mit dem Wert 30 "Stellen" zuvor)
# Werden Zusammenhänge überprüft.

acf(
  sim_data$y,
  lag.max = 30,
  main = "ACF of simulated MA(1) time series"
)

### Ergebnis 
# Bei Lag_O = 1:      logisch, eine Zeitreige erklärt sich selbst immer perfekt
# Bei Lag_1 ca. 0,4:  Benachbarte Werte teilen den selben Zufallsschock  
# Bei >Lag_2 ca. 0:   Werte teilen sich keinen Zufallsschock mehr 


###############################################################################
# Schritt 5: Training-Test-Split der simulierten MA(1)-Zeitreihe
###############################################################################

### Analysedatensatz erstellen ###

analysis_data <- data.frame(
  time = sim_data$time,
  y = sim_data$y
)

# Der volle Datensatz enthält nun auch die Epsilon Werte. Diese kennt man 
# aber im Normalfall nicht. Deshalb wird diese Spalte im Vorfeld entfernt und 
# es Analysedatensatz wird aus dem simulierten Dataframe erzeugt.


### (Zeitlicher) Training-Test-Split ###

n_train <- 175
train_raw <- analysis_data[1:n_train, ]
test_raw <- analysis_data[(n_train + 1):n_obs, ]

# Ursprüngliche Reihenfolge noch immer beibehalten, demnach erste 175 Beobachtungen
# und letzte 75 noch in zeitlicher Dimension richtig


### Lag-Feature im Trainingsdatensatz erstellen ###

train_data <- train_raw

train_data$lag_1 <- c(
  NA,
  train_data$y[1:(nrow(train_data) - 1)]
)

train_data <- na.omit(train_data)

# Dem Analysedatensatz wird eine die Spalte Lag_1 hinzugefügt. Für den ersten Wert
# kann es noch keinen Vorgänger-Wert geben, deshalb wird dieser NA gesetzt und 
# anschließend entfernt


### Lag-Feature im Testdatensatz erstellen ###

test_data <- test_raw

last_train_y <- train_raw$y[nrow(train_raw)]

test_data$lag_1 <- c(
  last_train_y,
  test_data$y[1:(nrow(test_data) - 1)]
)
# Erster Wert hier = Letzter Wert aus train_data (175)


###############################################################################
# Schritt 6: Kandidaten Modell(e) definieren: LM mit 1 Lag 
###############################################################################


### Prognosemodell auf Trainingsdaten fitten ###

model_lm_lag1 <- lm(
  y ~ lag_1,
  data = train_data
)

summary(model_lm_lag1)

###  Prognosemodell auf Testdaten übertragen ###

test_data$predicted_y <- predict(
  model_lm_lag1,
  newdata = test_data
)

head(test_data, 10)
