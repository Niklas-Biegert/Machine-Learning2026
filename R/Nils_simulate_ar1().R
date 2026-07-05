set.seed(123)

t <- 250       # Anzahl der Zeitpunkte
phi <- 0.7     # AR(1)-Koeffizient
mu <- 10       # Langfristiger Mittelwert
sigma <- 17    # Standardabweichung der Fehler

# Stationarität prüfen
if (abs(phi) >= 1) {
  stop("Die AR(1)-Zeitreihe ist nicht stationär, da |phi| >= 1 gilt.")
}

# AR(1)-Zeitreihe simulieren und als numerischen Vektor speichern
y <- as.numeric(
  mu + arima.sim(
    model = list(ar = phi),
    n = t,
    sd = sigma
  )
)

# Ergebnis anzeigen
y

# Struktur prüfen
is.numeric(y)
length(y)







#so? ##############################################






###############################################################################
# Simulationsteil: AR(1)-Daten-generierender Prozess
# Ziel: Eine einfache AR(1)-Zeitreihe simulieren
###############################################################################

# Seed setzen, damit die Simulation reproduzierbar ist
set.seed(123)


###############################################################################
# Schritt 1: Funktion zur Simulation eines AR(1)-Prozesses
###############################################################################

# AR(1) bedeutet:
# Der aktuelle Wert y_t hängt vom vorherigen Wert y_{t-1} ab.
#
# Modell:
# y_t = phi * y_{t-1} + epsilon_t
#
# phi     = AR-Parameter, also Stärke des Einflusses von y_{t-1}
# sigma   = Standardabweichung des Fehlerterms
# epsilon = zufälliger Fehler / Schock
# T       = Länge der Zeitreihe

simulate_ar1 <- function(T = 250, phi = 0.7, sigma = 1) {
  
  # Stationarität prüfen:
  # Für einen stationären AR(1)-Prozess muss |phi| < 1 gelten.
  if (abs(phi) >= 1) {
    stop("Die AR(1)-Zeitreihe ist nicht stationär, da |phi| >= 1 gilt.")
  }
  
  # Zufällige Fehler / Schocks erzeugen
  epsilon <- rnorm(T, mean = 0, sd = sigma)
  
  # Leeren Vektor für die Zeitreihe erstellen
  y <- numeric(T)
  
  # Startwert setzen
  y[1] <- epsilon[1]
  
  # AR(1)-Prozess Schritt für Schritt simulieren
  for (i in 2:T) {
    y[i] <- phi * y[i - 1] + epsilon[i]
  }
  
  # Simulierte Zeitreihe zurückgeben
  return(y)
}


###############################################################################
# Schritt 2: Testlauf der AR(1)-Simulation
###############################################################################

# Parameter für den ersten Testlauf
T <- 250
phi <- 0.7
sigma <- 1

# AR(1)-Zeitreihe simulieren
y_ar <- simulate_ar1(
  T = T,
  phi = phi,
  sigma = sigma
)


###############################################################################
# Schritt 3: Struktur prüfen
###############################################################################

# Prüfen, ob y_ar ein numerischer Vektor ist
is.numeric(y_ar)

# Prüfen, ob die Länge stimmt
length(y_ar)

# Erste Werte anzeigen
head(y_ar)


###############################################################################
# Schritt 4: Dataframe erstellen
###############################################################################

ar_data <- data.frame(
  time = 1:T,
  y = y_ar,
  dgp = "AR(1)",
  phi = phi,
  sigma = sigma
)

head(ar_data)


###############################################################################
# Schritt 5: AR(1)-Zeitreihe plotten
###############################################################################

plot(
  ar_data$time,
  ar_data$y,
  type = "l",
  main = "Simulierte AR(1)-Zeitreihe",
  xlab = "Zeit",
  ylab = "y"
)


###############################################################################
# Schritt 6: Autokorrelation anschauen
###############################################################################

# ACF = Autokorrelationsfunktion
# Sie zeigt, wie stark y_t mit vergangenen Werten zusammenhängt.
#
# Bei einem AR(1)-Prozess sollte die ACF langsam abfallen,
# weil vergangene Werte über phi weiterwirken.

acf(
  ar_data$y,
  lag.max = 30,
  main = "ACF der simulierten AR(1)-Zeitreihe"
)


###############################################################################
# Kurze Interpretation
###############################################################################

# Interpretation:
#
# Der AR(1)-Prozess beschreibt eine Zeitreihe, bei der der aktuelle Wert y_t
# vom vorherigen Wert y_{t-1} abhängt.
#
# Der Parameter phi bestimmt die Stärke dieser Abhängigkeit.
#
# Bei phi = 0.7 ist die zeitliche Abhängigkeit relativ stark:
# Wenn ein Wert heute hoch ist, ist der nächste Wert tendenziell ebenfalls hoch.
#
# Da |phi| < 1 gilt, ist der Prozess stationär.
#
# Die simulierte Zeitreihe kann später als daten-generierender Prozess
# in der Monte-Carlo-Studie verwendet werden.
###############################################################################




