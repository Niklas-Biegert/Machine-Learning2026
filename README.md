# Machine-Learning2026

Projekt fuer **Statistical Machine Learning, Thema 5**:
**Time Series Cross-Validation for Temporal Data**.

Ziel ist ein reproduzierbarer Vergleich verschiedener Cross-Validation-Verfahren fuer Forecasting-Modelle auf simulierten Zeitreihen. Untersucht werden AR-, MA- und ARMA-Prozesse sowie Szenarien mit Trend und Saisonalitaet.

## Forschungsfrage

Welche Cross-Validation-Methode liefert fuer zeitlich abhaengige Daten die zuverlaessigsten Fehlerschaetzungen und Modellentscheidungen?

## Methoden

- Daten-generierende Prozesse: AR, MA, ARMA, Trend, Saisonalitaet
- CV-Verfahren: k-fold, LOOCV, Rolling-Origin, Blocked CV, h-block CV
- Modelle: Lag-Regression, Ridge/Lasso, Tree-Based Methods
- Evaluation: Bias, Varianz, RMSE, Model-Selection Accuracy, Laufzeit
- Studiendesign: Monte-Carlo-Simulation

## Projektstruktur

```text
.
├── R/                         # R-Skripte fuer Experimente und Auswertung
├── data/
│   ├── raw/                   # externe Rohdaten, falls spaeter benoetigt
│   └── processed/             # generierte/aufbereitete Daten (nicht versioniert)
├── docs/                      # Theorie- und Methodennotizen
├── experiments/               # reproduzierbare Experiment-Konfigurationen
├── notebooks/                 # explorative Analysen
├── project_management/        # Zeitplan, Aufgaben, Entscheidungen
├── references/
│   ├── slides/                # relevante Kursfolien/PDFs
│   └── project_overview/      # Projektbilder und Skizzen
├── reports/
│   ├── paper/                 # Hausarbeit / Quarto-Report
│   ├── presentation/          # Praesentation
│   └── figures/               # finale Abbildungen
├── src/
│   ├── cv_methods/            # Implementierung der CV-Splits
│   ├── data_generating_processes/
│   ├── evaluation/
│   └── models/
└── tests/                     # Tests fuer zentrale Funktionen
```

## Schnellstart

Python:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
pytest
```

R:

```r
source("R/00_setup.R")
```

## Naechste Schritte

1. Studiendesign finalisieren: DGPs, Stichprobengroessen, Anzahl Monte-Carlo-Runs.
2. CV-Splitter implementieren und mit kleinen Tests pruefen.
3. Baseline-Modelle fuer Lag-Regression, Ridge/Lasso und Tree-Based Methods definieren.
4. Einen kleinen Testlauf mit wenigen Simulationen ausfuehren.
5. Danach Hauptsimulationen starten und Ergebnisse in `reports/figures/` speichern.
