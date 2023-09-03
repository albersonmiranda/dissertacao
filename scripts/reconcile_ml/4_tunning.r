### TUNNING ###


# Inner resampling performance > outer resampling
# performance means overfit. Resampling models isn't
# made for prediction or even model selection,
# but only for tunning purposes and assessment of "real"
# in-sample performance.
#
# Prediction is obtained after tunning and selection,
# with a model trained with all available data.
#
# Model selection depends on test set performance of
# a tuned model.

source("scripts/reconcile_ml/3_hyperparameters.r")

# outer resampling
outer_resampling = rsmp("repeated_cv", repeats = 2, folds = 3)

# benchmark design
design = benchmark_grid(task, learners, outer_resampling)

# Runs the inner loop in parallel and the outer loop sequentially
future::plan(list("sequential", "multisession"))

# benchmark execution
bmr = benchmark(design, store_models = TRUE) |> progressr::with_progress()
results = bmr$aggregate(msrs("regr.rmse", "time_both"))[, 3:7]

# resultados
aggregate(regr.rmse ~ learner_id, data = results, FUN = mean)
autoplot(bmr, measure = msr("regr.rmse")) +
  ggplot2::scale_y_continuous(labels = scales::number_format(scale = 1 / 1000)) +
  ggplot2::labs(
    y = "RMSE (mil)"
  )

# optimal configurations
extract_inner_tuning_results(bmr)
