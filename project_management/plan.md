# Projektplan

## Eckdaten

- Thema: Time Series Cross-Validation for Temporal Data
- Team: Alex, Nils, Niklas
- Abgabe Hausarbeit: 05.08.2026
- Praesentation: 12.08.2026
- Optionaler Ersatztermin: 09.09.2026

## Meilensteine

| Datum | Meilenstein |
| --- | --- |
| 01.07.2026 | Kick-off und Organisation |
| 06.07.2026 | GitHub und Zugang abgeschlossen |
| 15.07.2026 | Studiendesign fix |
| 24.07.2026 | erster kompletter Testlauf |
| 05.08.2026 | Hausarbeit abgegeben |
| 12.08.2026 | Praesentation |

## Arbeitsphasen

1. Fragestellung definieren.
2. Theoretische Grundlagen zu k-fold, LOOCV, Rolling-Origin, Blocked CV und h-block CV aufarbeiten.
3. Simulationsdesign fuer AR-, MA-, ARMA-Prozesse, Trend und Saisonalitaet festlegen.
4. Modelle auswaehlen: Lag-Regression, Ridge/Lasso, Tree-Based Methods.
5. Monte-Carlo-Simulationen implementieren.
6. Evaluation mit Bias, Varianz, RMSE, Model-Selection Accuracy und Laufzeit.
7. Ergebnisse interpretieren und Empfehlungen ableiten.

## Offene Entscheidungen

- Finale Laenge der Zeitreihen `T`.
- Anzahl Monte-Carlo-Wiederholungen `R`.
- Kandidaten-Lags fuer Forecasting-Modelle.
- h-Werte fuer h-block CV.
- Umfang der Tree-Based Methods.
