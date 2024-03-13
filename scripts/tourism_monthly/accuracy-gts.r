# adiciona RMSSE à função
# TODO: issue + PR no pacote {hts}

accuracy.gts_new <- function(object, test, levels, ..., f = NULL) {
  # Compute in-sample or out-of-sample accuracy measures
  #
  # Args:
  #   f: forcasts
  #   test: Test set. If it's missing, default is in-sample accuracy for the
  #         bottom level, when keep.fitted is set to TRUE in the forecast.gts().
  #   levels: If computing out-of-sample accuracy, users can select whatever
  #           levels they like.
  #
  # Returns:
  #   Accuracy measures
  #
  # Error Handling:
  if (!is.null(f)) {
    warning("Using `f` as the argument for `accuracy()` is deprecated. Please use `object` instead.")
    object <- f
  }
  if (!hts::is.gts(object)) {
    stop("Argument f must be a grouped time series.", call. = FALSE)
  }
  if (!missing(test) && !hts::is.gts(test)) {
    stop("Argument test must be a grouped time series.", call. = FALSE)
  }

  if (missing(test)) {
    if (is.null(object$fitted)) {
      stop("No fitted values available for historical times, and no actual values available for future times", call. = FALSE)
    }

    x <- unclass(object$histy) # Unclass mts to matrix
    res <- x - unclass(object$fitted) # f$residuals may contain errors
    levels <- ifelse(hts::is.hts(object), length(object$nodes),
      nrow(object$groups) - 1L
    )
  } else {
    fcasts <- unclass(hts::aggts(object, levels, forecasts = TRUE))
    x <- unclass(hts::aggts(test, levels))
    tspf <- tsp(fcasts)
    tspx <- tsp(x)
    start <- max(tspf[1], tspx[1])
    end <- min(tspf[2], tspx[2])
    start <- min(start, end)
    end <- max(start, end)
    fcasts <- window(fcasts, start = start, end = end)
    x <- window(x, start = start, end = end)
    res <- x - fcasts
  }

  if (is.null(object$histy)) {
    histy <- NULL
  } else {
    histy <- hts::aggts(object, levels, forecasts = FALSE)
  }
  if (!is.null(histy)) {
    # MASE
    scale <- colMeans(abs(diff(histy, lag = max(1, round(stats::frequency(histy))))), na.rm = TRUE)
    q <- sweep(res, 2, scale, "/")
    mase <- colMeans(abs(q), na.rm = TRUE)
    # RMSSE
    mse = colMeans(res^2, na.rm = TRUE)
    scale_rmsse <- colMeans(diff(histy, lag = max(1, round(stats::frequency(histy))))^2, na.rm = TRUE)
    rmsse = sqrt(mse / scale_rmsse)
  }
  pe <- res / x * 100 # percentage error

  me <- colMeans(res, na.rm = TRUE)
  rmse <- sqrt(colMeans(res^2, na.rm = TRUE))
  mae <- colMeans(abs(res), na.rm = TRUE)
  mape <- colMeans(abs(pe), na.rm = TRUE)
  mpe <- colMeans(pe, na.rm = TRUE)

  out <- rbind(me, rmse, mae, mape, mpe)
  rownames(out) <- c("ME", "RMSE", "MAE", "MAPE", "MPE")
  if (exists("mase") || exists("rmsse")) {
    out <- rbind(out, mase, rmsse)
    rownames(out)[6L] <- "MASE"
    rownames(out)[7L] <- "RMSSE"
  }
  if (exists("fcasts")) {
    colnames(out) <- colnames(fcasts)
  }
  return(out)
}
