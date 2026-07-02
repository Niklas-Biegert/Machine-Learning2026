# Thema 5: Time Series Cross-Validation

## Kernproblem

Klassische Cross-Validation nimmt oft unabhaengige Beobachtungen an. Bei Zeitreihen ist diese Annahme problematisch, weil Beobachtungen zeitlich abhaengig sind. Eine zufaellige Aufteilung kann dadurch zu optimistischen Fehlerschaetzungen fuehren.

## Zu vergleichende Verfahren

- k-fold CV: Standardverfahren, als Referenz und potenziell problematischer Baseline.
- LOOCV: sehr kleine Testsets, bei Zeitreihen ebenfalls kritisch.
- Rolling-Origin CV: trainiert nur auf Vergangenheit und testet auf spaeteren Beobachtungen.
- Blocked CV: nutzt zeitlich zusammenhaengende Bloecke.
- h-block CV: laesst eine Luecke zwischen Training und Test, um Abhaengigkeit zu reduzieren.

## Evaluationsidee

Pro Simulation wird das Verfahren bevorzugt, dessen CV-Fehler das beste Modell auswaehlt. Anschliessend wird auf einem echten Hold-out-Testteil geprueft, wie gut diese Entscheidung war.
