###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: R/05_cv_methods.R
#
# Zweck:
# Cross-Validation-Methoden für Forecasting-Modelle vergleichen.
#
# Enthaltene CV-Methoden:
# 1. k-fold CV
# 2. LOOCV
# 3. rolling-origin CV
# 4. blocked CV
# 5. h-block CV
###############################################################################


###############################################################################
# 1. Hilfsfunktion: Modell anhand des Modellnamens fitten
###############################################################################

fit_model_by_name <- function(model_name, train_data) {
  
  if (model_name == "LM-lag1") {
    
    model <- fit_lm_lag1(train_data)
    
  } else if (model_name == "LM-lag5") {
    
    model <- fit_lm_lag5(train_data)
    
  } else {
    
    stop("Unbekanntes Modell: ", model_name)
    
  }
  
  return(model)
}


###############################################################################
# 2. k-fold Cross-Validation
###############################################################################

# k-fold CV:
# Die Daten werden zufällig in k Gruppen aufgeteilt.
# Diese Methode ignoriert die Zeitstruktur und ist deshalb bei Zeitreihen
# methodisch problematisch, aber genau deswegen interessant für das Projekt.

cv_kfold <- function(data, model_name, k = 5, seed = 123) {
  
  set.seed(seed)
  
  n <- nrow(data)
  
  fold_id <- sample(rep(1:k, length.out = n))
  
  all_actual <- c()
  all_predicted <- c()
  
  for (fold in 1:k) {
    
    valid_data <- data[fold_id == fold, ]
    train_data <- data[fold_id != fold, ]
    
    model <- fit_model_by_name(
      model_name = model_name,
      train_data = train_data
    )
    
    predicted <- predict_model(
      model = model,
      new_data = valid_data
    )
    
    all_actual <- c(all_actual, valid_data$y)
    all_predicted <- c(all_predicted, predicted)
  }
  
  cv_error <- rmse(
    actual = all_actual,
    predicted = all_predicted
  )
  
  return(cv_error)
}


###############################################################################
# 3. LOOCV
###############################################################################

# LOOCV = Leave-One-Out Cross-Validation.
#
# Jede Beobachtung wird einmal als Validierungspunkt verwendet.
# Alle anderen Beobachtungen werden als Training verwendet.
#
# Achtung:
# Bei Zeitreihen ist das problematisch, weil Punkte vor und nach dem
# Validierungspunkt im Training liegen können.

cv_loocv <- function(data, model_name) {
  
  n <- nrow(data)
  
  all_actual <- c()
  all_predicted <- c()
  
  for (i in 1:n) {
    
    valid_data <- data[i, ]
    train_data <- data[-i, ]
    
    model <- fit_model_by_name(
      model_name = model_name,
      train_data = train_data
    )
    
    predicted <- predict_model(
      model = model,
      new_data = valid_data
    )
    
    all_actual <- c(all_actual, valid_data$y)
    all_predicted <- c(all_predicted, predicted)
  }
  
  cv_error <- rmse(
    actual = all_actual,
    predicted = all_predicted
  )
  
  return(cv_error)
}


###############################################################################
# 4. rolling-origin Cross-Validation
###############################################################################

# rolling-origin CV:
# Es wird immer nur mit der Vergangenheit trainiert
# und auf einen späteren Punkt oder Block validiert.
#
# Beispiel:
# Training: 1-100    Validierung: 101
# Training: 1-110    Validierung: 111
# Training: 1-120    Validierung: 121

cv_rolling_origin <- function(data, model_name, initial_train_size = 100, horizon = 1, step = 10) {
  
  n <- nrow(data)
  
  all_actual <- c()
  all_predicted <- c()
  
  train_ends <- seq(
    from = initial_train_size,
    to = n - horizon,
    by = step
  )
  
  for (train_end in train_ends) {
    
    train_data <- data[1:train_end, ]
    
    valid_start <- train_end + 1
    valid_end <- train_end + horizon
    
    valid_data <- data[valid_start:valid_end, ]
    
    model <- fit_model_by_name(
      model_name = model_name,
      train_data = train_data
    )
    
    predicted <- predict_model(
      model = model,
      new_data = valid_data
    )
    
    all_actual <- c(all_actual, valid_data$y)
    all_predicted <- c(all_predicted, predicted)
  }
  
  cv_error <- rmse(
    actual = all_actual,
    predicted = all_predicted
  )
  
  return(cv_error)
}


###############################################################################
# 5. blocked Cross-Validation
###############################################################################

# blocked CV:
# Die Zeitreihe wird in zusammenhängende Blöcke geteilt.
# Jeder Block wird einmal als Validierungsblock verwendet.
#
# Im Gegensatz zu k-fold werden hier keine zufälligen Einzelpunkte gemischt,
# sondern zeitlich zusammenhängende Abschnitte verwendet.

cv_blocked <- function(data, model_name, k = 5) {
  
  n <- nrow(data)
  
  fold_id <- rep(1:k, length.out = n)
  fold_id <- sort(fold_id)
  
  all_actual <- c()
  all_predicted <- c()
  
  for (fold in 1:k) {
    
    valid_data <- data[fold_id == fold, ]
    train_data <- data[fold_id != fold, ]
    
    model <- fit_model_by_name(
      model_name = model_name,
      train_data = train_data
    )
    
    predicted <- predict_model(
      model = model,
      new_data = valid_data
    )
    
    all_actual <- c(all_actual, valid_data$y)
    all_predicted <- c(all_predicted, predicted)
  }
  
  cv_error <- rmse(
    actual = all_actual,
    predicted = all_predicted
  )
  
  return(cv_error)
}


###############################################################################
# 6. h-block Cross-Validation
###############################################################################

# h-block CV:
# Wie LOOCV, aber um den Validierungspunkt herum wird ein Pufferbereich entfernt.
#
# Beispiel mit h = 2:
# Validierungspunkt: i
# Entfernt aus Training: i-2, i-1, i, i+1, i+2
#
# Dadurch wird verhindert, dass sehr nahe Nachbarpunkte im Training liegen.

cv_hblock <- function(data, model_name, h = 5) {
  
  n <- nrow(data)
  
  all_actual <- c()
  all_predicted <- c()
  
  for (i in 1:n) {
    
    valid_data <- data[i, ]
    
    remove_start <- max(1, i - h)
    remove_end <- min(n, i + h)
    
    remove_index <- remove_start:remove_end
    
    train_data <- data[-remove_index, ]
    
    # Falls zu wenig Trainingsdaten übrig bleiben, überspringen
    if (nrow(train_data) < 20) {
      next
    }
    
    model <- fit_model_by_name(
      model_name = model_name,
      train_data = train_data
    )
    
    predicted <- predict_model(
      model = model,
      new_data = valid_data
    )
    
    all_actual <- c(all_actual, valid_data$y)
    all_predicted <- c(all_predicted, predicted)
  }
  
  cv_error <- rmse(
    actual = all_actual,
    predicted = all_predicted
  )
  
  return(cv_error)
}


###############################################################################
# 7. Mehrere Modelle mit einer CV-Methode vergleichen
###############################################################################

compare_models_cv <- function(data, model_names, cv_method = "kfold") {
  
  results <- data.frame(
    model = model_names,
    cv_error = NA_real_
  )
  
  for (i in seq_along(model_names)) {
    
    model_name <- model_names[i]
    
    if (cv_method == "kfold") {
      
      error <- cv_kfold(
        data = data,
        model_name = model_name,
        k = 5
      )
      
    } else if (cv_method == "loocv") {
      
      error <- cv_loocv(
        data = data,
        model_name = model_name
      )
      
    } else if (cv_method == "rolling_origin") {
      
      error <- cv_rolling_origin(
        data = data,
        model_name = model_name,
        initial_train_size = 100,
        horizon = 1,
        step = 10
      )
      
    } else if (cv_method == "blocked") {
      
      error <- cv_blocked(
        data = data,
        model_name = model_name,
        k = 5
      )
      
    } else if (cv_method == "hblock") {
      
      error <- cv_hblock(
        data = data,
        model_name = model_name,
        h = 5
      )
      
    } else {
      
      stop("Unbekannte CV-Methode: ", cv_method)
      
    }
    
    results$cv_error[i] <- error
  }
  
  # Bestes Modell markieren
  results$selected_model <- results$cv_error == min(results$cv_error)
  
  return(results)
}