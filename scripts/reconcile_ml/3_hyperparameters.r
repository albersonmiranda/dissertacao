### ESPAÇO DE HIPERPARÂMETROS ###


source("scripts/reconcile_ml/2_task_learners.r")
source("scripts/reconcile_ml/trafos.r")

## XGBOOST ##

# search space
search_space = ps(
  # taxa de aprendizado diminui a contriubição de cada atualização de reforço
  regr.xgboost.eta = p_dbl(lower = -4, upper = 0),
  # número de interações de reforço
  regr.xgboost.nrounds = p_int(lower = 1, upper = 5000),
  # profundidade máxima de uma árvore
  regr.xgboost.max_depth = p_int(lower = 1, upper = 20),
  # taxa de subamostragem de colunas para uma árvore
  regr.xgboost.colsample_bytree = p_dbl(lower = 0.1, upper = 1),
  # taxa de subamostragem de colunas para cada nível de profundidade
  regr.xgboost.colsample_bylevel = p_dbl(lower = 0.1, upper = 1),
  # regularização com penalidade norma L2
  regr.xgboost.lambda = p_dbl(lower = -10, upper = 10),
  # regularização com penalidade norma L1
  regr.xgboost.alpha = p_dbl(lower = -10, upper = 10),
  # subsample
  regr.xgboost.subsample = p_dbl(lower = 0.1, upper = 1)
)

# transformação
search_space$trafo = trafo_xgb

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
  # quantidade mínima de observações no nó a ser dividido
  regr.ranger.min.node.size = p_int(lower = 1, upper = 7),
  # quantidade mínima de observações no nó folha
  regr.ranger.min.bucket = p_int(lower = 1, upper = 6),
  # número de variáveis candidatas para divisão a cada divsão
  regr.ranger.mtry = p_int(lower = 2, upper = ncol(train_data) - 2),
  # as observações são selecionadas com ou sem reposição
  regr.ranger.replace = p_lgl(),
  # proporção de observações selecionadas aleatoriamente
  regr.ranger.sample.fraction = p_dbl(lower = 0.1, upper = 1),
  # número de árvores
  regr.ranger.num.trees = p_int(lower = 1, upper = 2000)
)

# transformação
search_space$trafo = trafo_ranger

ranger = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$ranger,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

## Elastic net ##

# search space
search_space = ps(
  # determina mistura entre lasso e ridge
  regr.glmnet.alpha = p_dbl(lower = 0, upper = 1),
  # controla regularização
  regr.glmnet.s = p_dbl(lower = -12, upper = 12)
)

# transformação
search_space$trafo = trafo_glmnet

# tuner
glmnet = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$glmnet,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

## Lasso ##

# search space
search_space = ps(
  # controla regularização
  regr.glmnet.s = p_dbl(lower = -12, upper = 12)
)

# transformação
search_space$trafo = trafo_glmnet

# tuner
glmnet_lasso = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$glmnet_lasso,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

## Ridge ##

# search space
search_space = ps(
  # controla regularização
  regr.glmnet.s = p_dbl(lower = -12, upper = 12)
)

# transformação
search_space$trafo = trafo_glmnet

# tuner
glmnet_ridge = auto_tuner(
  tuner = tnr("mbo"),
  learner = learners$glmnet_ridge,
  resampling = rsmp("cv", folds = 10),
  measure = msr("regr.rmse"),
  search_space = search_space,
  terminator = trm("stagnation", iters = 5)
)

# atualizando learners
learners = list(
  xgb = xgb,
  ranger = ranger,
  glmnet = glmnet,
  glmnet_lasso = glmnet_lasso,
  glmnet_ridge = glmnet_ridge
)
