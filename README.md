# Machine Learning 2026


# Zeitreihenprognosen mit Rolling-Origin-Cross-Validation

## Projektziel

Dieses Projekt untersucht Prognosemodelle für eine simulierte
ARMA(1,1)-Zeitreihe. Im Mittelpunkt steht nicht nur die Vorhersagegüte,
sondern auch die Frage, wie zuverlässig eine zeitgerichtete
Rolling-Origin-Cross-Validation den späteren Fehler auf einem
vollständig unabhängigen Testzeitraum schätzt.

Die finale Analyse vergleicht eine naive Prognose, zwei OLS-Modelle
sowie Ridge und Lasso. Alle Modelle verwenden dieselben Beobachtungen
und werden auf exakt denselben 66 Testzeitpunkten bewertet.

## Forschungsfrage

Wie gut prognostizieren OLS, Ridge und Lasso eine ARMA(1,1)-Zeitreihe
mit bis zu 30 verzögerten Prädiktoren, und wie zuverlässig schätzt
Rolling-Origin-Cross-Validation den späteren Testfehler?

## Vorgehen

- Daten-generierender Prozess: ARMA(1,1)
- Zeitreihenlänge: `T = 250`
- Prädiktoren: `lag_1` bis `lag_30`
- Training: Zeitpunkte 31 bis 184 (`n = 154`)
- unabhängiger Test: Zeitpunkte 185 bis 250 (`n = 66`)
- Validierung: fünf lückenlose, zeitgerichtete Rolling-Origin-Splits
- Modelle: naive Baseline, OLS Lag 1, OLS Lag 30, Ridge Lag 30 und Lasso
  Lag 30
- Auswahl von `lambda`: ausschließlich innerhalb der Trainingsdaten
- Testmetriken: MSE, RMSE und MAE

## Zentrale Ergebnisse

| Modell         | Prädiktoren |     CV-MSE |  Test-RMSE |   Test-MAE |
|----------------|------------:|-----------:|-----------:|-----------:|
| Naive Baseline |           1 |     1.6887 |     1.2421 |     1.0282 |
| OLS Lag 1      |           1 | **1.5136** |     1.1852 |     0.9687 |
| OLS Lag 30     |          30 |     1.9112 |     1.1730 |     0.9468 |
| Ridge Lag 30   |          30 |     1.9630 |     1.1941 |     0.9647 |
| Lasso Lag 30   |           7 |     1.5572 | **1.1451** | **0.9284** |

Lasso erzielt auf dem unabhängigen Testzeitraum den niedrigsten RMSE und
MAE und setzt nur 7 von 30 Lag-Koeffizienten ungleich null. Der
Vorsprung gegenüber OLS mit 30 Lags ist vorhanden, aber moderat.
Gleichzeitig weist OLS Lag 1 den kleinsten Rolling-Origin-CV-MSE auf.
Die Cross-Validation hat Lasso in diesem Lauf daher nicht eindeutig als
bestes Modell ausgewählt; sie bevorzugt nach ihrem eigenen
Fehlerkriterium das einfachere Ein-Lag-Modell.

## Reproduzierbarer Ablauf

Die gesamte Analyse lässt sich aus einer leeren R-Sitzung mit einem
Befehl ausführen. Benötigt werden R sowie die Pakete `here` und
`glmnet`.

Plattformunabhängig:

``` bash
Rscript R/99_run_all.R
```

Unter Windows mit dem im Projekt verwendeten R:

``` powershell
& 'C:\Program Files\R\R-4.5.1\bin\Rscript.exe' R\99_run_all.R
```

Der feste Seed ist `20260716`. `R/99_run_all.R` prüft am Ende unter
anderem die Testzeilen, die Zeitrichtung der Rolling-Origin-Splits,
gültige Lambda-Werte und das Vorhandensein aller finalen Resultate.

## Projektstruktur

``` text
Machine-Learning2026/
|-- R/
|   |-- 01_simulate_dgp.R
|   |-- 02_create_lags.R
|   |-- 03_train_test_split.R
|   |-- 10_lasso_lag30.R
|   |-- 11_final_model_comparison.R
|   `-- 99_run_all.R
|-- results/
|   |-- lasso/
|   `-- final_comparison/
|-- docs/
|-- references/
|-- project_report.qmd
|-- project_report.html
|-- presentation.qmd
|-- presentation.html
`-- README.qmd
```

## Wichtige Dateien

- [`R/99_run_all.R`](R/99_run_all.R): zentraler reproduzierbarer
  Gesamtlauf.
- [`R/project_config.R`](R/project_config.R): Seed, Lag-Anzahl sowie
  Train-, Test- und CV-Konfiguration.
- [`R/10_lasso_lag30.R`](R/10_lasso_lag30.R): Lasso mit eigener
  zeitgerichteter Lambda-Auswahl.
- [`R/11_final_model_comparison.R`](R/11_final_model_comparison.R):
  finaler Vergleich aller fünf Modelle.
- [`results/final_comparison/model_comparison_metrics.csv`](results/final_comparison/model_comparison_metrics.csv):
  zentrale Ergebnistabelle.
- [`project_report.html`](project_report.html): vollständiger
  Projektbericht.
- [`presentation.html`](presentation.html): Präsentation für den
  15-minütigen Vortrag.

## Dokumentation

- [Vollständiger Projektbericht](project_report.html)
- [Quarto-Quelldatei des Berichts](project_report.qmd)
- [HTML-Präsentation](presentation.html)
- [Quarto-Quelldatei der Präsentation](presentation.qmd)
- [Persönlicher Projekt-Styleguide](docs/project_style_guide.md)
- [Stilvergleich mit
  SAE_WS25](docs/style_comparison_SAE_WS25_vs_Machine_Learning2026.md)
