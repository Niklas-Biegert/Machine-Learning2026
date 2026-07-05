# Machine-Learning2026

Projekt fuer **Statistical Machine Learning** zum Thema:

**Time Series Cross-Validation for Temporal Data**

## Projektziel

Ziel des Projekts ist ein reproduzierbarer Vergleich verschiedener Cross-Validation-Verfahren fuer Forecasting-Aufgaben mit zeitlich abhaengigen Daten. Dafuer wurde eine Monte-Carlo-Simulation mit **500 Wiederholungen pro daten-generierendem Prozess (DGP)** durchgefuehrt.

Untersucht werden drei simulierte Zeitreihenprozesse:

- AR(1)
- MA(1)
- ARMA(1,1)

Verglichen werden fuenf Cross-Validation-Methoden:

- k-fold Cross-Validation
- Leave-One-Out Cross-Validation (LOOCV)
- Rolling-origin Cross-Validation
- Blocked Cross-Validation
- h-block Cross-Validation

Als Forecasting-Modelle werden zwei lineare Lag-Modelle verwendet:

- `LM-lag1`
- `LM-lag5`

Die zentrale Frage ist, welche CV-Methode den spaeteren Hold-out-Testfehler am verlaesslichsten schaetzt und dadurch robuste Modellentscheidungen ermoeglicht.

## Ordnerstruktur

```text
.
|-- R/                         # R-Skripte fuer Simulation, CV, Modelle, Plots und Tabellen
|-- data/                      # optionale Rohdaten oder verarbeitete Daten
|-- docs/                      # Notizen, Theorieuebersicht und LaTeX/PDF-Uebersicht
|-- experiments/               # Experimentnotizen und Konfigurationen
|-- notebooks/                 # explorative Analysen
|-- project_management/        # Projektplan und organisatorische Notizen
|-- references/                # Vorlesungsfolien und Projektmaterial
|-- reports/                   # Entwuerfe fuer Paper und Praesentation
|-- results/
|   |-- figures/               # finale Plots fuer Bericht und Praesentation
|   `-- tables/                # finale Ergebnistabellen und gespeicherte Simulationsergebnisse
|-- src/                       # ggf. wiederverwendbarer Code
|-- tests/                     # Tests
|-- paper.qmd                  # Quarto-Bericht fuer die Abgabe
`-- README.md                  # Projektuebersicht und Ausfuehrungsanleitung
```

## Reihenfolge zum Ausfuehren der Skripte

Die Skripte sind nummeriert und sollten in dieser Reihenfolge ausgefuehrt werden:

```r
source("R/00_setup.R")
source("R/01_simulate_dgp.R")
source("R/02_create_lags.R")
source("R/03_train_test_split.R")
source("R/04_models.R")
source("R/05_cv_methods.R")
source("R/06_monte_carlo.R")
source("R/07_plots.R")
source("R/08_tables_and_interpretation.R")
```

Optional bzw. fuer den Bericht:

```r
rmarkdown::render("R/09_export_tables_for_report.Rmd")
```

Der Quarto-Bericht kann anschliessend gerendert werden mit:

```bash
quarto render paper.qmd
```

Hinweis: Die Monte-Carlo-Simulation ist der zeitaufwendigste Schritt. Fuer die Abgabe muessen die Simulationen nicht jedes Mal neu gerechnet werden, wenn die Ergebnisse bereits in `results/tables/` und `results/figures/` gespeichert sind.

## Wichtigste Dateien

### R-Skripte

- `R/00_setup.R`: laedt benoetigte Pakete und zentrale Einstellungen.
- `R/01_simulate_dgp.R`: definiert die daten-generierenden Prozesse AR(1), MA(1) und ARMA(1,1).
- `R/02_create_lags.R`: erzeugt Lag-Features fuer die Forecasting-Modelle.
- `R/03_train_test_split.R`: erstellt zeitlich geordnete Train-Test-Splits.
- `R/04_models.R`: definiert die Modelle `LM-lag1` und `LM-lag5`.
- `R/05_cv_methods.R`: implementiert k-fold, LOOCV, rolling-origin, blocked CV und h-block CV.
- `R/06_monte_carlo.R`: fuehrt die Monte-Carlo-Simulationen aus.
- `R/07_plots.R`: erstellt die finalen Abbildungen.
- `R/08_tables_and_interpretation.R`: erzeugt finale Tabellen und Ergebniszusammenfassungen.
- `R/09_export_tables_for_report.Rmd`: exportiert bzw. dokumentiert Tabellen fuer den Bericht.

### Bericht und Dokumentation

- `paper.qmd`: Quarto-Bericht mit Introduction, Methodology, Simulation Design, Results, Discussion, Limitations und Conclusion.
- `docs/thema_05_latex_uebersicht.tex`: LaTeX-Uebersicht mit Definitionen und Vorgehen.
- `docs/thema_05_latex_uebersicht.pdf`: PDF-Version der Theorie- und Vorgehensuebersicht.

### Ergebnisse

Wichtige Tabellen in `results/tables/`:

- `summary_table_final.csv`
- `bias_sd_table_final.csv`
- `model_selection_table_final.csv`
- `best_bias_table_final.csv`

Wichtige Plots in `results/figures/`:

- `plot_bias_mean.png`
- `plot_bias_boxplot.png`
- `plot_test_error.png`
- `plot_model_selection.png`

## Kurzinterpretation

In den finalen Ergebnissen liegen **h-block CV** und **LOOCV** in mehreren DGPs am naechsten bei Bias 0. **Rolling-origin CV** zeigt in diesem konkreten Setup einen staerkeren negativen Bias und eine hoehere Bias-Streuung. Dieses Ergebnis sollte vorsichtig interpretiert werden, weil rolling-origin CV stark von der Wahl von Forecast-Horizon, Step-Size und Validierungsfenster abhaengt.
