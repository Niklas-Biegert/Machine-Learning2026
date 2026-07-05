# Shared setup for the time-series CV project.

required_packages <- c(
  "tidyverse",
  "forecast",
  "glmnet",
  "ranger",
  "rsample",
  "yardstick",
  "here"
)

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  message("Missing R packages: ", paste(missing_packages, collapse = ", "))
  message("Install them with install.packages(missing_packages).")
}

invisible(lapply(required_packages, require, character.only = TRUE))


###############################################################################
# Projekt-Setup
# Datei: R/00_setup.R
###############################################################################

# Pakete laden
library(here)

# DGP-Funktionen laden
source(here("R", "01_simulate_dgp.R"))
