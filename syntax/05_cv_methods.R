###############################################################################
# Projekt: SML Time Series Cross-Validation
# Datei: syntax/05_cv_methods.R
#
# Zweck:
# Vier Cross-Validation-Methoden für die zentrale Zeitreihenstudie.
###############################################################################

make_contiguous_folds <- function(n, k) {
  if (k < 2 || k > n) {
    stop("k muss zwischen 2 und n liegen.")
  }

  fold_sizes <- rep(floor(n / k), k)
  remainder <- n %% k
  if (remainder > 0) {
    fold_sizes[seq_len(remainder)] <- fold_sizes[seq_len(remainder)] + 1
  }

  folds <- vector("list", k)
  start <- 1
  for (i in seq_len(k)) {
    end <- start + fold_sizes[i] - 1
    folds[[i]] <- start:end
    start <- end + 1
  }
  folds
}

fit_predict_for_split <- function(data, train_index, validation_index, config) {
  if (length(train_index) <= config$primary_max_lag + 1) {
    stop("Zu wenige Trainingsbeobachtungen im CV-Split.")
  }
  if (length(validation_index) < 1) {
    stop("Leerer Validierungsblock im CV-Split.")
  }

  model <- fit_primary_model(data[train_index, , drop = FALSE], config)
  predicted <- predict_model(model, data[validation_index, , drop = FALSE])

  data.frame(
    row_index = validation_index,
    time = data$time[validation_index],
    actual = data$y[validation_index],
    predicted = predicted,
    squared_error = (data$y[validation_index] - predicted)^2
  )
}

build_cv_result <- function(method, data, predictions, splits, runtime_seconds, k, h) {
  if (nrow(predictions) == 0) {
    stop("Keine Validierungsvorhersagen erzeugt für ", method)
  }
  if (!all(is.finite(predictions$squared_error))) {
    stop("Nicht-endliche Validierungsfehler für ", method)
  }

  list(
    cv_method = method,
    cv_mse = mean(predictions$squared_error),
    n_validation_predictions = nrow(predictions),
    predictions = predictions,
    splits = splits,
    runtime_seconds = as.numeric(runtime_seconds),
    k = k,
    h = h
  )
}

cv_kfold <- function(data, config, seed) {
  start_time <- Sys.time()
  k <- config$n_cv_splits
  n <- nrow(data)
  set.seed(seed)
  fold_id <- sample(rep(seq_len(k), length.out = n))

  predictions <- data.frame()
  splits <- data.frame()

  for (fold in seq_len(k)) {
    validation_index <- which(fold_id == fold)
    train_index <- which(fold_id != fold)
    pred <- fit_predict_for_split(data, train_index, validation_index, config)
    pred$split_id <- fold
    predictions <- rbind(predictions, pred)

    splits <- rbind(splits, data.frame(
      cv_method = "kfold",
      split_id = fold,
      train_n = length(train_index),
      validation_n = length(validation_index),
      train_time_min = min(data$time[train_index]),
      train_time_max = max(data$time[train_index]),
      validation_time_min = min(data$time[validation_index]),
      validation_time_max = max(data$time[validation_index]),
      validation_contiguous = FALSE,
      uses_future_training = TRUE,
      h = NA_integer_
    ))
  }

  build_cv_result("kfold", data, predictions, splits, Sys.time() - start_time, k, NA_integer_)
}

cv_blocked <- function(data, config) {
  start_time <- Sys.time()
  k <- config$n_cv_splits
  folds <- make_contiguous_folds(nrow(data), k)
  predictions <- data.frame()
  splits <- data.frame()

  for (fold in seq_len(k)) {
    validation_index <- folds[[fold]]
    train_index <- setdiff(seq_len(nrow(data)), validation_index)
    pred <- fit_predict_for_split(data, train_index, validation_index, config)
    pred$split_id <- fold
    predictions <- rbind(predictions, pred)

    splits <- rbind(splits, data.frame(
      cv_method = "blocked",
      split_id = fold,
      train_n = length(train_index),
      validation_n = length(validation_index),
      train_time_min = min(data$time[train_index]),
      train_time_max = max(data$time[train_index]),
      validation_time_min = min(data$time[validation_index]),
      validation_time_max = max(data$time[validation_index]),
      validation_contiguous = TRUE,
      uses_future_training = max(data$time[train_index]) > max(data$time[validation_index]),
      h = NA_integer_
    ))
  }

  build_cv_result("blocked", data, predictions, splits, Sys.time() - start_time, k, NA_integer_)
}

cv_hblock <- function(data, config) {
  start_time <- Sys.time()
  k <- config$n_cv_splits
  h <- config$h_block
  folds <- make_contiguous_folds(nrow(data), k)
  predictions <- data.frame()
  splits <- data.frame()

  for (fold in seq_len(k)) {
    validation_index <- folds[[fold]]
    buffer_start <- max(1, min(validation_index) - h)
    buffer_end <- min(nrow(data), max(validation_index) + h)
    removed_index <- buffer_start:buffer_end
    train_index <- setdiff(seq_len(nrow(data)), removed_index)

    if (length(train_index) <= config$primary_max_lag + 1) {
      stop("h-block erzeugt zu wenige Trainingsdaten in Split ", fold)
    }

    pred <- fit_predict_for_split(data, train_index, validation_index, config)
    pred$split_id <- fold
    predictions <- rbind(predictions, pred)

    train_times <- data$time[train_index]
    val_times <- data$time[validation_index]
    buffer_times <- data$time[removed_index]

    splits <- rbind(splits, data.frame(
      cv_method = "hblock",
      split_id = fold,
      train_n = length(train_index),
      validation_n = length(validation_index),
      train_time_min = min(train_times),
      train_time_max = max(train_times),
      validation_time_min = min(val_times),
      validation_time_max = max(val_times),
      validation_contiguous = TRUE,
      uses_future_training = max(train_times) > max(val_times),
      h = h,
      removed_time_min = min(buffer_times),
      removed_time_max = max(buffer_times)
    ))
  }

  build_cv_result("hblock", data, predictions, splits, Sys.time() - start_time, k, h)
}

cv_rolling_origin <- function(data, config) {
  start_time <- Sys.time()
  k <- config$n_cv_splits
  n <- nrow(data)
  initial_train_size <- floor(0.5 * n)
  validation_size <- ceiling((n - initial_train_size) / k)

  predictions <- data.frame()
  splits <- data.frame()
  train_end <- initial_train_size

  for (fold in seq_len(k)) {
    validation_start <- train_end + 1
    if (validation_start > n) {
      break
    }
    validation_end <- min(train_end + validation_size, n)
    train_index <- seq_len(train_end)
    validation_index <- validation_start:validation_end

    if (max(train_index) >= min(validation_index)) {
      stop("Rolling-origin verletzt die Zeitrichtung in Split ", fold)
    }

    pred <- fit_predict_for_split(data, train_index, validation_index, config)
    pred$split_id <- fold
    predictions <- rbind(predictions, pred)

    splits <- rbind(splits, data.frame(
      cv_method = "rolling_origin",
      split_id = fold,
      train_n = length(train_index),
      validation_n = length(validation_index),
      train_time_min = min(data$time[train_index]),
      train_time_max = max(data$time[train_index]),
      validation_time_min = min(data$time[validation_index]),
      validation_time_max = max(data$time[validation_index]),
      validation_contiguous = TRUE,
      uses_future_training = FALSE,
      h = NA_integer_
    ))

    train_end <- validation_end
  }

  build_cv_result("rolling_origin", data, predictions, splits, Sys.time() - start_time, k, NA_integer_)
}

run_cv_method <- function(method, data, config, seed) {
  if (method == "kfold") {
    return(cv_kfold(data, config, seed))
  }
  if (method == "blocked") {
    return(cv_blocked(data, config))
  }
  if (method == "hblock") {
    return(cv_hblock(data, config))
  }
  if (method == "rolling_origin") {
    return(cv_rolling_origin(data, config))
  }
  stop("Unbekannte CV-Methode: ", method)
}

