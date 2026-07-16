###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/07_plots.R
#
# Zweck:
# Finale Grafiken für die zentrale CV-Monte-Carlo-Studie erstellen.
###############################################################################

suppressPackageStartupMessages({
  library(here)
  library(ggplot2)
})

source(here("syntax", "project_config.R"))
source(here("syntax", "01_simulate_dgp.R"))

method_labels <- c(
  kfold = "Standard k-fold",
  blocked = "Blocked CV",
  hblock = "h-block CV",
  rolling_origin = "Rolling-origin"
)

method_colors <- c(
  kfold = "#0B4F7D",
  blocked = "#177E89",
  hblock = "#7CA982",
  rolling_origin = "#F05425"
)

theme_project <- function() {
  theme_minimal(base_family = "Segoe UI") +
    theme(
      plot.title = element_text(color = "#0B4F7D", face = "bold"),
      plot.subtitle = element_text(color = "#52616D"),
      axis.title = element_text(color = "#24303B"),
      legend.title = element_blank(),
      panel.grid.minor = element_blank(),
      strip.text = element_text(face = "bold", color = "#0B4F7D")
    )
}

save_project_plot <- function(plot, filename, width = 9, height = 5.5) {
  ggsave(filename = filename, plot = plot, width = width, height = height, dpi = 300)
}

plot_cv_results <- function(config = get_project_config(), run_label = "final") {
  raw_dir <- here("output", "cv_comparison", "raw")
  table_dir <- here("output", "cv_comparison", "tables")
  figure_dir <- here("output", "cv_comparison", "figures")
  dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

  results_path <- if (run_label == "final") {
    file.path(raw_dir, "cv_simulation_results.csv")
  } else {
    file.path(raw_dir, paste0("cv_simulation_results_", run_label, ".csv"))
  }
  results <- read.csv(results_path, stringsAsFactors = FALSE)
  summary_table <- read.csv(file.path(table_dir, "cv_method_summary.csv"), stringsAsFactors = FALSE)
  ranking <- read.csv(file.path(table_dir, "cv_method_ranking.csv"), stringsAsFactors = FALSE)

  results$cv_method_label <- method_labels[results$cv_method]
  summary_table$cv_method_label <- method_labels[summary_table$cv_method]

  set.seed(config$seed)
  example_rows <- data.frame()
  for (dgp_name in config$dgp_names) {
    y <- simulate_dgp(dgp_name, config)
    example_rows <- rbind(example_rows, data.frame(
      time = seq_along(y),
      y = y,
      dgp = dgp_name
    ))
  }

  p1 <- ggplot(example_rows, aes(x = time, y = y)) +
    geom_line(color = "#0B4F7D", linewidth = 0.35) +
    facet_wrap(~ dgp, scales = "free_y", ncol = 1) +
    labs(
      title = "Beispielrealisierungen der fünf Zeitreihenstrukturen",
      x = "Zeit", y = "Wert"
    ) +
    theme_project()
  save_project_plot(p1, file.path(figure_dir, "01_dgp_example_realizations.png"), 9, 8)

  schema <- data.frame(
    method = rep(c("Standard k-fold", "Blocked CV", "h-block CV", "Rolling-origin"), each = 5),
    segment = c(
      "Train", "Validation", "Train", "Validation", "Train",
      "Validation", "Train", "Train", "Train", "Train",
      "Buffer", "Validation", "Buffer", "Train", "Train",
      "Train", "Validation", "Train", "Validation", "Train"
    ),
    xmin = c(1, 21, 41, 61, 81, 1, 21, 41, 61, 81, 16, 26, 36, 1, 46, 1, 45, 1, 65, 1),
    xmax = c(20, 40, 60, 80, 100, 20, 40, 60, 80, 100, 25, 35, 45, 15, 100, 44, 60, 64, 80, 100),
    y = rep(4:1, each = 5)
  )
  schema$segment <- factor(schema$segment, levels = c("Train", "Validation", "Buffer"))

  p2 <- ggplot(schema, aes(xmin = xmin, xmax = xmax, ymin = y - 0.35, ymax = y + 0.35, fill = segment)) +
    geom_rect(color = "white") +
    scale_y_continuous(breaks = 1:4, labels = rev(c("Standard k-fold", "Blocked CV", "h-block CV", "Rolling-origin"))) +
    scale_fill_manual(values = c(Train = "#0B4F7D", Validation = "#F05425", Buffer = "#FACC15")) +
    labs(title = "Schematische Split-Logik der vier CV-Verfahren", x = "Zeitindex im Trainingsfenster", y = "") +
    theme_project()
  save_project_plot(p2, file.path(figure_dir, "02_cv_split_schema.png"), 9, 4.8)

  p3 <- ggplot(summary_table, aes(x = cv_method_label, y = bias, fill = cv_method)) +
    geom_col() +
    geom_hline(yintercept = 0, linetype = "dashed") +
    facet_wrap(~ dgp, scales = "free_y") +
    scale_fill_manual(values = method_colors) +
    labs(title = "Bias der Fehlerschätzung", subtitle = "Bias = mean(CV-MSE - Test-MSE)", x = "", y = "Bias") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p3, file.path(figure_dir, "03_bias_by_method_and_dgp.png"))

  p4 <- ggplot(summary_table, aes(x = cv_method_label, y = rmse_estimation_error, fill = cv_method)) +
    geom_col() +
    facet_wrap(~ dgp, scales = "free_y") +
    scale_fill_manual(values = method_colors) +
    labs(title = "RMSE der Fehlerschätzung", subtitle = "sqrt(mean((CV-MSE - Test-MSE)^2))", x = "", y = "RMSE") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p4, file.path(figure_dir, "04_rmse_estimation_error.png"))

  p5 <- ggplot(results[results$success == TRUE, ], aes(x = cv_method_label, y = estimation_error, fill = cv_method)) +
    geom_boxplot(outlier.alpha = 0.25) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    facet_wrap(~ dgp, scales = "free_y") +
    scale_fill_manual(values = method_colors) +
    labs(title = "Verteilung von CV-MSE minus Test-MSE", x = "", y = "Schätzfehler") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p5, file.path(figure_dir, "05_estimation_error_boxplots.png"))

  p6 <- ggplot(results[results$success == TRUE, ], aes(x = test_mse, y = cv_mse, color = cv_method)) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "#52616D") +
    geom_point(alpha = 0.35, size = 1.1) +
    facet_wrap(~ dgp, scales = "free") +
    scale_color_manual(values = method_colors, labels = method_labels) +
    labs(title = "CV-MSE gegenüber unabhängigem Test-MSE", x = "Test-MSE", y = "CV-MSE") +
    theme_project()
  save_project_plot(p6, file.path(figure_dir, "06_cv_mse_vs_test_mse.png"))

  p7 <- ggplot(summary_table, aes(x = cv_method_label, y = var_estimation_error, fill = cv_method)) +
    geom_col() +
    facet_wrap(~ dgp, scales = "free_y") +
    scale_fill_manual(values = method_colors) +
    labs(title = "Varianz der Fehlerschätzung", x = "", y = "Varianz") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p7, file.path(figure_dir, "07_variance_estimation_error.png"))

  p8 <- ggplot(summary_table, aes(x = cv_method_label, y = mean_runtime_seconds, fill = cv_method)) +
    geom_col() +
    facet_wrap(~ dgp, scales = "free_y") +
    scale_fill_manual(values = method_colors) +
    labs(title = "Mittlere Laufzeit je Simulation und CV-Methode", x = "", y = "Sekunden") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p8, file.path(figure_dir, "08_runtime_comparison.png"))

  p9 <- ggplot(summary_table, aes(x = cv_method_label, y = dgp, fill = rmse_estimation_error)) +
    geom_tile(color = "white") +
    scale_fill_gradient(low = "#EEF4F7", high = "#F05425") +
    labs(title = "Heatmap: RMSE der Fehlerschätzung", x = "", y = "", fill = "RMSE") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p9, file.path(figure_dir, "09_rmse_heatmap.png"), 8, 4.8)

  ranking_long <- data.frame(
    dgp = rep(ranking$dgp, 4),
    criterion = rep(c("Abs. Bias", "RMSE", "Varianz", "Laufzeit"), each = nrow(ranking)),
    method = c(ranking$best_abs_bias, ranking$best_rmse_estimation_error, ranking$best_variance, ranking$fastest_method)
  )
  ranking_long$method_label <- method_labels[ranking_long$method]

  p10 <- ggplot(ranking_long, aes(x = criterion, fill = method)) +
    geom_bar() +
    facet_wrap(~ dgp) +
    scale_fill_manual(values = method_colors, labels = method_labels) +
    labs(title = "Rangfolge der CV-Methoden nach Kriterium", x = "Kriterium", y = "Anzahl bester Einstufungen") +
    theme_project() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
  save_project_plot(p10, file.path(figure_dir, "10_method_ranking_by_dgp.png"), 9, 5.5)

  invisible(list(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10))
}

