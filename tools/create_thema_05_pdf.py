from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs" / "thema_05_latex_uebersicht.pdf"


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#4b5563"))
    canvas.drawString(2 * cm, 1.25 * cm, "Thema 5: Time Series Cross-Validation for Temporal Data")
    canvas.drawRightString(A4[0] - 2 * cm, 1.25 * cm, f"Seite {doc.page}")
    canvas.restoreState()


def p(text, style):
    return Paragraph(text, style)


def bullet(text, styles):
    return p(f"&bull; {text}", styles["Bullet"])


def make_styles():
    base = getSampleStyleSheet()
    return {
        "Title": ParagraphStyle(
            "Title",
            parent=base["Title"],
            fontName="Helvetica-Bold",
            fontSize=19,
            leading=24,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#0f2f63"),
            spaceAfter=10,
        ),
        "Subtitle": ParagraphStyle(
            "Subtitle",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=10,
            leading=14,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#334155"),
            spaceAfter=22,
        ),
        "H1": ParagraphStyle(
            "H1",
            parent=base["Heading1"],
            fontName="Helvetica-Bold",
            fontSize=14,
            leading=18,
            textColor=colors.HexColor("#0f2f63"),
            spaceBefore=12,
            spaceAfter=8,
        ),
        "H2": ParagraphStyle(
            "H2",
            parent=base["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=11.5,
            leading=15,
            textColor=colors.HexColor("#1e3a8a"),
            spaceBefore=10,
            spaceAfter=5,
        ),
        "Body": ParagraphStyle(
            "Body",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=9.5,
            leading=13.5,
            alignment=TA_LEFT,
            spaceAfter=6,
        ),
        "Bullet": ParagraphStyle(
            "Bullet",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=9.3,
            leading=13,
            leftIndent=12,
            firstLineIndent=-8,
            spaceAfter=3,
        ),
        "Formula": ParagraphStyle(
            "Formula",
            parent=base["BodyText"],
            fontName="Courier",
            fontSize=8.8,
            leading=12,
            leftIndent=14,
            textColor=colors.HexColor("#111827"),
            backColor=colors.HexColor("#f8fafc"),
            borderColor=colors.HexColor("#dbeafe"),
            borderWidth=0.4,
            borderPadding=5,
            spaceBefore=3,
            spaceAfter=7,
        ),
        "Definition": ParagraphStyle(
            "Definition",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=9.2,
            leading=13,
            leftIndent=8,
            rightIndent=4,
            borderColor=colors.HexColor("#bfdbfe"),
            borderWidth=0.6,
            borderPadding=6,
            backColor=colors.HexColor("#eff6ff"),
            spaceBefore=4,
            spaceAfter=7,
        ),
    }


def add_definition(story, styles, title, text):
    story.append(p(f"<b>Definition: {title}</b><br/>{text}", styles["Definition"]))


def add_numbered(story, styles, items):
    for i, item in enumerate(items, start=1):
        story.append(p(f"{i}. {item}", styles["Bullet"]))


def build_pdf():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    styles = make_styles()
    story = []

    doc = BaseDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        leftMargin=2 * cm,
        rightMargin=2 * cm,
        topMargin=1.8 * cm,
        bottomMargin=2 * cm,
        title="Thema 5: Time Series Cross-Validation for Temporal Data",
        author="Projektgruppe Statistical Machine Learning",
    )
    frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="normal")
    doc.addPageTemplates([PageTemplate(id="main", frames=[frame], onPage=header_footer)])

    story.append(p("Thema 5: Time Series Cross-Validation for Temporal Data", styles["Title"]))
    story.append(p("LaTeX-Uebersicht mit Definitionen und Projektvorgehen", styles["Subtitle"]))

    story.append(p("Projektziel", styles["H1"]))
    story.append(
        p(
            "Ziel der Projektarbeit ist es, verschiedene Cross-Validation-Verfahren fuer "
            "Zeitreihendaten systematisch zu vergleichen. Im Mittelpunkt steht die Frage, "
            "welches Verfahren bei zeitlich abhaengigen Daten die zuverlaessigsten "
            "Fehlerschaetzungen und Modellentscheidungen liefert.",
            styles["Body"],
        )
    )

    story.append(p("Forschungsfrage", styles["H1"]))
    story.append(
        p(
            "<i>Welche Cross-Validation-Methode eignet sich fuer Forecasting-Aufgaben "
            "mit zeitlicher Abhaengigkeit am besten, wenn Modelle anhand ihres "
            "geschaetzten Vorhersagefehlers ausgewaehlt werden?</i>",
            styles["Definition"],
        )
    )
    for item in [
        "k-fold Cross-Validation",
        "Leave-One-Out Cross-Validation (LOOCV)",
        "Rolling-Origin Cross-Validation",
        "Blocked Cross-Validation",
        "h-block Cross-Validation",
    ]:
        story.append(bullet(item, styles))

    story.append(p("Wichtige Definitionen", styles["H1"]))
    add_definition(
        story,
        styles,
        "Zeitreihe",
        "Eine Zeitreihe ist eine geordnete Folge von Beobachtungen y_1, y_2, ..., y_T, "
        "bei der die Reihenfolge inhaltlich relevant ist. Beobachtungen koennen von "
        "vorherigen Werten abhaengen.",
    )
    add_definition(
        story,
        styles,
        "Forecasting-Modell",
        "Ein Forecasting-Modell nutzt Informationen aus der Vergangenheit, um zukuenftige "
        "Werte zu prognostizieren, zum Beispiel y_t = beta_0 + beta_1 y_{t-1} + ... + beta_p y_{t-p} + epsilon_t.",
    )
    add_definition(
        story,
        styles,
        "Train-Test-Split fuer Zeitreihen",
        "Die zeitliche Ordnung bleibt erhalten: die ersten T_train Beobachtungen dienen als Training, "
        "die letzten T_test Beobachtungen als unberuehrter Hold-out-Test.",
    )
    add_definition(
        story,
        styles,
        "Cross-Validation-Fehler",
        "Der CV-Fehler ist der durchschnittliche Validierungsfehler ueber mehrere Splits. "
        "Er dient zur Schaetzung des spaeteren Vorhersagefehlers.",
    )
    add_definition(
        story,
        styles,
        "k-fold CV",
        "Die Daten werden in K Folds geteilt. Jeder Fold wird einmal validiert. Bei Zeitreihen "
        "ist zufaellige Fold-Bildung kritisch, weil Zukunftsinformation ins Training gelangen kann.",
    )
    add_definition(
        story,
        styles,
        "LOOCV",
        "Leave-One-Out CV ist k-fold CV mit K = n. Pro Split wird eine Beobachtung validiert. "
        "Bei abhaengigen Zeitpunkten kann das zu optimistischen Fehlerschaetzungen fuehren.",
    )
    add_definition(
        story,
        styles,
        "Rolling-Origin CV",
        "Das Training verwendet nur vergangene Beobachtungen, das Validierungsfenster liegt danach. "
        "Das Trainingsfenster kann expandierend oder rollierend sein.",
    )
    add_definition(
        story,
        styles,
        "Blocked CV",
        "Die Zeitreihe wird in zusammenhaengende Bloecke geteilt. Ganze Bloecke werden validiert, "
        "wodurch lokale zeitliche Struktur besser erhalten bleibt.",
    )
    add_definition(
        story,
        styles,
        "h-block CV",
        "Zwischen Training und Validierung wird eine Luecke der Laenge h gelassen, um die "
        "Abhaengigkeit zwischen Trainings- und Validierungsdaten zu reduzieren.",
    )

    story.append(PageBreak())
    story.append(p("Daten-generierende Prozesse", styles["H1"]))
    rows = [
        ["Prozess", "Form", "Idee"],
        ["AR(1)", "y_t = phi y_{t-1} + epsilon_t", "Abhaengigkeit vom vorherigen Wert"],
        ["MA(q)", "y_t = epsilon_t + theta_1 epsilon_{t-1} + ...", "Abhaengigkeit von Schocks"],
        ["ARMA(p,q)", "AR-Komponente + MA-Komponente", "Kombinierter Zeitreihenprozess"],
        ["Trend/Saison", "alpha + gamma t + A sin(2 pi t / s) + epsilon_t", "Trend und periodische Muster"],
    ]
    table = Table(rows, colWidths=[3.0 * cm, 7.3 * cm, 5.2 * cm])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0f2f63")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.2),
                ("LEADING", (0, 0), (-1, -1), 10),
                ("GRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#cbd5e1")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f8fafc")]),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    story.append(table)
    story.append(Spacer(1, 8))

    story.append(p("Kandidatenmodelle", styles["H1"]))
    for item in [
        "lineare Lag-Regression",
        "Ridge Regression mit Lags",
        "Lasso Regression mit Lags",
        "Regression Tree",
        "Random Forest oder anderes tree-based Modell",
    ]:
        story.append(bullet(item, styles))
    story.append(p("Lag-Features: x_t = (y_{t-1}, y_{t-2}, ..., y_{t-p}).", styles["Formula"]))

    story.append(p("Evaluationsgroessen", styles["H1"]))
    story.append(p("<b>Hold-out-Testfehler:</b> mittlerer Fehler auf den letzten, unberuehrten Beobachtungen.", styles["Body"]))
    story.append(p("Err_test = (1 / T_test) sum_{t in Test} (y_t - yhat_t)^2", styles["Formula"]))
    story.append(p("<b>RMSE:</b> Wurzel aus dem mittleren quadratischen Fehler.", styles["Body"]))
    story.append(p("RMSE = sqrt((1 / n) sum_i (y_i - yhat_i)^2)", styles["Formula"]))
    story.append(p("<b>Bias der Fehlerschaetzung:</b> durchschnittliche Differenz aus CV-Fehler und Testfehler.", styles["Body"]))
    story.append(p("Bias = (1 / R) sum_r (Err_CV,r - Err_test,r)", styles["Formula"]))
    story.append(p("<b>Varianz:</b> Streuung der CV-Fehlerschaetzung ueber alle Monte-Carlo-Wiederholungen.", styles["Body"]))
    story.append(p("<b>Model-Selection Accuracy:</b> Anteil der Simulationen, in denen CV das auf dem Testset beste Modell auswaehlt.", styles["Body"]))

    story.append(PageBreak())
    story.append(p("Genauer Arbeitsablauf", styles["H1"]))

    phases = [
        (
            "Phase 1: Theorie und Eingrenzung",
            [
                "Vorlesungsfolien zu Resampling Methods und Model Selection sichten.",
                "Definitionen fuer k-fold, LOOCV, Rolling-Origin, Blocked CV und h-block CV formulieren.",
                "Begruenden, warum Standard-CV bei Zeitreihen problematisch sein kann.",
                "Forschungsfrage und Vergleichskriterien final festlegen.",
            ],
        ),
        (
            "Phase 2: Simulationsdesign",
            [
                "Daten-generierende Prozesse festlegen: AR, MA, ARMA, Trend und Saisonalitaet.",
                "Parameter festlegen, z.B. T = 250, T_train = 175, T_test = 75.",
                "Monte-Carlo-Wiederholungen festlegen: erst R = 20 als Testlauf, danach z.B. R = 500.",
                "Kandidaten-Lags definieren, z.B. p in {1, 2, 5, 10}.",
                "h-Werte fuer h-block CV definieren, z.B. h in {1, 5, 10}.",
            ],
        ),
        (
            "Phase 3: Implementierung",
            [
                "Funktionen fuer die Simulation der DGPs schreiben.",
                "Lag-Features erstellen.",
                "CV-Splitter fuer alle Verfahren implementieren.",
                "Modellfunktionen fuer lineare Regression, Ridge, Lasso und Tree-Based Methods bauen.",
                "Evaluation fuer RMSE, Bias, Varianz, Accuracy und Laufzeit implementieren.",
            ],
        ),
        (
            "Phase 4: Smoke-Test",
            [
                "Sehr kleinen Testlauf ausfuehren: ein DGP, zwei Modelle, zwei CV-Verfahren, R = 5.",
                "Pruefen, ob alle Splits zeitlich korrekt sind.",
                "Pruefen, ob keine Daten aus der Zukunft ins Training gelangen.",
                "Erste Ergebnisdatei speichern und kontrollieren.",
            ],
        ),
        (
            "Phase 5: Hauptsimulation",
            [
                "Alle DGPs und Parameterkombinationen durchlaufen.",
                "Pro Simulation CV-Fehler je Verfahren und Modell berechnen.",
                "Je CV-Verfahren das Modell mit kleinstem CV-Fehler auswaehlen.",
                "Ausgewaehltes Modell auf dem Hold-out-Testset evaluieren.",
                "CV-Fehler, Testfehler, Modellentscheidung und Laufzeit speichern.",
            ],
        ),
        (
            "Phase 6: Auswertung und Interpretation",
            [
                "Bias, Varianz, Test-RMSE, Model-Selection Accuracy und Laufzeit vergleichen.",
                "Boxplots, Balkendiagramme, Tabellen und ggf. Heatmaps erstellen.",
                "Trade-off zwischen Bias, Varianz und Laufzeit diskutieren.",
                "Praktische Empfehlung fuer Forecasting-Probleme formulieren.",
            ],
        ),
    ]

    for title, items in phases:
        story.append(p(title, styles["H2"]))
        add_numbered(story, styles, items)

    story.append(p("Geplanter Output", styles["H1"]))
    for item in [
        "reproduzierbarer Code fuer Simulation und Evaluation",
        "Tabellen mit Bias, Varianz, RMSE, Accuracy und Laufzeit",
        "Grafiken fuer Hausarbeit und Praesentation",
        "Hausarbeit mit Methodik, Ergebnissen und Fazit",
        "Praesentation mit klarer Empfehlung fuer die Anwendung",
    ]:
        story.append(bullet(item, styles))

    story.append(p("Kurze Erwartung", styles["H1"]))
    story.append(
        p(
            "Es ist zu erwarten, dass zufaellige k-fold CV und LOOCV bei stark abhaengigen "
            "Zeitreihen zu optimistische Fehlerschaetzungen liefern koennen. Verfahren, die "
            "die zeitliche Ordnung explizit beruecksichtigen, insbesondere Rolling-Origin, "
            "Blocked CV und h-block CV, sollten realistischere Schaetzungen liefern. Welches "
            "Verfahren insgesamt am besten abschneidet, haengt von Autokorrelation, "
            "Trend/Saisonalitaet, Stichprobengroesse und Modellklasse ab.",
            styles["Body"],
        )
    )

    doc.build(story)


if __name__ == "__main__":
    build_pdf()
    print(OUTPUT)
