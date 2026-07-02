# Core Concepts

## Statistical Learning

Statistical Learning verbindet Statistik und Machine Learning. Ziel ist es, aus Daten Muster zu lernen und damit neue Beobachtungen zu erklaeren oder vorherzusagen.

## Supervised Learning

Beim supervised learning gibt es Eingaben `X` und bekannte Zielwerte `y`.

- Regression: Zielwert ist numerisch, zum Beispiel `final_score`.
- Klassifikation: Zielwert ist eine Klasse, zum Beispiel `passed`.

## Unsupervised Learning

Beim unsupervised learning gibt es keine Zielvariable. Typische Aufgaben sind:

- Gruppen in Daten finden
- Dimensionen reduzieren
- Datenstruktur sichtbar machen

## Bias-Variance Tradeoff

- Hoher Bias: Modell ist zu einfach und underfittet.
- Hohe Varianz: Modell ist zu flexibel und overfittet.
- Gute Modelle balancieren beide Fehlerquellen.

## Cross-Validation

Cross-Validation schaetzt, wie gut ein Modell auf neuen Daten funktionieren wird. Dabei wird der Datensatz mehrfach in Trainings- und Validierungsteile geteilt.
