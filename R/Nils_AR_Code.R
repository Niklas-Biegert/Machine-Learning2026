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