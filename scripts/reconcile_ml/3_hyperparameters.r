source("1_task_learners.R")

## XGBOOST ##

# search space
search_space = ps(
  # velocidade de aprendizado
  regr.xgboost.eta = p_dbl(lower = 0.1, upper = 0.3),
  regr.xgboost.min_child_weight = p_dbl(lower = 1, upper = 20),
  # número de interações
  regr.xgboost.nrounds = p_int(lower = 50, upper = 1000),
  # profundidade das árvores
  regr.xgboost.max_depth = p_int(lower = 1, upper = 10)
)

# tuner
xgb_tuned = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$xgb,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  term_evals = 10,
)

## RANGER ##

# search space
search_space = ps(
  # velocidade de aprendizado
  regr.xgboost.eta = p_dbl(lower = 0.1, upper = 0.3),
  regr.xgboost.min_child_weight = p_dbl(lower = 1, upper = 20),
  # número de interações
  regr.xgboost.nrounds = p_int(lower = 50, upper = 1000),
  # profundidade das árvores
  regr.xgboost.max_depth = p_int(lower = 1, upper = 10)
)

# tuner
xgb_tuned = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$xgb,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  term_evals = 10,
)

## GLMNET ##

# search space
search_space = ps(
  # velocidade de aprendizado
  regr.xgboost.eta = p_dbl(lower = 0.1, upper = 0.3),
  regr.xgboost.min_child_weight = p_dbl(lower = 1, upper = 20),
  # número de interações
  regr.xgboost.nrounds = p_int(lower = 50, upper = 1000),
  # profundidade das árvores
  regr.xgboost.max_depth = p_int(lower = 1, upper = 10)
)

# tuner
xgb_tuned = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$xgb,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  term_evals = 10,
)