### PERFORMANCE


# pacotes
library(fabletools)

# juntando predições em um único dataframe
preds = lapply(c("xgb", "ranger", "glmnet", "lasso", "ridge"), function(learner) {
  preds = readRDS(paste0("data/estban/preds_ml/preds/preds_", learner, ".RDS"))
  preds = lapply(preds[[1]], function(df) data.table::as.data.table(df) |> subset(select = response))
  preds = do.call(cbind, preds)
  # adicionando coluna ref
  preds$ref = tsibble::yearmonth(seq(as.Date("2022-01-01"), as.Date("2022-12-01"), by = "month"))
  return(preds)
})

# nomeando a lista
names(preds) = c("xgb", "ranger", "glmnet", "lasso", "ridge")

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
  tsibble::filter_index("2022 jan" ~ "2022 dec")

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
  nome_mesorregiao = iconv(tolower(gsub("-", " ", nome_mesorregiao)), "LATIN1", "ASCII//TRANSLIT")
  verbete = iconv(tolower(verbete), "LATIN1", "ASCII//TRANSLIT")
  nome_microrregiao = iconv(tolower(nome_microrregiao), "LATIN1", "ASCII//TRANSLIT")
  nome = iconv(tolower(nome), "LATIN1", "ASCII//TRANSLIT")
})

# merge entre estban e preds
data = merge(estban, preds)

# teste se merge foi completo
nrow(data) == 5 * nrow(estban)

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

# combinações para acurácia
combinacoes = list(
  agregado = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("modelo")), # nolint
  mesorregiao = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("nome_mesorregiao", "modelo")), # nolint
  microrregiao = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  municipio = list("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("nome", "nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  agencia = list("is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
  verbete = list("!is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", c("verbete", "cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "modelo")), # nolint
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
