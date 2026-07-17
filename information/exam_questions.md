# Mögliche Prüfungsfragen

## Projektbezogene Fragen

### Warum wurden fünf DGPs verwendet?

Kurze Antwort: Die fünf DGPs bilden unterschiedliche Zeitreihenstrukturen ab und machen den Methodenvergleich breiter.

Ausführlichere Antwort: AR(1), MA(1) und ARMA(1,1) decken einfache stationäre Abhängigkeiten ab. Trend und Saisonalität bringen nichtstationäre beziehungsweise periodische Strukturen hinein. Dadurch wird sichtbar, ob eine CV-Methode nur in einem einfachen stationären Fall gut funktioniert oder auch bei anderen Strukturen stabil bleibt.

Mögliche kritische Nachfrage: Warum wurden keine realen Daten verwendet?

Antwort: Simulierte Daten erlauben viele Wiederholungen unter kontrollierten Bedingungen. Für reale Daten wäre die Interpretation weniger eindeutig, weil die wahre Struktur unbekannt ist.

### Warum 200 Wiederholungen?

Kurze Antwort: 200 Wiederholungen sind ein praktikabler Kompromiss zwischen Stabilität und Rechenzeit.

Ausführlichere Antwort: Eine einzelne simulierte Zeitreihe kann zufällig stark abweichen. Durch 200 Wiederholungen je DGP lässt sich die mittlere Verzerrung und Streuung der CV-Schätzungen stabiler beurteilen. Gleichzeitig bleibt der Lauf für ein Kursprojekt noch ausführbar.

Mögliche kritische Nachfrage: Wären 1.000 Wiederholungen besser?

Antwort: Für noch genauere Monte-Carlo-Schätzungen ja. Für dieses Projekt war 200 aber ausreichend, um klare Muster zu erkennen und die Laufzeit beherrschbar zu halten.

### Warum fünf Lags im Hauptmodell?

Kurze Antwort: Das Modell sollte einfach und für alle DGPs gleich sein.

Ausführlichere Antwort: Das lineare Modell mit `lag_1` bis `lag_5` ist nicht für jeden DGP optimal. Es hält aber den Modellteil konstant, sodass Unterschiede stärker auf die CV-Methode zurückgeführt werden können. Besonders bei der saisonalen Zeitreihe ist das eine bewusste Limitation, weil `lag_12` nicht enthalten ist.

Mögliche kritische Nachfrage: Ist das saisonale Modell dadurch falsch?

Antwort: Es ist nicht vollständig spezialisiert. Das ist als Limitation dokumentiert, betrifft aber alle CV-Methoden gleich.

### Warum beginnt das Training bei 31?

Kurze Antwort: Der Start bei 31 passt zur Lag-Erstellung und zur zusätzlichen Lag-30-Fallstudie.

Ausführlichere Antwort: Lag-Features benötigen vergangene Beobachtungen. In der Hauptstudie werden fünf Lags genutzt, in der Zusatzanalyse bis zu 30 Lags. Der einheitliche Start bei Zeitpunkt 31 sorgt dafür, dass beide Teile ein konsistentes Zeitfenster verwenden.

Mögliche kritische Nachfrage: Verliert man dadurch Daten?

Antwort: Ja, aber der Verlust ist bewusst und macht die Vergleiche zwischen Haupt- und Zusatzanalyse konsistent.

### Warum ist der Testzeitraum unabhängig?

Kurze Antwort: Er liegt vollständig nach dem Training und wird nicht für die CV verwendet.

Ausführlichere Antwort: Der Testzeitraum umfasst die Zeitpunkte 185 bis 250. Die CV arbeitet nur im Trainingsbereich 31 bis 184. Dadurch dient der Testzeitraum als Annäherung an den zukünftigen Prognosefehler.

Mögliche kritische Nachfrage: Ist er wirklich unabhängig?

Antwort: Bei Zeitreihen besteht zeitliche Abhängigkeit. Gemeint ist hier unabhängig im Validierungssinn: Er wird nicht für Training, CV oder Modellwahl verwendet.

### Warum kann k-fold bei ARMA trotzdem gut abschneiden?

Kurze Antwort: In diesem einfachen stationären Szenario kann die numerische Fehlerschätzung nah am Testfehler liegen.

Ausführlichere Antwort: k-fold ist methodisch problematisch, weil es die Zeitrichtung ignoriert. Trotzdem kann es in bestimmten einfachen stationären Settings eine Fehlerschätzung liefern, die im Mittel nahe am späteren Testfehler liegt. Das ist ein Ergebnis dieses Szenarios, keine allgemeine Empfehlung.

Mögliche kritische Nachfrage: Würden Sie k-fold für Zeitreihen empfehlen?

Antwort: Nicht allgemein. Für echte Prognosesituationen würde ich zeitgerichtete Verfahren bevorzugen oder zumindest die Leakage-Gefahr sehr genau prüfen.

### Warum ist blocked CV nicht vollständig zeitlich sauber?

Kurze Antwort: Die Validierungsblöcke sind zusammenhängend, aber spätere Blöcke können im Training liegen.

Ausführlichere Antwort: Blocked CV verhindert zufälliges Mischen und erhält kompakte Validierungsbereiche. Wenn aber ein mittlerer Block validiert wird, können Trainingsdaten sowohl vor als auch nach diesem Block liegen. Dadurch ist die reale Prognoserichtung nicht vollständig eingehalten.

Mögliche kritische Nachfrage: Was ist der Vorteil gegenüber k-fold?

Antwort: Die Validierungsbereiche sind zeitlich zusammenhängend, was die Zeitstruktur zumindest teilweise respektiert.

### Was macht h-block?

Kurze Antwort: h-block entfernt einen Puffer um den Validierungsblock.

Ausführlichere Antwort: In diesem Projekt beträgt der Puffer `h = 5`. Die fünf direkten Nachbarn vor und nach dem Validierungsblock werden aus dem Training entfernt. Dadurch wird lokale Abhängigkeit zwischen Training und Validierung reduziert.

Mögliche kritische Nachfrage: Ist h-block dann zeitlich sauber?

Antwort: Nicht vollständig. Es reduziert lokale Nähe, kann aber weiterhin spätere Trainingsbeobachtungen außerhalb des Puffers enthalten.

### Was ist der Unterschied zwischen Bias und RMSE?

Kurze Antwort: Bias misst die mittlere Verzerrung, RMSE die gesamte typische Abweichung.

Ausführlichere Antwort: Der Bias kann nahe null sein, wenn positive und negative Fehler sich ausgleichen. RMSE quadriert die Fehler und bestraft größere Abweichungen stärker. Deshalb kann eine Methode mit kleinem Bias trotzdem einen größeren RMSE haben.

Mögliche kritische Nachfrage: Welche Kennzahl ist wichtiger?

Antwort: Keine allein. Bias, RMSE und Varianz beantworten unterschiedliche Fragen und sollten zusammen betrachtet werden.

### Warum ist rolling-origin nicht immer die beste Methode?

Kurze Antwort: Es ist zeitlich sauber, kann aber variablere Schätzungen erzeugen.

Ausführlichere Antwort: Rolling-origin trainiert nur auf vergangenen Daten und validiert auf späteren Blöcken. Dadurch ist die Prognoselogik realistisch. In diesem Design entstehen aber weniger beziehungsweise unterschiedlich große Validierungsfenster, was die Streuung erhöhen kann.

Mögliche kritische Nachfrage: Trotzdem die beste Wahl in der Praxis?

Antwort: Oft ist es methodisch sehr plausibel. Ob es praktisch die beste Wahl ist, hängt aber von Datenmenge, Ziel und Stabilität der Schätzung ab.

### Warum wird dasselbe Modell für alle DGPs verwendet?

Kurze Antwort: Damit der Einfluss der CV-Methode isolierter untersucht werden kann.

Ausführlichere Antwort: Würde man für jeden DGP ein eigenes optimales Modell wählen, wären Modellwahl und Validierungsmethode vermischt. Das gemeinsame Lag-Modell ist eine kontrollierte Vereinfachung.

Mögliche kritische Nachfrage: Ist das nicht unrealistisch?

Antwort: Für reale Modellierung ja. Für einen Methodenvergleich ist die Vereinfachung sinnvoll, solange sie als Limitation genannt wird.

### Was bedeutet ein negativer Schätzfehler?

Kurze Antwort: Die CV schätzt den Testfehler zu optimistisch.

Ausführlichere Antwort: Der Schätzfehler ist `cv_mse - test_mse`. Wenn der Wert negativ ist, liegt der CV-MSE unter dem Test-MSE. Die Methode unterschätzt also den späteren Prognosefehler.

Mögliche kritische Nachfrage: Ist optimistisch immer schlecht?

Antwort: Es ist riskant, weil die spätere Modellleistung überschätzt werden kann. Für Modellwahl und Kommunikation ist das problematisch.

### Welche Limitationen hat die Studie?

Kurze Antwort: Simulierte einfache DGPs, ein lineares gemeinsames Modell und eine begrenzte Zusatzfallstudie.

Ausführlichere Antwort: Reale Daten können Strukturbrüche, Ausreißer, Nichtlinearitäten und mehrere saisonale Muster enthalten. Außerdem enthält das Hauptmodell keinen `lag_12`, obwohl ein saisonaler DGP verwendet wird. Die Ridge-/Lasso-Fallstudie betrachtet nur einen zusätzlichen ARMA-Fall.

Mögliche kritische Nachfrage: Was wäre eine sinnvolle Erweiterung?

Antwort: Mehr DGPs, reale Datensätze, alternative Modelle und mehr Wiederholungen wären sinnvolle nächste Schritte.

## Allgemeine fachliche Fragen

### Was ist Cross-Validation?

Kurze Antwort: Ein Verfahren zur Schätzung der Vorhersageleistung durch wiederholtes Aufteilen in Training und Validierung.

Ausführlichere Antwort: Das Modell wird auf einem Teil der Daten trainiert und auf einem anderen Teil bewertet. Mehrere Splits liefern eine robustere Schätzung des Fehlers als eine einzelne Aufteilung.

Mögliche kritische Nachfrage: Warum nicht einfach den Trainingsfehler verwenden?

Antwort: Der Trainingsfehler ist meist zu optimistisch, weil das Modell genau auf diesen Daten geschätzt wurde.

### Was ist der Bias-Varianz-Trade-off?

Kurze Antwort: Modelle oder Schätzer können entweder systematisch verzerrt oder stark schwankend sein.

Ausführlichere Antwort: Hoher Bias bedeutet, dass ein Verfahren im Mittel falsch liegt. Hohe Varianz bedeutet, dass es stark auf die konkrete Stichprobe reagiert. Gute Verfahren müssen beides ausbalancieren.

Mögliche kritische Nachfrage: Wie zeigt sich das in diesem Projekt?

Antwort: Eine CV-Methode kann einen kleinen Bias, aber eine große Varianz des Schätzfehlers haben.

### Was ist Overfitting?

Kurze Antwort: Ein Modell passt sich zu stark an Trainingsdaten an und generalisiert schlechter.

Ausführlichere Antwort: Overfitting tritt auf, wenn ein Modell Muster lernt, die eher Zufall oder Rauschen sind. Dann ist der Trainingsfehler klein, aber der Testfehler hoch.

Mögliche kritische Nachfrage: Wie erkennt man Overfitting?

Antwort: Ein großer Abstand zwischen Trainings- und Validierungs- oder Testfehler ist ein typisches Warnsignal.

### Was ist Regularisierung?

Kurze Antwort: Regularisierung bestraft komplexe Modelle, um Overfitting zu reduzieren.

Ausführlichere Antwort: Bei Ridge und Lasso wird zur Fehlerfunktion ein Strafterm hinzugefügt. Dadurch werden Koeffizienten kleiner, und das Modell kann stabiler werden.

Mögliche kritische Nachfrage: Was steuert die Stärke?

Antwort: Der Parameter `lambda`. Größere Werte bedeuten stärkere Regularisierung.

### Unterschied Ridge und Lasso

Kurze Antwort: Ridge schrumpft Koeffizienten, Lasso kann sie exakt auf null setzen.

Ausführlichere Antwort: Ridge verwendet eine L2-Strafe und behält typischerweise alle Prädiktoren im Modell. Lasso verwendet eine L1-Strafe und kann Variablen auswählen, weil manche Koeffizienten genau null werden.

Mögliche kritische Nachfrage: Wann ist Lasso hilfreich?

Antwort: Wenn viele Prädiktoren vorhanden sind und nur einige davon wirklich wichtig sein könnten.

### Bedeutung von lambda

Kurze Antwort: `lambda` ist die Regularisierungsstärke.

Ausführlichere Antwort: Bei kleinem `lambda` ähnelt das Modell stärker einem unregularisierten Modell. Bei großem `lambda` werden Koeffizienten stärker geschrumpft. Im Projekt wird `lambda` im Trainingszeitraum per rolling-origin-Validierung ausgewählt.

Mögliche kritische Nachfrage: Darf der Testzeitraum für lambda verwendet werden?

Antwort: Nein, sonst wäre der Testfehler nicht mehr unabhängig.

### Unterschied Trainings-, Validierungs- und Testfehler

Kurze Antwort: Trainingsfehler misst Anpassung, Validierungsfehler unterstützt Auswahl, Testfehler bewertet final.

Ausführlichere Antwort: Der Trainingsfehler entsteht auf den Daten, auf denen das Modell geschätzt wurde. Der Validierungsfehler wird zur Modell- oder Methodenwahl genutzt. Der Testfehler soll erst am Ende verwendet werden und die spätere Prognoseleistung annähern.

Mögliche kritische Nachfrage: Warum ist der Testfehler besonders wichtig?

Antwort: Weil er nicht zur Auswahl genutzt werden sollte und deshalb eine neutralere Bewertung liefert.

### Warum ist Data Leakage problematisch?

Kurze Antwort: Das Modell nutzt Informationen, die in der echten Prognosesituation nicht verfügbar wären.

Ausführlichere Antwort: Leakage macht Fehlerschätzungen zu optimistisch. Bei Zeitreihen kann Leakage entstehen, wenn zukünftige Beobachtungen beim Training für frühere Validierungszeitpunkte verwendet werden.

Mögliche kritische Nachfrage: Betrifft das nur Zeitreihen?

Antwort: Nein, aber bei Zeitreihen ist es besonders naheliegend, weil die zeitliche Reihenfolge eine klare Informationsgrenze definiert.

### Was bedeutet Stationarität?

Kurze Antwort: Die grundlegenden Verteilungseigenschaften ändern sich nicht systematisch über die Zeit.

Ausführlichere Antwort: Bei einem stationären Prozess bleiben Erwartungswert, Varianz und Abhängigkeitsstruktur ungefähr konstant. Trendprozesse sind typischerweise nicht stationär, weil sich der Erwartungswert verändert.

Mögliche kritische Nachfrage: Warum ist Stationarität wichtig?

Antwort: Viele Zeitreihenmodelle und Validierungsannahmen funktionieren einfacher, wenn die Struktur über die Zeit stabil bleibt.

### Unterschied AR, MA und ARMA

Kurze Antwort: AR nutzt vergangene Werte, MA vergangene Fehler, ARMA kombiniert beides.

Ausführlichere Antwort: Bei AR-Prozessen hängt der aktuelle Wert von früheren Beobachtungen ab. Bei MA-Prozessen hängt er von aktuellen und vergangenen Schocks ab. ARMA-Prozesse enthalten beide Komponenten.

Mögliche kritische Nachfrage: Welcher Prozess ist komplexer?

Antwort: ARMA ist flexibler, weil es autoregressive und Moving-Average-Abhängigkeit kombiniert.

### Was ist eine Monte-Carlo-Simulation?

Kurze Antwort: Ein Verfahren, bei dem ein Zufallsexperiment viele Male wiederholt wird.

Ausführlichere Antwort: In diesem Projekt wird jede Zeitreihenstruktur 200-mal neu simuliert. Dadurch kann man untersuchen, wie stabil die CV-Methoden über viele mögliche Realisierungen hinweg sind.

Mögliche kritische Nachfrage: Warum ist Reproduzierbarkeit möglich, obwohl Zufall verwendet wird?

Antwort: Durch feste Seeds werden die Zufallszahlen reproduzierbar erzeugt.