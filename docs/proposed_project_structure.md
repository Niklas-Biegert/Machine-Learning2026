# Vorgeschlagene finale Projektstruktur

## Entscheidung

Die bestehende technische Struktur bleibt erhalten. Sie überträgt die klare Trennung aus `SAE_WS25`, ist für eine reproduzierbare Skriptpipeline aber konsistenter als eine wörtliche Umbenennung in `syntax/` und `output/`.

```text
Machine-Learning2026/
|-- R/
|   |-- 01_simulate_dgp.R
|   |-- 02_create_lags.R
|   |-- 03_train_test_split.R
|   |-- 04_models.R
|   |-- 05_cv_methods.R
|   |-- 06_monte_carlo.R
|   |-- 07_plots.R
|   |-- 08_tables_and_interpretation.R
|   |-- 10_lasso_lag30.R
|   |-- 11_final_model_comparison.R
|   |-- 99_run_all.R
|   |-- project_config.R
|   `-- scratch/
|-- data/
|-- docs/
|   |-- style_comparison_SAE_WS25_vs_Machine_Learning2026.md
|   |-- project_style_guide.md
|   |-- project_restructure_plan.csv
|   `-- proposed_project_structure.md
|-- references/
|-- results/
|   |-- figures/
|   |-- tables/
|   |-- lasso/
|   |   |-- figures/
|   |   |-- tables/
|   |   |-- models/
|   |   `-- previous_blocked_cv/
|   `-- final_comparison/
|       |-- figures/
|       |-- tables/
|       `-- models/
|-- README.qmd
|-- README.md
|-- project_report.qmd
|-- project_report.html
|-- presentation.qmd
|-- presentation.html
|-- styles.scss
|-- presentation.scss
`-- _quarto.yml
```

## Bewusst unveränderte Pfade

- `R/` bleibt der Ort der ausführbaren Analyse. Die Bezeichnung ist für ein Skriptprojekt eindeutiger als `syntax/`.
- `results/` bleibt bestehen, weil Tabellen, Grafiken und Modelle bereits sauber getrennt sind.
- Bericht und Präsentation bleiben im Projektstamm, damit GitHub-Links und die Renderbefehle kurz und stabil bleiben.
- `R/project_config.R` bleibt unverändert benannt. Die Datei ist eine gemeinsame Konfiguration und kein erster ausführbarer Analyseschritt.
- `results/lasso/previous_blocked_cv/` bleibt als klar benanntes Audit-Archiv erhalten und wird nicht als Input verwendet.

## Neue Dokumentation

Die vier neuen Dateien unter `docs/` machen die Stilentscheidungen nachvollziehbar, ohne den funktionierenden Datenfluss umzubauen. Es werden keine finalen Ergebnisse gelöscht, verschoben oder neu benannt.
