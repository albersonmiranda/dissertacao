### TAREFA E LEARNERS ###


# meta pacote
pacman::p_load(
  mlr3verse,
  fabletools
)

# dados
train_data = readRDS("data/estban_ets_preds.rds") |>
  tibble::as_tibble(subset(select = -.model)) |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    names_sep = "x",
    values_from = ".fitted"
  ) |>
  janitor::clean_names()

new_data = readRDS("data/estban.RDS") |>
  tsibble::filter_index("2022 jan" ~ "2022 dec") |>
  tibble::as_tibble() |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    names_sep = "x",
    values_from = "saldo"
  ) |>
  janitor::clean_names()

# targets
target = names(train_data) |>
  grep(pattern = "aggregated|ref", invert = TRUE, value = TRUE)

# tasks
task = lapply(target, function(y_m) {
  TaskRegr$new(
    id = y_m,
    backend = subset(train_data, select = -ref),
    target = y_m
  )
})

# pipeline
pipeline = po("scale") %>>%
  po("encode", method = "treatment", affect_columns = selector_type("factor"))

# learners
learners = list(
  glmnet = as_learner(pipeline %>>% po("learner", lrn("regr.glmnet"))),
  glmnet_lasso = as_learner(pipeline %>>% po("learner", lrn("regr.glmnet"))),
  glmnet_ridge = as_learner(pipeline %>>% po("learner", lrn("regr.glmnet"))),
  xgb = as_learner(pipeline %>>% po("learner", lrn("regr.xgboost"))),
  ranger = as_learner(pipeline %>>% po("learner", lrn("regr.ranger")))
)

# ids
learners$xgb$id = "xgboost"
learners$ranger$id = "ranger"
learners$glmnet$id = "glmnet"
learners$glmnet_lasso$id = "glmnet_lasso"
learners$glmnet_ridge$id = "glmnet_ridge"
