# Persönlicher Projektstil für R- und Quarto-Projekte

## 1. Hauptordner

Bevorzugt werden wenige, eindeutig benannte Hauptordner:

- `R/` oder `syntax/` für nummerierte Analyseschritte
- `data/` beziehungsweise `data_raw/` für Eingabedaten
- `results/` beziehungsweise `output/` für erzeugte Resultate
- `docs/` für methodische und technische Begleitdokumente
- `references/` oder `information/` für externe Unterlagen
- `presentation/` nur dann, wenn mehrere Präsentationsdateien verwaltet werden

Für neue reproduzierbare Projekte sind `R/` und `results/` zu bevorzugen. Bestehende Projekte werden nicht allein aus optischen Gründen umbenannt.

## 2. Unterordner

Ergebnisse werden nach Funktion getrennt:

```text
results/
|-- figures/
|-- tables/
|-- models/
|-- logs/
`-- archive/
```

Modellspezifische Unterordner sind sinnvoll, wenn ein Modell mehrere Tabellen, Grafiken und gespeicherte Objekte erzeugt.

## 3. Dateibenennung

- Analyseschritte beginnen zweistellig: `01_`, `02_`, ..., `99_`.
- Dateinamen sind kurz, beschreibend und in `snake_case`.
- `99_` kennzeichnet einen Gesamtlauf oder einen abschließenden Hilfsschritt.
- Explorative Varianten erhalten einen eindeutigen Zusatz wie `_exploratory` oder liegen in `scratch/`.
- Finale Resultate tragen stabile, inhaltliche Namen statt Datums- oder Versionssuffixen.

## 4. Nummerierung von R-Skripten

Die Reihenfolge folgt dem Datenfluss:

1. Daten erzeugen oder einlesen
2. Variablen konstruieren
3. Aufteilung und Validierungsdesign
4. Modelle und Hilfsfunktionen
5. Auswertung und Grafiken
6. Export und Interpretation
7. finaler Vergleich
8. `99_run_all.R`

## 5. Skript-Header

Jedes zentrale Skript beginnt mit Projekt, Datei und Zweck:

```r
###############################################################################
# Projekt: Kurzer Projektname
# Datei: R/01_example.R
#
# Zweck:
# Ein Satz zum fachlichen oder technischen Ziel.
###############################################################################
```

Methodische Leitplanken stehen nur dort im Header, wo sie für das gesamte Skript gelten.

## 6. Abschnittstrenner

Hauptabschnitte werden nummeriert und mit demselben Trenner markiert. Kleine Unterabschnitte benötigen keinen dekorativen Block. Die Nummerierung soll den tatsächlichen Ablauf zeigen.

## 7. Kommentarstil

- Kommentare erklären den Grund, nicht die offensichtliche Syntax.
- Kritische Annahmen und Leakage-Risiken werden direkt am betreffenden Code genannt.
- Kurze Kontrollschritte dürfen mit `# Quick checks` oder `# Kontrolle` angekündigt werden.
- Veraltete Alternativimplementierungen werden nicht dauerhaft als große auskommentierte Blöcke mitgeführt.

## 8. Funktionsnamen

Funktionsnamen verwenden Verben und `snake_case`, zum Beispiel `create_lag_features()`, `fit_lasso_model()` oder `run_final_model_comparison()`.

## 9. Variablennamen

- `snake_case` für Objekte und Spalten
- `X_train`, `X_test`, `y_train`, `y_test` für Modellmatrizen und Zielvektoren
- `*_table`, `*_metrics`, `*_splits` für tabellarische Resultate
- keine generischen Namen wie `tmp` oder `list`, außer für sehr lokale Zwischenschritte

## 10. Pfadverwaltung

- nur relative Pfade
- in reproduzierbaren Projekten bevorzugt `here::here()`
- innerhalb eines bereits bestimmten Ausgabeordners `file.path()`
- keine benutzerspezifischen Windows-Pfade im ausführbaren Code

## 11. README-Struktur

1. Projekttitel und kurze Einordnung
2. Ziel und Forschungsfrage
3. Vorgehen
4. wichtigste Ergebnisse
5. reproduzierbarer Aufruf
6. Projektstruktur
7. zentrale Dateien und Dokumentation

Die README bleibt deutlich kürzer als der Bericht und beantwortet zuerst, was untersucht wurde, wie es ausgeführt wird und wo die Resultate liegen.

## 12. Berichtsgliederung

Der Bericht folgt der Logik Ziel - Methode - Daten/Simulation - Ergebnisse - Diskussion - Limitationen - Fazit. Erklärender Text steht vor Code und Tabellen. Technische Details, die für das Verständnis nötig sind, bleiben im Haupttext; reine Kontrollausgaben können eingeklappt werden.

## 13. Präsentationslogik

Die Präsentation beginnt mit der konkreten Frage und führt dann über Problem, Design, Modelle und Resultate zur Empfehlung. Eine Schlussfolie trennt Kernaussage und Grenzen. Backup-Folien enthalten technische Details, die für Rückfragen hilfreich sind.

## 14. Bevorzugtes Quarto-YAML

- `lang: de`
- Inhaltsverzeichnis und nummerierte Abschnitte für längere Berichte
- `code-fold: true`, wenn Code zur Nachvollziehbarkeit gezeigt wird
- ein ruhiges Bootstrap-Theme wie `flatly` oder ein vergleichbares eigenes SCSS
- feste Figurenbreite und aussagekräftige Captions

## 15. Farben

Die wiederkehrende Palette ist zurückhaltend und kontrastreich:

| Rolle | Farbe |
|---|---|
| Dunkelblau | `#0B4F7D` |
| dunkler Text | `#24303B` |
| Türkis | `#22A6B3` |
| gedämpftes Grün | `#7CA982` |
| Koralle | `#F05425` |
| Gelb als seltener Akzent | `#FACC15` |
| heller Hintergrund | `#F7F9FA` |

Koralle und Gelb werden sparsam für Hervorhebungen eingesetzt, nicht als flächiger Hintergrund.

## 16. Plot-Theme

- weißer Hintergrund
- `theme_minimal()` oder `theme_classic()` als Ausgangspunkt
- wenige, konsistente Farben
- keine dekorativen Rahmen oder Schatten
- klare Achsentitel, dezente Gitternetzlinien und kompakte Legenden
- Titel beschreiben die Aussage der Grafik, nicht nur den Diagrammtyp

Eine zentrale Funktion `theme_project()` ist sinnvoll, sobald mehrere Grafiken neu erzeugt werden. In abgeschlossenen Analysen wird sie nicht nachträglich eingeführt, wenn dadurch finale Resultate unnötig neu geschrieben werden müssten.

## 17. Tabellenformatierung

- Rohdateien behalten volle Genauigkeit
- im Bericht drei bis vier Dezimalstellen, abhängig von der Metrik
- sprechende deutsche Spaltennamen in der Darstellung
- rechtsbündige Zahlen und kurze Captions
- beste Werte gezielt hervorheben, ohne jede Zelle farbig zu formatieren

## 18. Sprache und Ton

Die Sprache ist sachlich, verständlich und direkt. Fachbegriffe werden verwendet, aber beim ersten Auftreten erklärt. Der Ton entspricht einer sorgfältigen Masterarbeit: professionell, ohne unnötig steife Formulierungen oder pauschale Überlegenheitsaussagen.

## 19. Paketerklärungen

Nur tatsächlich verwendete Pakete werden erklärt. Für jedes zentrale Paket werden Zweck, wichtige Funktionen, Eignung und eine mögliche Alternative genannt. Base-R-Funktionen werden nicht künstlich als zusätzliche Abhängigkeit dargestellt.

## 20. Methodische Begründungen

Entscheidungen werden an der Forschungsfrage ausgerichtet. Besonders Auswahl von Datenfenstern, Validierung, Standardisierung und Hyperparameterwahl benötigen eine kurze Begründung. Erkannte Fehlansätze werden mit Problem und Korrektur dokumentiert.

## 21. Ergebnisse und Limitationen

Ergebnisse werden mit konkreten Kennzahlen beschrieben und anschließend vorsichtig eingeordnet. Kleine Unterschiede gelten nicht automatisch als praktisch relevant. Limitationen nennen offen, welche Generalisierung durch Simulation, Stichprobengröße oder Validierungsdesign nicht gedeckt ist.

## 22. Reproduzierbarkeitsstruktur

- zentrale Konfiguration
- fester Seed
- ein ausführbarer Gesamtlauf
- explizite Paketprüfung
- automatisch erzeugte Ergebnisordner
- maschinenlesbare Tabellen und Logs
- Quarto liest gespeicherte Resultate ein, schätzt aber keine Modelle neu
- automatische Checks für zentrale methodische Garantien
