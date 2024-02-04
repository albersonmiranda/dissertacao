### TAREFA E LEARNERS ###


# meta pacote
pacman::p_load(
  mlr3verse,
  fabletools
)

# tipo de previsões treino: one-step-ahead, rolling_forecast ou fitted_base
tipo = "one-step-ahead"

# true data (y_t)
true_data = readRDS("data/tourism/tourism.rds") |>
  tibble::as_tibble(subset(select = -.model)) |>
  tidyr::pivot_wider(
    id_cols = c("Quarter"),
    names_from = c("State", "Region", "Purpose"),
    names_sep = "__",
    values_from = "Trips"
  ) |>
  subset(Quarter >= tsibble::yearquarter("2008 Q1") & Quarter <= tsibble::yearquarter("2015 Q4"))

# add suffix to colnames
names(true_data) = paste0(names(true_data), "__true")

# dados para treino do modelo de combinação
if (tipo == "one-step-ahead") {
  train_data = readRDS("data/tourism/preds_ml/train/preds.rds") |>
    tibble::as_tibble(subset(select = -.model)) |>
    tidyr::pivot_wider(
      id_cols = c("Quarter"),
      names_from = c("State", "Region", "Purpose"),
      names_sep = "__",
      values_from = ".fitted"
    ) |>
    subset(Quarter >= tsibble::yearquarter("2008 Q1") & Quarter <= tsibble::yearquarter("2015 Q4")) |>
    cbind(subset(true_data, select = -`Quarter__true`))
}

if (tipo == "rolling_forecast") {
  train_data = readRDS("data/tourism/preds_ml/train/preds_rolling.rds") |>
    tibble::as_tibble(subset(select = -.model)) |>
    tidyr::pivot_wider(
      id_cols = c("Quarter"),
      names_from = c("State", "Region", "Purpose"),
      names_sep = "__",
      values_from = ".mean"
    ) |>
    cbind(subset(true_data, select = -`Quarter__true`))
}

if (tipo == "fitted_base") {
  train_data = readRDS("data/tourism/previsoes_base/fitted_values.rds") |>
    tibble::as_tibble(subset(select = -.model)) |>
    tidyr::pivot_wider(
      id_cols = c("Quarter"),
      names_from = c("State", "Region", "Purpose"),
      names_sep = "__",
      values_from = ".fitted"
    ) |>
    subset(Quarter >= tsibble::yearquarter("2008 Q1") & Quarter <= tsibble::yearquarter("2015 Q4")) |>
    cbind(subset(true_data, select = -`Quarter__true`))
}

# limpar nomes de colunas
names(train_data) = gsub("<|>", "", names(train_data))
names(train_data) = paste0("x", names(train_data))

# previsões base
previsoes_base = readRDS("data/tourism/previsoes_base/previsoes_base.rds") |>
  tibble::as_tibble() |>
  tidyr::pivot_wider(
    id_cols = c("Quarter"),
    names_from = c("State", "Region", "Purpose"),
    names_sep = "__",
    values_from = ".mean"
  )

# limpar nomes de colunas
names(previsoes_base) = gsub("<|>", "", names(previsoes_base))
names(previsoes_base) = paste0("x", names(previsoes_base))

# targets
target = names(train_data) |>
  grep(pattern = "(?!.*aggregated|.*Quarter)^.*true.*$", value = TRUE, perl = TRUE)

# tasks
task = lapply(target, function(y_m) {
  target = subset(train_data, select = y_m)
  data = cbind(dplyr::select(train_data, -tidyselect::matches("true|Quarter")), target)
  TaskRegr$new(
    id = y_m,
    backend = data,
    target = y_m
  )
})

# pipeline
pipeline = po("imputehist", affect_columns = selector_type("numeric"))

# learners
learners = list(
  glmnet = as_learner(pipeline %>>% po("learner", lrn("regr.glmnet"))),
  glmnet_lasso = as_learner(pipeline %>>% po("learner", lrn("regr.glmnet"))),
  glmnet_ridge = as_learner(pipeline %>>% po("learner", lrn("regr.glmnet"))),
  xgb = as_learner(pipeline %>>% po("learner", lrn("regr.xgboost"))),
  ranger = as_learner(pipeline %>>% po("learner", lrn("regr.ranger"))),
  svm = as_learner(pipeline %>>% po("learner", lrn("regr.svm"))),
  lightgbm = as_learner(pipeline %>>% po("learner", lrn("regr.lightgbm")))
)

# ids
learners$xgb$id = "xgboost"
learners$ranger$id = "ranger"
learners$glmnet$id = "glmnet"
learners$glmnet_lasso$id = "glmnet_lasso"
learners$glmnet_ridge$id = "glmnet_ridge"
learners$svm$id = "svm"
learners$lightgbm$id = "lightgbm"
