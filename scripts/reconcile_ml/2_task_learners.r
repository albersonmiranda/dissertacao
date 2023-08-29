### TAREFA E LEARNERS ###


# reprodutibilidade
set.seed(123)

# meta pacote
pacman::p_load(
  mlr3verse,
  mlr3temporal,
  fabletools
)

# dados
train_data = readRDS("data/estban_ets_preds.RDS") |>
  tibble::as_tibble(subset(select = -.model)) |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
    values_from = ".fitted"
  ) |>
  janitor::clean_names()

test_data = readRDS("data/estban.RDS") |>
  tsibble::filter_index("2016 jan" ~ "2021 dec") |>
  tibble::as_tibble() |>
  tidyr::pivot_wider(
    id_cols = c("ref"),
    names_from = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
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
  xgb = as_learner(pipeline %>>% po("learner", lrn("regr.xgboost"))),
  ranger = as_learner(pipeline %>>% po("learner", lrn("regr.ranger")))
)
