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

source("scripts/tourism/reconcile_ml/3_benchmark_hp.r")

# reprodutibilidade
set.seed(123)

# outer resampling
outer_resampling = rsmp("repeated_cv", folds = 5, repeats = 2)

# benchmark design
design = benchmark_grid(
  task,
  list(
    learners$xgb,
    learners$ranger,
    learners$glmnet,
    learners$glmnet_lasso,
    learners$glmnet_ridge,
    learners$svm,
    learners$lightgbm
  ),
  outer_resampling
)

# Runs the inner loop in parallel and the outer loop sequentially
future::plan(list("sequential", "multisession"))

# benchmark execution
bmr = benchmark(design, store_models = FALSE, store_backends = FALSE) |> progressr::with_progress()

# results
results = bmr$aggregate(list(msr("regr.rmse"), msr("regr.mae"), msr("regr.mape"), msr("time_both")))[, 3:10]
aggregate(cbind(regr.rmse, regr.mae, regr.mape, time_both) ~ learner_id, data = results, FUN = mean)

# save results
saveRDS(bmr, "data/tourism/preds_ml/train/bmr.rds")
saveRDS(results, "data/tourism/preds_ml/train/bmr_results.rds")
