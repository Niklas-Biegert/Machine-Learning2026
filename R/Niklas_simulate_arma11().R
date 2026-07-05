###############################################################################
# Simulationsteil: ARMA(1,1)-Daten-generierender Prozess
# Ziel: Eine einfache ARMA(1,1)-Zeitreihe simulieren
###############################################################################

# Seed setzen, damit die Simulation reproduzierbar ist
set.seed(123)


###############################################################################
# Schritt 1: Funktion zur Simulation eines ARMA(1,1)-Prozesses
###############################################################################

# ARMA(1,1) bedeutet:
# Der aktuelle Wert y_t hängt vom vorherigen Wert y_{t-1},
# vom aktuellen Fehler epsilon_t und vom vorherigen Fehler epsilon_{t-1} ab.
#
# Modell:
# y_t = phi * y_{t-1} + epsilon_t + theta * epsilon_{t-1}
#
# phi    = AR-Parameter, also Stärke des Einflusses von y_{t-1}
# theta  = MA-Parameter, also Stärke des Einflusses von epsilon_{t-1}
# sigma  = Standardabweichung des Fehlerterms
# epsilon = zufälliger Fehler / Schock
# T      = Länge der Zeitreihe

simulate_arma11 <- function(T = 250, phi = 0.6, theta = 0.5, sigma = 1) {
  
  # Stationarität prüfen:
  # Für den AR-Anteil muss |phi| < 1 gelten.
  if (abs(phi) >= 1) {
    stop("Die ARMA(1,1)-Zeitreihe ist nicht stationär, da |phi| >= 1 gilt.")
  }
  
  # Zufällige Fehler / Schocks erzeugen
  epsilon <- rnorm(T, mean = 0, sd = sigma)
  
  # Leeren Vektor für die Zeitreihe erstellen
  y <- numeric(T)
  
  # Startwert setzen:
  # Für t = 1 gibt es noch keinen vorherigen Wert y_0
  # und keinen vorherigen Fehler epsilon_0.
  # Deshalb setzen wir y[1] gleich dem ersten Fehler.
  y[1] <- epsilon[1]
  
  # ARMA(1,1)-Prozess Schritt für Schritt simulieren
  for (i in 2:T) {
    y[i] <- phi * y[i - 1] + epsilon[i] + theta * epsilon[i - 1]
  }
  
  # Simulierte Zeitreihe zurückgeben
  return(y)
}


###############################################################################
# Schritt 2: Testlauf der ARMA(1,1)-Simulation
###############################################################################

# Parameter für den ersten Testlauf
T <- 250
phi <- 0.6
theta <- 0.5
sigma <- 1

# ARMA(1,1)-Zeitreihe simulieren
y_arma <- simulate_arma11(
  T = T,
  phi = phi,
  theta = theta,
  sigma = sigma
)


###############################################################################
# Schritt 3: Struktur prüfen
###############################################################################

# Prüfen, ob y_arma ein numerischer Vektor ist
is.numeric(y_arma)

# Prüfen, ob die Länge stimmt
length(y_arma)

# Erste Werte anzeigen
head(y_arma)


###############################################################################
# Schritt 4: Dataframe erstellen
###############################################################################

arma_data <- data.frame(
  time = 1:T,
  y = y_arma,
  dgp = "ARMA(1,1)",
  phi = phi,
  theta = theta,
  sigma = sigma
)

head(arma_data)


###############################################################################
# Schritt 5: ARMA(1,1)-Zeitreihe plotten
###############################################################################

plot(
  arma_data$time,
  arma_data$y,
  type = "l",
  main = "Simulierte ARMA(1,1)-Zeitreihe",
  xlab = "Zeit",
  ylab = "y"
)


###############################################################################
# Schritt 6: Autokorrelation anschauen
###############################################################################

# ACF = Autokorrelationsfunktion
# Sie zeigt, wie stark y_t mit vergangenen Werten zusammenhängt.
#
# Bei einem ARMA(1,1)-Prozess sieht man typischerweise ein gemischtes Muster:
# Der AR-Teil sorgt für ein Nachwirken vergangener Werte.
# Der MA-Teil sorgt für eine Nachwirkung vergangener Fehler.

acf(
  arma_data$y,
  lag.max = 30,
  main = "ACF der simulierten ARMA(1,1)-Zeitreihe"
)


###############################################################################
# Schritt 7: Partielle Autokorrelation anschauen
###############################################################################

# PACF = partielle Autokorrelationsfunktion
# Sie zeigt den direkten Zusammenhang mit vergangenen Werten,
# nachdem Zwischen-Lags berücksichtigt wurden.
#
# Bei ARMA(1,1) ist das Muster meistens nicht so eindeutig wie bei reinem AR(1)
# oder reinem MA(1), weil beide Strukturen kombiniert werden.

pacf(
  arma_data$y,
  lag.max = 30,
  main = "PACF der simulierten ARMA(1,1)-Zeitreihe"
)


###############################################################################
# Kurze Interpretation
###############################################################################

# Interpretation:
#
# Der ARMA(1,1)-Prozess kombiniert einen AR-Anteil und einen MA-Anteil.
#
# Der AR-Anteil bedeutet:
# Der aktuelle Wert y_t hängt vom vorherigen Wert y_{t-1} ab.
#
# Der MA-Anteil bedeutet:
# Der aktuelle Wert y_t hängt zusätzlich vom vorherigen Fehlerterm
# epsilon_{t-1} ab.
#
# Der Parameter phi bestimmt die Stärke des AR-Anteils.
# Der Parameter theta bestimmt die Stärke des MA-Anteils.
#
# Bei phi = 0.6 und theta = 0.5 liegt eine mittlere zeitliche Abhängigkeit vor.
#
# Diese simulierte Zeitreihe ist für unser Projekt wichtig, weil sie komplexer
# ist als ein reiner AR(1)- oder MA(1)-Prozess. Dadurch können wir später testen,
# ob verschiedene Cross-Validation-Verfahren auch bei gemischter zeitlicher
# Abhängigkeit zuverlässige Fehlerschätzungen liefern.
###############################################################################