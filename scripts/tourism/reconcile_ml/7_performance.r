### PERFORMANCE


# pacotes
library(fabletools)

# tipo de previsões treino: one-step-ahead ou rolling_forecast
tipo = "rolling_forecast"

# juntando predições em um único dataframe
preds = lapply(c("xgb", "ranger", "glmnet", "lasso", "ridge"), function(learner) {
  preds = readRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_", learner, ".RDS"))
  preds = lapply(preds[[1]], function(df) data.table::as.data.table(df) |> subset(select = response))
  preds = do.call(cbind, preds)
  # adicionando coluna Quarter
  preds$Quarter = tsibble::yearquarter(seq(as.Date("2016-01-01"), as.Date("2017-12-01"), by = "quarter"))
  return(preds)
})

# nomeando a lista
names(preds) = c("xgb", "ranger", "glmnet", "lasso", "ridge")

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
tourism = readRDS("data/tourism/tourism.rds") |>
  tsibble::filter_index("2016 Q1" ~ "2017 Q4")

# remover agregados
tourism = tourism |>
  subset(
    !is_aggregated(State)
    & !is_aggregated(Region)
    & !is_aggregated(Purpose)
  ) |>
  as.data.frame()

# convertendo coluna Quarter para yearquarter
preds$Quarter = as.character(preds$Quarter)
tourism$Quarter = as.character(tourism$Quarter)

# convertendo colunas chr* do dataframe tourism para character
tourism = within(tourism, {
  State = as.character(State)
  Region = as.character(Region)
  Purpose = as.character(Purpose)
})

# limpando dataframe tourism
tourism = within(tourism, {
  State = iconv(tolower(gsub("-", " ", State)), "LATIN1", "ASCII//TRANSLIT")
  Region = iconv(tolower(Region), "LATIN1", "ASCII//TRANSLIT")
})

# merge entre tourism e preds
data = merge(tourism, preds)

# teste se merge foi completo
nrow(data) == 5 * nrow(tourism)

# agregando
data = data |>
  transform(Quarter = tsibble::yearquarter(Quarter)) |>
  tsibble::as_tsibble(
    key = c(
      "State",
      "Region",
      "modelo"
    ),
    index = Quarter
  ) |>
  fabletools::aggregate_key(
    (State / Region) * modelo,
    saldo = sum(Trips),
    prediction = sum(prediction)
  )

# combinações para acurácia
combinacoes = list(
  agregado = list("is_aggregated(Region) & is_aggregated(State) & !is_aggregated(modelo)", c("modelo")), # nolint
  State = list("is_aggregated(Region) & !is_aggregated(State) & !is_aggregated(modelo)", c("State", "modelo")), # nolint
  Region = list("!is_aggregated(Region) & !is_aggregated(State) & !is_aggregated(modelo)", c("Region", "State", "modelo")), # nolint
  hierarquia = list("!is_aggregated(modelo)", c("modelo")) # nolint
)

# acurácia
data_acc = lapply(names(combinacoes), function(nivel) {
  data = tsibble::as_tibble(data) |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]][[1]])) |>
    dplyr::mutate(modelo = as.character(modelo)) |>
    dplyr::group_by_at(dplyr::vars(combinacoes[[nivel]][[2]])) |>
    dplyr::summarise(
      rmse = sqrt(mean((prediction - saldo) ^ 2)),
      mae = mean(abs(prediction - saldo)),
      mape = mean(abs((prediction - saldo) / saldo))
    ) |>
    dplyr::group_by(modelo) |>
    dplyr::summarise(rmse = mean(rmse), mae = mean(mae), mape = mean(mape))
  data$serie = nivel

  return(data)
})

# agregando dataframes
acuracia_ml = lapply(list("rmse", "mae", "mape"), function(medida) {
  do.call("rbind", data_acc)[, c("modelo", medida, "serie")] |>
    tidyr::pivot_wider(
      names_from = serie,
      values_from = rlang::parse_expr(medida)
    ) |>
    as.data.frame(t()) |>
    tibble::as_tibble()
})
