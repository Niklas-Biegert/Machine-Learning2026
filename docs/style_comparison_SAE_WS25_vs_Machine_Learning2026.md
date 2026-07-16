# Stilvergleich: SAE_WS25 und Machine-Learning2026

## Ziel des Vergleichs

`SAE_WS25` dient ausschließlich als persönliche strukturelle und gestalterische Referenz. Fachliche Inhalte, Daten, Modelle und Formulierungen werden nicht übernommen. Der Vergleich konzentriert sich darauf, welche wiederkehrenden Arbeitsweisen als persönlicher Projektstil erkennbar sind und welche davon ohne Risiko auf `Machine-Learning2026` übertragbar sind.

## Typische Merkmale von SAE_WS25

### Struktur und Dateibenennung

- wenige, direkt verständliche Hauptordner: `data_raw/`, `syntax/`, `output/`, `presentation/` und `information/`
- nummerierte Analyseschritte wie `01-preprocessing.Rmd`, `02-processing.Rmd` und `03-sampling_frame.Rmd`
- Ergänzungen werden mit Zusätzen wie `exA`, `exB` oder `exp` markiert
- Ergebnisse und Präsentationsmaterial sind klar von der Analysesyntax getrennt
- relative Pfade statt benutzerspezifischer absoluter Pfade

### Aufbau von Analyse-Dateien

- kurze YAML-Köpfe mit Titel, Autor, Inhaltsverzeichnis und einem zurückhaltenden Bootstrap-Theme
- nachvollziehbare Abfolge: Ziel, Pakete, Pfade, Daten, Verarbeitung, Modell, Diagnostik und Export
- erklärender Text steht unmittelbar vor dem zugehörigen Code
- Abschnitte sind handlungsorientiert und häufig nummeriert
- Kommentare sind knapp, praktisch und begründen besonders kritische Entscheidungen
- Zwischenstände werden mit `summary()`, `table()`, `class()` oder `stopifnot()` kontrolliert

### R-Stil

- Mischung aus Base R, `data.table` und tidyverse, abhängig vom Arbeitsschritt
- zentrale `library()`-Blöcke am Anfang eines Dokuments
- `package::function` vor allem dort, wo eine Funktion mehrdeutig ist oder die Herkunft wichtig ist
- Objektnamen sind beschreibend, überwiegend in `snake_case`
- wiederverwendete Darstellungslogik wird in kleine Funktionen oder Theme-Objekte ausgelagert

### Ergebnisdarstellung

- weiße oder transparente Hintergründe mit viel freier Fläche
- häufig `theme_minimal()` oder `theme_classic()`
- wiederkehrende Akzente in Dunkelblau, Türkis, gedämpftem Grün, Koralle und Gelb
- vergleichende Grafiken mit direkter Beschriftung, kleinen Legenden und klaren Achsentiteln
- Exporte häufig als PNG und SVG; Tabellen werden im Analysekontext kompakt dargestellt

### Sprache und methodische Einordnung

- sachlich, direkt und nicht unnötig formal
- Methoden werden über den konkreten Zweck im Projekt erklärt
- Probleme und Korrekturen werden offen dokumentiert, etwa mögliche Informationsleckage oder ungeeignete Variablen
- Limitationen werden als reale Grenzen der Aussagekraft formuliert

## Aktueller Aufbau von Machine-Learning2026

`Machine-Learning2026` ist stärker als reproduzierbare Analysepipeline organisiert. Die Hauptlogik liegt in `R/`, zentrale Parameter in `R/project_config.R`, Resultate in `results/` und die Dokumentation in Quarto-Dateien. `R/99_run_all.R` führt die finale Analyse aus einer leeren R-Sitzung aus und validiert die erzeugten Ergebnisse.

Die R-Skripte sind bereits nummeriert und besitzen konsistente Header, Abschnittstrenner, klare Fehlermeldungen sowie relative Pfade mit `here()`. Bericht und Präsentation lesen gespeicherte Resultate ein; Modellberechnung und Darstellung sind damit sauber getrennt.

## Gemeinsamkeiten

- nummerierte Analyseschritte
- relative Projektpfade
- beschreibende Objektnamen
- erklärender Text nahe am Code
- sichtbare Plausibilitäts- und Validierungschecks
- getrennte Ordner für Daten, Analyse, Ergebnisse und Präsentation
- klare Dokumentation methodischer Entscheidungen und Limitationen
- zurückhaltende Diagramme mit wenigen Akzentfarben

## Unterschiede

| Bereich | SAE_WS25 | Machine-Learning2026 | Bewertung |
|---|---|---|---|
| Hauptsyntax | überwiegend R Markdown in `syntax/` | modulare R-Skripte in `R/` | Unterschied ist durch die Projektart begründet |
| Ergebnisse | breiter Sammelordner `output/` | fachlich gegliederte Unterordner in `results/` | aktuelle Lösung ist reproduzierbarer |
| Konfiguration | Parameter meist in einzelnen Dokumenten | zentrale Konfiguration | aktuelle Lösung beibehalten |
| README | nur sehr knapp ausgeprägt | ausführliche Projektübersicht | aktuelle README ist für Abgabe und GitHub sinnvoller |
| Bericht | mehrere Arbeitsdokumente | ein konsolidierter Quarto-Bericht | aktuelle Lösung beibehalten |
| Präsentation | visuell dichter Poster-/Folienstil | lineare 15-Minuten-Präsentation | Dramaturgie angleichen, Dichte nicht kopieren |
| Plot-Erzeugung | überwiegend ggplot2 mit zentralen Farben | Monte-Carlo-Plots mit ggplot2, finaler Vergleich mit Base R | keine Neuberechnung nur aus Stilgründen |
| Reproduzierbarkeit | eher dokumentzentriert | zentraler Clean Run mit Checks | aktuelle Lösung ist stärker |

## Konkrete Änderungsvorschläge

| Priorität | Änderung | Risiko | Betroffene Dateien |
|---|---|---|---|
| erforderlich | Vergleich, Styleguide und Migrationsentscheidungen dokumentieren | niedrig | `docs/` |
| erforderlich | bestehende Quarto-Dokumente nur gezielt überarbeiten und wichtige Methodenbegründungen erhalten | niedrig | `README.qmd`, `README.md`, `project_report.qmd`, `presentation.qmd` |
| sinnvoll | deutsche, handlungsorientierte Abschnittstitel und knappere Einleitung in der README | niedrig | `README.qmd`, `README.md` |
| sinnvoll | visuelle Palette auf Dunkelblau, Türkis, Grün und Koralle vereinheitlichen | niedrig | `styles.scss`, `presentation.scss` |
| sinnvoll | Bericht und Präsentation stärker entlang Ziel - Vorgehen - Ergebnis - Grenzen ordnen | niedrig | `project_report.qmd`, `presentation.qmd` |
| sinnvoll | Autor und institutionellen Kontext in den Quarto-Metadaten konsistent halten | niedrig | Quarto-Quelldateien |
| optional | zentrale Plotfunktion `theme_project()` ergänzen | mittel | R-Plot-Skripte und Grafiken |
| optional | zusätzliche SVG-Exporte erzeugen | mittel | R-Plot-Skripte, Ergebnisordner |
| nicht empfohlen | `R/` in `syntax/` und `results/` in `output/` umbenennen | hoch | alle Analyse- und Dokumentpfade |
| nicht empfohlen | `project_config.R` in `00_config.R` umbenennen | mittel | mehrere `source()`-Aufrufe und Dokumentlinks |
| nicht empfohlen | finale Berichte in neue Unterordner verschieben | mittel | README, Quarto, GitHub-Links |

## Risikobewertung

Die größten Risiken entstehen durch Pfadänderungen in der reproduzierbaren Pipeline. Da die aktuelle Struktur technisch konsistenter ist als das ältere Referenzprojekt, wird der persönliche Fingerabdruck vor allem über Benennung, Abschnittslogik, Ton und visuelle Gestaltung übertragen. Modellcode und Resultatpfade bleiben unverändert.
