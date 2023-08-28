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

source("3_hyperparameters.R")

# learners tunados
learners_t = c(
  learners,
  xgb_tuned = xgb_tuned
)

# outer resampling
outer_resampling = rsmp("cv", folds = 5)

# benchmark design
design = benchmark_grid(task, learners_t, outer_resampling)

# benchmark execution
bmr = benchmark(design, store_models = TRUE)
bmr$aggregate(msr("regr.rmse"))[, 3:7]
autoplot(bmr, measure = msr("regr.rmse"))

# optimal configurations
extract_inner_tuning_results(bmr)
