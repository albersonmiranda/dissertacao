### TAREFA E LEARNERS ###


# meta pacote
library(mlr3verse)
library(mlr3temporal)

# dados
estban = readRDS("data/estban.RDS")

# reprodutibilidade
set.seed(123)

# widen dataframe
estban = tidyr::pivot_wider(
  tibble::as_tibble(estban),
  id_cols = c("ref"),
  names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
  values_from = "saldo"
)

# tarefa
task = TaskRegr$new(
  "producao",
  backend = subset(data, select = variaveis),
  target = "producao"
)

# split treino e teste
split = partition(task, ratio = 0.9)

# pipeline
pipeline = po("scale") %>>%
  po("encode", method = "treatment", affect_columns = selector_type("factor"))

# learners
learners = list(
  glmnet = as_learner(pipeline %>>% po("learner", lrn("regr.rpart"))),
  lm = as_learner(pipeline %>>% po("learner", lrn("regr.lm"))),
  xgb = as_learner(pipeline %>>% po("learner", lrn("regr.xgboost"))),
  random_forest = as_learner(pipeline %>>% po("learner", lrn("regr.randomForest")))
)