###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/06_monte_carlo.R
#
# Zweck:
# Monte-Carlo-Simulation:
# Die gesamte Pipeline wird mehrfach wiederholt.
#
# Ablauf pro Wiederholung:
# 1. Zeitreihe simulieren
# 2. Lag-Features bauen
# 3. Train/Test-Split
# 4. CV-Methoden vergleichen Modelle
# 5. Bestes Modell auswählen
# 6. Ausgewähltes Modell auf gesamtem Training fitten
# 7. Auf echtem Testbereich bewerten
# 8. Bias berechnen
###############################################################################


###############################################################################
# 0. Pakete und Funktionen laden
###############################################################################

library(here)

source(here("R", "01_simulate_dgp.R"))
source(here("R", "02_create_lags.R"))
source(here("R", "03_train_test_split.R"))
source(here("R", "04_models.R"))
source(here("R", "05_cv_methods.R"))


###############################################################################
# 1. Eine einzelne Monte-Carlo-Wiederholung
###############################################################################

run_one_simulation <- function(
    sim_id,
    dgp_name = "ARMA(1,1)",
    T = 250,
    sigma = 1,
    max_lag = 5,
    train_prop = 0.7,
    model_names = c("LM-lag1", "LM-lag5")
) {
  
  ###########################################################################
  # 1. Seed setzen
  ###########################################################################
  
  set.seed(sim_id)
  
  
  ###########################################################################
  # 2. DGP auswählen und Zeitreihe simulieren
  ###########################################################################
  
  if (dgp_name == "AR(1)") {
    
    y <- simulate_ar1(
      T = T,
      phi = 0.7,
      sigma = sigma
    )
    
  } else if (dgp_name == "MA(1)") {
    
    y <- simulate_ma1(
      T = T,
      theta = 0.6,
      sigma = sigma
    )
    
  } else if (dgp_name == "ARMA(1,1)") {
    
    y <- simulate_arma11(
      T = T,
      phi = 0.6,
      theta = 0.5,
      sigma = sigma
    )
    
  } else {
    
    stop("Unbekannter DGP: ", dgp_name)
    
  }
  
  
  ###########################################################################
  # 3. Lag-Features bauen
  ###########################################################################
  
  lag_data <- create_lags(
    y = y,
    max_lag = max_lag
  )
  
  
  ###########################################################################
  # 4. Train/Test-Split
  ###########################################################################
  
  split_data <- time_train_test_split(
    data = lag_data,
    train_prop = train_prop
  )
  
  train_data <- split_data$train
  test_data <- split_data$test
  
  
  ###########################################################################
  # 5. CV-Methoden festlegen
  ###########################################################################
  
  cv_methods <- c(
    "kfold",
    "loocv",
    "rolling_origin",
    "blocked",
    "hblock"
  )
  
  
  ###########################################################################
  # 6. Ergebniscontainer
  ###########################################################################
  
  sim_results <- data.frame()
  
  
  ###########################################################################
  # 7. Schleife über CV-Methoden
  ###########################################################################
  
  for (cv_method in cv_methods) {
    
    # Modelle mit aktueller CV-Methode vergleichen
    cv_results <- compare_models_cv(
      data = train_data,
      model_names = model_names,
      cv_method = cv_method
    )
    
    # Gewähltes Modell extrahieren
    selected_model <- cv_results$model[cv_results$selected_model]
    
    # CV-Fehler des gewählten Modells
    cv_error <- cv_results$cv_error[cv_results$selected_model]
    
    # Gewähltes Modell auf gesamtem Training fitten
    final_model <- fit_model_by_name(
      model_name = selected_model,
      train_data = train_data
    )
    
    # Echten Testfehler berechnen
    test_error <- evaluate_model(
      model = final_model,
      test_data = test_data
    )
    
    # Bias berechnen
    bias <- cv_error - test_error
    
    # Ergebnis speichern
    one_row <- data.frame(
      sim_id = sim_id,
      dgp = dgp_name,
      cv_method = cv_method,
      selected_model = selected_model,
      cv_error = cv_error,
      test_error = test_error,
      bias = bias
    )
    
    sim_results <- rbind(
      sim_results,
      one_row
    )
  }
  
  return(sim_results)
}


###############################################################################
# 2. Komplette Monte-Carlo-Simulation
###############################################################################

run_monte_carlo <- function(
    R = 10,
    dgp_names = c("AR(1)", "MA(1)", "ARMA(1,1)")
) {
  
  all_results <- data.frame()
  
  for (dgp_name in dgp_names) {
    
    for (sim_id in 1:R) {
      
      message(
        "DGP: ", dgp_name,
        " | Simulation: ", sim_id, " von ", R
      )
      
      sim_results <- run_one_simulation(
        sim_id = sim_id,
        dgp_name = dgp_name
      )
      
      all_results <- rbind(
        all_results,
        sim_results
      )
    }
  }
  
  return(all_results)
}


###############################################################################
# 3. Ergebnisse zusammenfassen
###############################################################################

summarise_monte_carlo <- function(results) {
  
  summary_results <- aggregate(
    cbind(cv_error, test_error, bias) ~ dgp + cv_method,
    data = results,
    FUN = mean
  )
  
  return(summary_results)
}


###############################################################################
# 4. Modellwahlhäufigkeiten berechnen
###############################################################################

summarise_model_selection <- function(results) {
  
  selection_table <- as.data.frame(
    table(
      results$dgp,
      results$cv_method,
      results$selected_model
    )
  )
  
  names(selection_table) <- c(
    "dgp",
    "cv_method",
    "selected_model",
    "count"
  )
  
  return(selection_table)
}

