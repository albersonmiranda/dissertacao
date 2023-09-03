source("scripts/reconcile_ml/2_task_learners.R")

## XGBOOST ##

# search space
search_space = ps(
  # velocidade de aprendizado
  regr.xgboost.eta = p_dbl(lower = 0.01, upper = 0.05),
  # subsample
  regr.xgboost.subsample = p_dbl(lower = 0.3, upper = 1),
  # colsample
  regr.xgboost.colsample_bytree = p_dbl(lower = 0.3, upper = 1),
  # minimum sum of instance weight (hessian) needed in a child
  regr.xgboost.min_child_weight = p_dbl(lower = 0, upper = 10),
  # número de interações
  regr.xgboost.nrounds = p_int(lower = 50, upper = 200),
  # profundidade das árvores
  regr.xgboost.max_depth = p_int(lower = 2, upper = 10),
  # gamma
  regr.xgboost.gamma = p_dbl(lower = 0, upper = 5)
)

xgb = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$xgb,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

## RANGER ##

# search space
search_space = ps(
  # número de árvores
  regr.ranger.num.trees = p_int(lower = 50, upper = 150),
  # número de variáveis selecionadas em cada árvore
  regr.ranger.mtry = p_int(lower = 2, upper = 6),
  # número mínimo de observações em um node terminal
  regr.ranger.min.node.size = p_int(lower = 10, upper = 50)
)

ranger = auto_tuner(
  tuner = tnr("grid_search", resolution = 5),
  learner = learners$ranger,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

## GLMnet ##

# search space
search_space = ps(
  # alpha
  regr.glmnet.alpha = p_int(lower = 0, upper = 1)
)

# tuner
glmnet = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$glmnet,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

# substitute learners
learners = list(
  xgb = xgb,
  ranger = ranger,
  glmnet = glmnet,
  glmnet_lasso = learners$glmnet_lasso,
  glmnet_ridge = learners$glmnet_ridge
)
