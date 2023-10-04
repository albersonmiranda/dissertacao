### TAREFA E LEARNERS ###


# meta pacote
pacman::p_load(
  mlr3verse,
  fabletools
)

# dados
true_data = readRDS("data/estban.rds") |>
  tibble::as_tibble(subset(select = -.model)) |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    names_sep = "x",
    values_from = "saldo"
  ) |>
  janitor::clean_names() |>
  subset(ref >= tsibble::yearmonth("2013 jan") & ref <= tsibble::yearmonth("2021 dec"))

# add suffix to colnames
names(true_data) = paste0(names(true_data), "_true")

train_data = readRDS("data/estban_ets_preds.rds") |>
  tibble::as_tibble(subset(select = -.model)) |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    names_sep = "x",
    values_from = ".fitted"
  ) |>
  janitor::clean_names() |>
  cbind(subset(true_data, select = -ref_true))

test_set = readRDS("data/estban.RDS") |>
  tsibble::filter_index("2022 jan" ~ "2022 dec") |>
  tibble::as_tibble() |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    names_sep = "x",
    values_from = "saldo"
  ) |>
  janitor::clean_names()

new_data_estatica = readRDS("data/previsoes_base_estatica.rds") |>
  tibble::as_tibble() |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    names_sep = "x",
    values_from = ".mean"
  ) |>
  janitor::clean_names()

# targets
target = names(train_data) |>
  grep(pattern = "(?!.*aggregated|.*ref)^.*true.*$", value = TRUE, perl = TRUE)

# tasks
task = lapply(target, function(y_m) {
  target = subset(train_data, select = y_m)
  data = cbind(dplyr::select(train_data, -tidyselect::matches("true|ref")), target)
  TaskRegr$new(
    id = y_m,
    backend = data,
    target = y_m
  )
})

# pipeline
pipeline = po("encode", method = "treatment", affect_columns = selector_type("factor"))

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
