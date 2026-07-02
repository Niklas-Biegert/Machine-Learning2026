# Shared setup for the time-series CV project.

required_packages <- c(
  "tidyverse",
  "forecast",
  "glmnet",
  "ranger",
  "rsample",
  "yardstick"
)

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  message("Missing R packages: ", paste(missing_packages, collapse = ", "))
  message("Install them with install.packages(missing_packages).")
}

invisible(lapply(required_packages, require, character.only = TRUE))
