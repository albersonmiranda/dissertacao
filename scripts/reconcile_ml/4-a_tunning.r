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

# reprodutibilidade
set.seed(123)

# outer resampling
outer_resampling = rsmp("cv", folds = 3)

# benchmark design
design = benchmark_grid(task, list(learners$xgb, learners$ranger), outer_resampling)

# Runs the inner loop in parallel and the outer loop sequentially
future::plan(list("sequential", "multisession"))

# benchmark execution
bmr = benchmark(design, store_models = FALSE) |> progressr::with_progress()
results = bmr$aggregate(list(msr("regr.rmse"), msr("time_both")))[, 3:8]

# resultados
aggregate(regr.rmse ~ learner_id, data = results, FUN = mean)
autoplot(bmr, measure = msr("regr.rmse")) +
  ggplot2::scale_y_continuous(labels = scales::number_format(scale = 1 / 1000)) +
  ggplot2::labs(
    y = "RMSE (mil)"
  )

# optimal configurations
extract_inner_tuning_results(bmr)

# save results
saveRDS(bmr, "data/bmr_a.rds")
