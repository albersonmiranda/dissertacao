### ESPAÇO DE HIPERPARÂMETROS ###


source("scripts/reconcile_ml/2_task_learners.r")
source("scripts/reconcile_ml/trafos.r")

# configurações
tuner = tnr("mbo")
inner_resampling = rsmp("cv", folds = 10)
measure = msr("regr.rmse")
terminator = trm("combo", list(
  trm("stagnation", iters = 3),
  trm("stagnation_batch", n = 3)
), any = TRUE)

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
  tuner = tuner,
  learner = learners$xgb,
  resampling = inner_resampling,
  measure = measure,
  search_space = search_space,
  terminator = terminator
)

## RANGER ##

# search space
search_space = ps(
  # quantidade mínima de observações no nó a ser dividido
  regr.ranger.min.node.size = p_int(lower = 1, upper = 7),
  # número de variáveis candidatas para divisão a cada divsão
  regr.ranger.mtry = p_int(lower = 2, upper = ncol(train_data) - 2),
  # as observações são selecionadas com ou sem reposição
  regr.ranger.replace = p_lgl(default = TRUE),
  # proporção de observações selecionadas aleatoriamente
  regr.ranger.sample.fraction = p_dbl(lower = 0.1, upper = 1, depends = regr.ranger.replace == TRUE),
  # número de árvores
  regr.ranger.num.trees = p_int(lower = 1, upper = 2000)
)

# transformação
search_space$trafo = trafo_ranger

ranger = auto_tuner(
  tuner = tuner,
  learner = learners$ranger,
  resampling = inner_resampling,
  measure = measure,
  search_space = search_space,
  terminator = terminator
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
  tuner = tuner,
  learner = learners$glmnet,
  resampling = inner_resampling,
  measure = measure,
  search_space = search_space,
  terminator = terminator
)

## Lasso ##

# search space
search_space = ps(
  # determina mistura entre lasso e ridge
  regr.glmnet.alpha = p_dbl(lower = 1, upper = 1),
  # controla regularização
  regr.glmnet.s = p_dbl(lower = -12, upper = 12)
)

# transformação
search_space$trafo = trafo_glmnet

# tuner
glmnet_lasso = auto_tuner(
  tuner = tuner,
  learner = learners$glmnet_lasso,
  resampling = inner_resampling,
  measure = measure,
  search_space = search_space,
  terminator = terminator
)

## Ridge ##

# search space
search_space = ps(
  # determina mistura entre lasso e ridge
  regr.glmnet.alpha = p_dbl(lower = 0, upper = 0),
  # controla regularização
  regr.glmnet.s = p_dbl(lower = -12, upper = 12)
)

# transformação
search_space$trafo = trafo_glmnet

# tuner
glmnet_ridge = auto_tuner(
  tuner = tuner,
  learner = learners$glmnet_ridge,
  resampling = inner_resampling,
  measure = measure,
  search_space = search_space,
  terminator = terminator
)

# atualizando learners
learners = list(
  xgb = xgb,
  ranger = ranger,
  glmnet = glmnet,
  glmnet_lasso = glmnet_lasso,
  glmnet_ridge = glmnet_ridge
)
