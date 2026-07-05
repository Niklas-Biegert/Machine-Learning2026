###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/07_plots.R
#
# Zweck:
# Auswertung und Visualisierung der Monte-Carlo-Ergebnisse.
###############################################################################


###############################################################################
# 0. Pakete laden
###############################################################################

library(here)
library(ggplot2)


###############################################################################
# 1. Ergebnisordner für Plots erstellen
###############################################################################

dir.create(
  here("results", "figures"),
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

mc_results$cv_method_label <- factor(
  mc_results$cv_method,
  levels = c("kfold", "loocv", "rolling_origin", "blocked", "hblock"),
  labels = c("k-fold", "LOOCV", "Rolling-origin", "Blocked", "h-block")
)

mc_summary$cv_method_label <- factor(
  mc_summary$cv_method,
  levels = c("kfold", "loocv", "rolling_origin", "blocked", "hblock"),
  labels = c("k-fold", "LOOCV", "Rolling-origin", "Blocked", "h-block")
)

model_selection$cv_method_label <- factor(
  model_selection$cv_method,
  levels = c("kfold", "loocv", "rolling_origin", "blocked", "hblock"),
  labels = c("k-fold", "LOOCV", "Rolling-origin", "Blocked", "h-block")
)


###############################################################################
# 4. Plot 1: Durchschnittlicher Bias pro CV-Methode und DGP
###############################################################################

plot_bias_mean <- ggplot(
  mc_summary,
  aes(
    x = cv_method_label,
    y = bias,
    fill = cv_method_label
  )
) +
  geom_col() +
  facet_wrap(~ dgp) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "Durchschnittlicher Bias der CV-Methoden",
    subtitle = "Bias = CV-Fehler - echter Testfehler",
    x = "Cross-Validation-Methode",
    y = "Durchschnittlicher Bias"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

plot_bias_mean

ggsave(
  filename = here("results", "figures", "plot_bias_mean.png"),
  plot = plot_bias_mean,
  width = 10,
  height = 6,
  dpi = 300
)


###############################################################################
# 5. Plot 2: Bias-Verteilung pro CV-Methode
###############################################################################

plot_bias_boxplot <- ggplot(
  mc_results,
  aes(
    x = cv_method_label,
    y = bias,
    fill = cv_method_label
  )
) +
  geom_boxplot() +
  facet_wrap(~ dgp) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "Verteilung des Bias über 500 Simulationen",
    subtitle = "Negative Werte bedeuten: CV schätzt den Fehler zu optimistisch",
    x = "Cross-Validation-Methode",
    y = "Bias"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

plot_bias_boxplot

ggsave(
  filename = here("results", "figures", "plot_bias_boxplot.png"),
  plot = plot_bias_boxplot,
  width = 10,
  height = 6,
  dpi = 300
)


###############################################################################
# 6. Plot 3: Durchschnittlicher Testfehler
###############################################################################

plot_test_error <- ggplot(
  mc_summary,
  aes(
    x = cv_method_label,
    y = test_error,
    fill = cv_method_label
  )
) +
  geom_col() +
  facet_wrap(~ dgp) +
  labs(
    title = "Durchschnittlicher Testfehler der ausgewählten Modelle",
    subtitle = "Niedrigerer RMSE bedeutet bessere Vorhersage auf dem Holdout-Testbereich",
    x = "Cross-Validation-Methode",
    y = "Durchschnittlicher Test-RMSE"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

plot_test_error

ggsave(
  filename = here("results", "figures", "plot_test_error.png"),
  plot = plot_test_error,
  width = 10,
  height = 6,
  dpi = 300
)


###############################################################################
# 7. Plot 4: Modellwahlhäufigkeiten
###############################################################################

plot_model_selection <- ggplot(
  model_selection,
  aes(
    x = cv_method_label,
    y = count,
    fill = selected_model
  )
) +
  geom_col(
    position = "dodge"
  ) +
  facet_wrap(~ dgp) +
  labs(
    title = "Modellwahlhäufigkeit über 500 Simulationen",
    subtitle = "Wie oft jede CV-Methode LM-lag1 oder LM-lag5 auswählt",
    x = "Cross-Validation-Methode",
    y = "Anzahl der Auswahlentscheidungen",
    fill = "Gewähltes Modell"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

plot_model_selection

ggsave(
  filename = here("results", "figures", "plot_model_selection.png"),
  plot = plot_model_selection,
  width = 10,
  height = 6,
  dpi = 300
)


###############################################################################
# 8. Kontrolle: gespeicherte Plots anzeigen
###############################################################################

list.files(
  here("results", "figures")
)

