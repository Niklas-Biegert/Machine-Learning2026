# Experiments

Hier liegen reproduzierbare Experiment-Konfigurationen und spaeter die Ergebnisse.

Vorschlag fuer den ersten Testlauf:

- `T = 250`
- `T_train = 175`
- `T_test = 75`
- `R = 20` fuer einen schnellen Smoke-Test
- danach `R = 500` fuer die Hauptsimulation
- Lags: `p in {1, 2, 5, 10}`
- h-block: `h in {1, 5, 10}`

Speichere grosse Ergebnisdateien unter `experiments/results/`; dieser Ordner ist in `.gitignore` ausgeschlossen.
