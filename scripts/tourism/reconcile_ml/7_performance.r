### PERFORMANCE


# pacotes
library(fabletools)

# tipo de previsões treino: one-step-ahead, rolling_forecast ou fitted_base
tipo = "rolling_forecast"

# juntando predições em um único dataframe
preds = lapply(c("xgb", "ranger", "glmnet", "lasso", "ridge", "svm", "nnet", "lightgbm"), function(learner) {
  preds = readRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_", learner, ".RDS"))
  preds = lapply(preds[[1]], function(df) data.table::as.data.table(df) |> subset(select = response))
  preds = do.call(cbind, preds)
  # adicionando coluna Quarter
  preds$Quarter = tsibble::yearquarter(seq(as.Date("2016-01-01"), as.Date("2017-12-01"), by = "quarter"))
  return(preds)
})

# nomeando a lista
names(preds) = c("xgb", "ranger", "glmnet", "lasso", "ridge", "svm", "nnet", "lightgbm")

# remover primeiro caractere do nome das colunas
preds = lapply(preds, function(df) {
  names(df) = gsub("^.", "", names(df))
  return(df)
})

# renomeando coluna ef para Quarter
preds = lapply(preds, function(df) {
  names(df)[names(df) == "uarter"] = "Quarter"
  return(df)
})

# alongando dataframe preds
preds = lapply(preds, function(df) {
  df = df |>
    tidyr::pivot_longer(
      cols = -Quarter,
      names_to = c("State", "Region", "Purpose", "tipo"),
      values_to = "prediction",
      names_sep = "__"
    ) |>
    subset(select = -tipo)
  return(df)
})

# adicionar coluna modelo
preds = lapply(names(preds), function(learner) {
  preds[[learner]]$modelo = learner
  return(preds[[learner]])
})

# juntando todos os dataframes em um único
preds = do.call(rbind, preds)

# tourism dataset
tourism = readRDS("data/tourism/tourism.rds")

# remover agregados
tourism = tourism |>
  subset(
    !is_aggregated(State) &
      !is_aggregated(Region) &
      !is_aggregated(Purpose)
  ) |>
  as.data.frame()

# convertendo coluna Quarter para character
preds$Quarter = as.character(preds$Quarter)
tourism$Quarter = as.character(tourism$Quarter)

# convertendo colunas chr* do dataframe tourism para character
tourism = within(tourism, {
  State = as.character(State)
  Region = as.character(Region)
  Purpose = as.character(Purpose)
})

# merge entre tourism e preds
data = merge(tourism, preds, all.x = TRUE)

# teste se merge foi completo
nrow(subset(data, !is.na(prediction))) == nrow(preds)

# agregando
data = data |>
  transform(Quarter = tsibble::yearquarter(Quarter)) |>
  tsibble::as_tsibble(
    key = c(
      "State",
      "Region",
      "Purpose",
      "modelo"
    ),
    index = Quarter
  ) |>
  fabletools::aggregate_key(
    (State / Region) * Purpose * modelo,
    Trips = sum(Trips),
    prediction = sum(prediction)
  )

# adicionando primeiras diferenças
data = data |>
  dplyr::group_by(State, Purpose, modelo, Region) |>
  dplyr::mutate(
    diff = abs(tsibble::difference(Trips, lag = 4)),
    diff_squared = tsibble::difference(Trips, lag = 4)^2
  ) |>
  dplyr::ungroup()

# combinações para acurácia
combinacoes = list(
  agregado = list("is_aggregated(Purpose) & is_aggregated(Region) & is_aggregated(State) & !is_aggregated(modelo)", c("modelo")), # nolint
  State = list("is_aggregated(Purpose) & is_aggregated(Region) & !is_aggregated(State) & !is_aggregated(modelo)", c("State", "modelo")), # nolint
  Region = list("is_aggregated(Purpose) & !is_aggregated(Region) & !is_aggregated(State) & !is_aggregated(modelo)", c("Region", "State", "modelo")), # nolint
  Purpose = list("!is_aggregated(Purpose) & is_aggregated(Region) & is_aggregated(State) & !is_aggregated(modelo)", c("Purpose", "modelo")), # nolint
  bottom = list("!is_aggregated(Purpose) & !is_aggregated(Region) & !is_aggregated(State) & !is_aggregated(modelo)", c("Purpose", "Region", "State", "modelo")), # nolint
  hierarquia = list("!is_aggregated(modelo)", c("Purpose", "Region", "State", "modelo")) # nolint
)

# acurácia
data_acc = lapply(names(combinacoes), function(nivel) {
  # filtrando dados
  temp = tsibble::as_tibble(data) |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]][[1]])) |>
    dplyr::mutate(modelo = as.character(modelo)) |>
    dplyr::group_by_at(dplyr::vars(combinacoes[[nivel]][[2]]))

  # calculando diffs para mase e rmsse
  diffs = temp |>
    dplyr::filter(modelo == "NA") |>
    dplyr::summarise(
      diff = mean(diff, na.rm = TRUE),
      diff_squared = mean(diff_squared, na.rm = TRUE)
    ) |>
    dplyr::select(-modelo)

  # calculando acurácia
  temp = temp |>
    dplyr::filter(modelo != "NA") |>
    dplyr::summarise(
      rmse = sqrt(mean((prediction - Trips) ^ 2)),
      mae = mean(abs(prediction - Trips)),
      mape = mean(abs((prediction - Trips) / Trips)),
      mse = mean((prediction - Trips) ^ 2)
    )

  # merge com diffs
  if (nivel == "agregado") {
    temp = dplyr::cross_join(temp, diffs)
  } else {
    temp = dplyr::left_join(temp, diffs)
  }

  # calculando mase e rmsse
  temp = temp |>
    dplyr::mutate(
      mase = mae / diff,
      rmsse = sqrt(mse / diff_squared)
    ) |>
    dplyr::group_by(modelo) |>
    dplyr::summarise(
      rmse = mean(rmse),
      mae = mean(mae),
      mape = mean(mape),
      mase = mean(mase),
      rmsse = mean(rmsse)
    )
  temp$serie = nivel

  return(temp)
})

# agregando dataframes
medidas = c("rmse", "mae", "mape", "mase", "rmsse")
acuracia_ml = lapply(medidas, function(medida) {
  do.call("rbind", data_acc)[, c("modelo", medida, "serie")] |>
    tidyr::pivot_wider(
      names_from = serie,
      values_from = rlang::parse_expr(medida)
    ) |>
    as.data.frame(t()) |>
    tibble::as_tibble()
})

names(acuracia_ml) = medidas
