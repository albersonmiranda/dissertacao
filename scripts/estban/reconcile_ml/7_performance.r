### PERFORMANCE


# pacotes
library(fabletools)

# tipo de previsões treino: one-step-ahead, rolling_forecast ou fitted_base
tipo = "one-step-ahead"

# juntando predições em um único dataframe
preds = lapply(c("xgb", "ranger", "glmnet", "lasso", "ridge", "svm", "lightgbm"), function(learner) {
  preds = readRDS(paste0("data/estban/preds_ml/preds/", tipo, "/preds_", learner, ".RDS"))
  preds = lapply(preds[[1]], function(df) data.table::as.data.table(df) |> subset(select = response))
  preds = do.call(cbind, preds)
  # adicionando coluna ref
  preds$ref = tsibble::yearmonth(seq(as.Date("2022-01-01"), as.Date("2022-12-01"), by = "month"))
  return(preds)
})

# nomeando a lista
names(preds) = c("xgb", "ranger", "glmnet", "lasso", "ridge", "svm", "lightgbm")

# remover primeiro caractere do nome das colunas
preds = lapply(preds, function(df) {
  names(df) = gsub("^.", "", names(df))
  return(df)
})

# renomeando coluna ef para ref
preds = lapply(preds, function(df) {
  names(df)[names(df) == "ef"] = "ref"
  return(df)
})

# alongando dataframe preds
preds = lapply(preds, function(df) {
  df = df |>
    tidyr::pivot_longer(
      cols = -ref,
      names_to = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete", "tipo"),
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

# estban dataset
estban = readRDS("data/estban/estban.rds") |>
  subset(ref <= tsibble::yearmonth("2022 dec"))

# remover agregados
estban = estban |>
  subset(
    !is_aggregated(nome_mesorregiao)
    & !is_aggregated(nome_microrregiao)
    & !is_aggregated(nome)
    & !is_aggregated(verbete)
    & !is_aggregated(cnpj_agencia)
  ) |>
  as.data.frame()

# convertendo coluna ref para yearmonth
preds$ref = as.character(preds$ref)
estban$ref = as.character(estban$ref)

# convertendo colunas chr* do dataframe estban para character
estban = within(estban, {
  nome_mesorregiao = as.character(nome_mesorregiao)
  nome_microrregiao = as.character(nome_microrregiao)
  nome = as.character(nome)
  verbete = as.character(verbete)
  cnpj_agencia = as.character(cnpj_agencia)
})

# limpando dataframe estban
estban = within(estban, {
  nome_mesorregiao = iconv(tolower(gsub("-| ", "_", nome_mesorregiao)), "UTF-8", "ASCII//TRANSLIT")
  verbete = iconv(tolower(gsub("-| ", "_", verbete)), "UTF-8", "ASCII//TRANSLIT")
  nome_microrregiao = iconv(tolower(gsub("-| ", "_", nome_microrregiao)), "UTF-8", "ASCII//TRANSLIT")
  nome = iconv(tolower(gsub("-| ", "_", nome)), "UTF-8", "ASCII//TRANSLIT")
})

# merge entre estban e preds
data = merge(estban, preds, all.x = TRUE)

# teste se merge foi completo
nrow(subset(data, !is.na(prediction) & !is_aggregated(cnpj_agencia) & !is_aggregated(verbete) & !is_aggregated(modelo))) == nrow(preds) # nolint

# agregando
data = data |>
  transform(ref = tsibble::yearmonth(as.Date(paste0(ref, "-01"), format = "%Y %b-%d"))) |>
  tsibble::as_tsibble(
    key = c(
      "nome_mesorregiao",
      "nome_microrregiao",
      "nome",
      "cnpj_agencia",
      "verbete",
      "modelo"
    ),
    index = ref
  ) |>
  fabletools::aggregate_key(
    (nome_mesorregiao / nome_microrregiao / nome / cnpj_agencia) * verbete * modelo,
    saldo = sum(saldo),
    prediction = sum(prediction)
  )

# adicionando primeiras diferenças
data = data |>
  dplyr::group_by(nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo) |>
  dplyr::mutate(
    diff = abs(tsibble::difference(saldo, lag = 12)),
    diff_squared = tsibble::difference(saldo, lag = 12)^2
  ) |>
  dplyr::ungroup()

# combinações para acurácia
combinacoes = list(
  agregado = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("modelo")), # nolint
  mesorregiao = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("nome_mesorregiao", "modelo")), # nolint
  microrregiao = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  municipio = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("nome", "nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  agencia = list("is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  verbete = list("!is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("verbete", "modelo")), # nolint
  bottom = list("!is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("verbete", "cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  hierarquia = list("!is_aggregated(modelo)", c("verbete", "cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "modelo")) # nolint
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
      rmse = sqrt(mean((prediction - saldo) ^ 2)),
      mae = mean(abs(prediction - saldo)),
      mape = mean(abs((prediction - saldo) / saldo)),
      mse = mean((prediction - saldo) ^ 2)
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

# export
saveRDS(acuracia_ml, paste0("data/estban/preds_ml/preds/", tipo, "/resumo.RDS"))
