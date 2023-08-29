source("scripts/reconcile_ml/2_task_learners.R")

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

xgb = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$xgb,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = term("stagnation", iters = 5)
)

## RANGER ##

# search space
search_space = ps(
  # profundidade máxima das árvores
  regr.max.depth = p_int(lower = 3, upper = 50),
  # número de variáveis selecionadas em cada árvore
  regr.mtry = p_int(lower = 5, upper = 200),
  # número mínimo de observações em um node terminal
  regr.min.node.size = p_int(lower = 1, upper = 10)
)

ranger = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$ranger,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = term("stagnation", iters = 5)
)

## GLMnet Lasso ##

# search space
search_space = ps(
  # alpha
  regr.glmnet.alpha = p_int(lower = 1, upper = 1)
)

# tuner
glmnet_lasso = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$glmnet,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = term("stagnation", iters = 5)
)

## GLMnet Ridge ##

# search space
search_space = ps(
  # alpha
  regr.glmnet.alpha = p_int(lower = 0, upper = 0)
)

# tuner
glmnet_ridge = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$glmnet,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = term("stagnation", iters = 5)
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
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = term("stagnation", iters = 5)
)

# substitute learners
leaners = list(
  xgb = xgb,
  ranger = ranger,
  glmnet = glmnet,
  glmnet_lasso = glmnet_lasso,
  glmnet_ridge = glmnet_ridge
)