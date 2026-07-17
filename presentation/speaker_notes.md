# Speaker Notes

## Folie: Motivation

Zuständig: Niklas

Kernaussage: Bei Zeitreihen ist die Reihenfolge Teil der Datenstruktur.

Sprechtext: Bei unabhängigen Daten ist eine zufällige Aufteilung oft unproblematisch. Bei Zeitreihen kann dadurch aber Zukunftsinformation in das Training geraten. Deshalb schauen wir uns an, wie verschiedene CV-Verfahren den späteren Prognosefehler schätzen.

Mögliche Rückfrage: Warum ist Zukunftsinformation problematisch?

Kurze Antwort: Weil sie in einer echten Prognosesituation noch nicht verfügbar wäre und den CV-Fehler zu optimistisch machen kann.

## Folie: Forschungsfrage

Zuständig: Niklas

Kernaussage: Verglichen werden vier CV-Methoden auf fünf Zeitreihenstrukturen.

Sprechtext: Die Hauptfrage ist nicht, welches Modell grundsätzlich am besten ist. Wir halten das Modell bewusst konstant und untersuchen, wie gut die CV-Verfahren den zukünftigen Testfehler annähern.

Mögliche Rückfrage: Warum wird der Testfehler als Referenz verwendet?

Kurze Antwort: Der Testzeitraum liegt später als das Training und imitiert dadurch die spätere Prognosesituation.

## Folie: Fünf Zeitreihenstrukturen

Zuständig: Alex

Kernaussage: Die DGPs bilden unterschiedliche Formen zeitlicher Abhängigkeit ab.

Sprechtext: AR, MA und ARMA sind stationäre Prozesse mit kurzfristiger Abhängigkeit. Trend und saisonale Zeitreihe bringen nichtstationäre beziehungsweise periodische Struktur hinein. So sieht man, ob ein Verfahren nur in einem einfachen Fall gut funktioniert oder über mehrere Strukturen hinweg stabil bleibt.

Mögliche Rückfrage: Warum keine realen Daten?

Kurze Antwort: Simulierte Daten erlauben eine kontrollierte Umgebung, in der die wahre Struktur bekannt ist und viele Wiederholungen möglich sind.

## Folie: Gemeinsames Modell

Zuständig: Niklas

Kernaussage: Dasselbe Lag-Modell isoliert den Einfluss der CV-Methode.

Sprechtext: Das lineare Modell mit fünf Lags ist nicht für jeden DGP optimal. Gerade bei der saisonalen Zeitreihe fehlt lag 12. Für diese Studie ist aber wichtig, dass alle CV-Methoden unter denselben Modellbedingungen verglichen werden.

Mögliche Rückfrage: Ist das saisonale Modell dadurch falsch?

Kurze Antwort: Es ist bewusst nicht vollständig spezialisiert. Das ist eine Limitation, betrifft aber alle CV-Methoden gleich.

## Folie: Train-Test-Design

Zuständig: Alex

Kernaussage: Der Testzeitraum liegt vollständig nach dem Training.

Sprechtext: Trainiert wird auf den Zeitpunkten 31 bis 184, getestet auf 185 bis 250. Der Testzeitraum geht nicht in die CV ein. Der Start bei 31 passt außerdem zur zusätzlichen Lag-30-Fallstudie.

Mögliche Rückfrage: Warum beginnt Training nicht bei 1?

Kurze Antwort: Durch Lag-Features gehen Anfangsbeobachtungen verloren; für die Lag-30-Fallstudie wird ein konsistenter Start ab Zeitpunkt 31 verwendet.

## Folie: Vier CV-Verfahren

Zuständig: Alex

Kernaussage: Die Methoden unterscheiden sich in ihrer zeitlichen Logik.

Sprechtext: k-fold mischt zufällig, blocked nutzt zusammenhängende Blöcke, h-block entfernt zusätzlich einen Puffer und rolling-origin trainiert nur auf vergangenen Daten. Dadurch werden klassische und stärker zeitgerichtete Ansätze vergleichbar.

Mögliche Rückfrage: Ist blocked CV zeitlich sauber?

Kurze Antwort: Nicht vollständig. Die Validierungsblöcke sind zusammenhängend, aber spätere Beobachtungen können trotzdem im Training liegen.

## Folie: Monte-Carlo-Design

Zuständig: Alex

Kernaussage: 4.000 Ergebniszeilen entstehen aus 5 DGPs, 200 Wiederholungen und 4 Methoden.

Sprechtext: Eine einzelne simulierte Zeitreihe könnte zufällig besonders günstig oder ungünstig sein. Deshalb werden pro DGP 200 Wiederholungen verwendet. Innerhalb einer Simulation erhalten alle CV-Methoden dieselbe Zeitreihe.

Mögliche Rückfrage: Warum reichen 200 Wiederholungen?

Kurze Antwort: 200 ist ein praktikabler Kompromiss zwischen stabilerer Schätzung und Rechenzeit für ein Kursprojekt.

## Folie: Bewertungslogik

Zuständig: Alex

Kernaussage: Bewertet wird die Differenz zwischen CV-MSE und Test-MSE.

Sprechtext: Der Schätzfehler ist CV-MSE minus Test-MSE. Negative Werte sind optimistisch, positive pessimistisch. Bias zeigt den mittleren Fehler, RMSE und Varianz zeigen zusätzlich, wie stark die Methode schwankt.

Mögliche Rückfrage: Warum reicht Bias nicht?

Kurze Antwort: Eine Methode kann im Mittel gut liegen, aber zwischen Simulationen stark variieren. Dann ist sie praktisch weniger zuverlässig.

## Folie: Bias-Ergebnisse

Zuständig: Nils

Kernaussage: Die Bias-Rangfolge hängt vom DGP ab.

Sprechtext: Rolling-origin ist beim Trend-Bias stark, blocked beim saisonalen Bias. Bei ARMA liegt k-fold numerisch nah am Testfehler. Das bedeutet aber nicht, dass k-fold zeitlich korrekt wäre.

Mögliche Rückfrage: Warum kann k-fold trotzdem gut abschneiden?

Kurze Antwort: In einfachen stationären Szenarien kann die numerische Fehlerschätzung nahe am Testfehler liegen, obwohl die Splitlogik theoretisch problematisch bleibt.

## Folie: RMSE der Fehlerschätzung

Zuständig: Nils

Kernaussage: RMSE bewertet die gesamte Abweichung vom Testfehler.

Sprechtext: RMSE bestraft größere Schätzfehler stärker als der reine Bias. Dadurch kann ein Verfahren mit gutem Bias trotzdem schlechter abschneiden, wenn es stark schwankt.

Mögliche Rückfrage: Warum gewinnt nicht immer rolling-origin?

Kurze Antwort: Rolling-origin ist zeitlich sauber, nutzt aber weniger und teilweise kleinere Trainingsfenster, was die Schätzung variabler machen kann.

## Folie: Varianz der Schätzfehler

Zuständig: Nils

Kernaussage: Stabilität ist ein eigenes Bewertungskriterium.

Sprechtext: Die Varianz zeigt, ob die Fehlerschätzung von Simulation zu Simulation stark schwankt. Für praktische Modellwahl ist eine stabile Methode oft leichter zu interpretieren als eine Methode, die nur im Mittel gut ist.

Mögliche Rückfrage: Ist kleine Varianz immer besser?

Kurze Antwort: Nicht allein. Eine Methode kann stabil, aber systematisch verzerrt sein. Deshalb betrachten wir Bias, RMSE und Varianz zusammen.

## Folie: Ergebnisrangfolge

Zuständig: Nils

Kernaussage: Es gibt keinen universellen Gewinner.

Sprechtext: Die Tabelle zeigt die besten Methoden je DGP und Kriterium. Dass die Einträge wechseln, ist ein zentrales Ergebnis der Studie. Die geeignete Methode hängt von Datenstruktur und Bewertungskriterium ab.

Mögliche Rückfrage: Welche Methode würden Sie empfehlen?

Kurze Antwort: Für echte Prognoseprobleme ist rolling-origin methodisch am plausibelsten, aber die Simulation zeigt, dass Genauigkeit und Stabilität je nach Struktur abweichen können.

## Folie: Interpretation

Zuständig: Nils

Kernaussage: Numerische Ergebnisse müssen methodisch eingeordnet werden.

Sprechtext: Ein numerisch gutes Ergebnis bedeutet nicht automatisch, dass ein Verfahren konzeptionell korrekt ist. Besonders k-fold bleibt für Zeitreihen kritisch, auch wenn es im ARMA-Szenario gut abschneidet.

Mögliche Rückfrage: Was ist die wichtigste praktische Lehre?

Kurze Antwort: Die Validierungsmethode sollte zur späteren Prognosesituation passen und nicht nur nach einem einzelnen Kennwert gewählt werden.

## Folie: Zusätzliche ARMA-Fallstudie

Zuständig: Nils

Kernaussage: Lasso ist in dieser konkreten Fallstudie am besten, aber nicht allgemein überlegen.

Sprechtext: Die Zusatzanalyse vergleicht Baseline, OLS, Ridge und Lasso mit bis zu 30 Lags. Lasso wählt nur einige aktive Lags und erreicht hier den kleinsten Testfehler. Das ist eine Ergänzung, nicht die Hauptfrage.

Mögliche Rückfrage: Was macht Lasso anders als Ridge?

Kurze Antwort: Ridge schrumpft Koeffizienten, Lasso kann Koeffizienten exakt auf null setzen und dadurch Variablen auswählen.

## Folie: Limitationen

Zuständig: Nils

Kernaussage: Die Studie ist kontrolliert, aber nicht vollständig allgemein.

Sprechtext: Wir nutzen einfache simulierte DGPs und ein einheitliches lineares Modell. Das macht den Methodenvergleich sauber, ersetzt aber keine Analyse realer Daten mit Strukturbrüchen, Ausreißern oder komplexerer Saisonalität.

Mögliche Rückfrage: Was wäre ein nächster Schritt?

Kurze Antwort: Weitere DGPs, reale Zeitreihen und alternative Modelle wie ARIMA oder nichtlineare Verfahren wären sinnvolle Erweiterungen.

## Folie: Fazit

Zuständig: Niklas

Kernaussage: Die passende CV-Methode hängt von Ziel und Zeitreihenstruktur ab.

Sprechtext: Rolling-origin ist zeitlich am plausibelsten, blocked und h-block können aber in bestimmten Kriterien stabiler sein. Die wichtigste Aussage ist deshalb nicht, dass eine Methode immer gewinnt, sondern dass Zeitrichtung, Bias und Streuung gemeinsam betrachtet werden müssen.

Mögliche Rückfrage: Was nehmen Sie persönlich aus dem Projekt mit?

Kurze Antwort: Bei Zeitreihen sollte man Validierung nicht wie bei unabhängigen Daten behandeln. Die Splitlogik ist selbst Teil der Modellbewertung.