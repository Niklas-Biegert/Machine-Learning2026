###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/08_tables_and_interpretation.R
#
# Zweck:
# Tabellen und einfache Interpretation der Monte-Carlo-Ergebnisse erstellen.
###############################################################################


###############################################################################
# 0. Pakete laden
###############################################################################

library(here)


###############################################################################
# 1. Ergebnisordner erstellen
###############################################################################

dir.create(
  here("results", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)


###############################################################################
# 2. Ergebnisse laden
###############################################################################

mc_results <- readRDS(
  here("results", "tables", "mc_results_500_all_cv.rds")
)

mc_summary <- readRDS(
  here("results", "tables", "mc_summary_500_all_cv.rds")
)

model_selection <- readRDS(
  here("results", "tables", "model_selection_500_all_cv.rds")
)


###############################################################################
# 3. CV-Methoden schöner benennen
###############################################################################

method_labels <- c(
  kfold = "k-fold",
  loocv = "LOOCV",
  rolling_origin = "Rolling-origin",
  blocked = "Blocked",
  hblock = "h-block"
)

mc_summary$cv_method_label <- method_labels[mc_summary$cv_method]
model_selection$cv_method_label <- method_labels[model_selection$cv_method]


###############################################################################
# 4. Haupttabelle: durchschnittliche Fehler und Bias
###############################################################################

summary_table <- mc_summary[
  order(mc_summary$dgp, mc_summary$cv_method),
  c("dgp", "cv_method_label", "cv_error", "test_error", "bias")
]

names(summary_table) <- c(
  "DGP",
  "CV_Method",
  "Mean_CV_RMSE",
  "Mean_Test_RMSE",
  "Mean_Bias"
)

# Werte runden
summary_table$Mean_CV_RMSE <- round(summary_table$Mean_CV_RMSE, 4)
summary_table$Mean_Test_RMSE <- round(summary_table$Mean_Test_RMSE, 4)
summary_table$Mean_Bias <- round(summary_table$Mean_Bias, 4)

summary_table


###############################################################################
# 5. Zusätzliche Tabelle: Bias-Varianz / Standardabweichung
###############################################################################

bias_sd_table <- aggregate(
  bias ~ dgp + cv_method,
  data = mc_results,
  FUN = sd
)

names(bias_sd_table) <- c(
  "DGP",
  "cv_method",
  "SD_Bias"
)

bias_sd_table$CV_Method <- method_labels[bias_sd_table$cv_method]
bias_sd_table$SD_Bias <- round(bias_sd_table$SD_Bias, 4)

bias_sd_table <- bias_sd_table[
  order(bias_sd_table$DGP, bias_sd_table$cv_method),
  c("DGP", "CV_Method", "SD_Bias")
]

bias_sd_table


###############################################################################
# 6. Modellwahlhäufigkeiten in Prozent berechnen
###############################################################################

# Pro DGP und CV-Methode gibt es 500 Entscheidungen.
# Wir berechnen: Wie oft wurde welches Modell gewählt?

model_selection$total <- ave(
  model_selection$count,
  model_selection$dgp,
  model_selection$cv_method,
  FUN = sum
)

model_selection$percentage <- 100 * model_selection$count / model_selection$total

model_selection_table <- model_selection[
  order(
    model_selection$dgp,
    model_selection$cv_method,
    model_selection$selected_model
  ),
  c("dgp", "cv_method_label", "selected_model", "count", "percentage")
]

names(model_selection_table) <- c(
  "DGP",
  "CV_Method",
  "Selected_Model",
  "Count",
  "Percentage"
)

model_selection_table$Percentage <- round(model_selection_table$Percentage, 2)

model_selection_table


###############################################################################
# 7. Beste Methode nach absolutem Bias je DGP
###############################################################################

summary_table$Abs_Bias <- abs(summary_table$Mean_Bias)

best_bias_table <- summary_table[
  ave(
    summary_table$Abs_Bias,
    summary_table$DGP,
    FUN = function(x) x == min(x)
  ) == TRUE,
]

best_bias_table <- best_bias_table[
  c("DGP", "CV_Method", "Mean_Bias", "Abs_Bias")
]

best_bias_table


###############################################################################
# 8. Tabellen speichern
###############################################################################

write.csv(
  summary_table,
  here("results", "tables", "summary_table_final.csv"),
  row.names = FALSE
)

write.csv(
  bias_sd_table,
  here("results", "tables", "bias_sd_table_final.csv"),
  row.names = FALSE
)

write.csv(
  model_selection_table,
  here("results", "tables", "model_selection_table_final.csv"),
  row.names = FALSE
)

write.csv(
  best_bias_table,
  here("results", "tables", "best_bias_table_final.csv"),
  row.names = FALSE
)


###############################################################################
# 9. Kurze automatische Textinterpretation
###############################################################################

cat("\n============================================================\n")
cat("KURZINTERPRETATION DER ERGEBNISSE\n")
cat("============================================================\n\n")

cat("1. Mean_Bias = Mean_CV_RMSE - Mean_Test_RMSE.\n")
cat("   Negative Werte bedeuten: Die CV-Methode schätzt den Fehler zu optimistisch.\n")
cat("   Positive Werte bedeuten: Die CV-Methode schätzt den Fehler zu pessimistisch.\n\n")

cat("2. Methoden mit Mean_Bias nahe 0 liefern im Durchschnitt die realistischste\n")
cat("   Schätzung des späteren Testfehlers.\n\n")

cat("3. Die Modellwahlhäufigkeiten zeigen, ob eine CV-Methode eher das einfache\n")
cat("   Modell LM-lag1 oder das komplexere Modell LM-lag5 auswählt.\n\n")

cat("4. Die Bias-Standardabweichung zeigt, wie stark die Fehlerschätzung über\n")
cat("   die 500 Simulationen schwankt.\n\n")

cat("Beste Methode nach absolutem Bias je DGP:\n")
print(best_bias_table)

cat("\nGespeicherte Tabellen:\n")
print(list.files(here("results", "tables"), pattern = "_final.csv"))

