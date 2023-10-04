### PERFORMANCE


# pacotes
library(fabletools)

# juntando predições em um único dataframe
preds = lapply(c("xgb", "ranger", "glmnet", "lasso", "ridge"), function(learner) {
  preds = readRDS(paste0("data/preds_", learner, ".RDS"))
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

# substituir o texto "baixo_guandu" para "BAIXO_GUANDU" no nome das colunas
preds = lapply(preds, function(df) {
  names(df) = gsub("baixo_guandu", "BAIXO_GUANDU", names(df))
  return(df)
})

# alongando dataframe preds
preds = lapply(preds, function(df) {
  df = df |>
    tidyr::pivot_longer(
      cols = -ref,
      names_to = c("cnpj_agencia", "nome", "nome_microrregiao", "nome_mesorregiao", "verbete"),
      values_to = "prediction",
      names_sep = "x"
    )
  return(df)
})

# revertendo substituição de texto
preds = lapply(preds, function(df) {
  df$nome = gsub("BAIXO_GUANDU", "baixo_guandu", df$nome)
  return(df)
})

# substituindo _ por espaço em todo o dataframe
preds = lapply(preds, function(df) {
  data = within(df, {
    nome = gsub("_", " ", nome)
    nome_microrregiao = gsub("_", " ", nome_microrregiao)
    nome_mesorregiao = gsub("_", " ", nome_mesorregiao)
    verbete = gsub("_", " ", verbete)
  })

  preds = data$prediction

  # remover espaços no início e fim das strings
  data = lapply(data, function(col) {
    if (!is.numeric(col)) {
      col = trimws(col)
      return(col)
    }
  })

  # adicionando novamente coluna prediction
  data$prediction = preds

  return(data.frame(data))
})

# remover sufixo " true.response" da coluna verbete
preds = lapply(preds, function(df) {
  df$verbete = gsub(" true.response", "", df$verbete)
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
estban = readRDS("data/estban.rds") |>
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

# combinações para acurácia
combinacoes = list(
  agregado = "modelo", # nolint
  mesorregiao = "nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo", # nolint, # nolint
  microrregiao = "nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo", # nolint, # nolint
  municipio = "nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo", # nolint, # nolint
  agencia = "nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo", # nolint, # nolint
  verbete = "nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo", # nolint, # nolint
  hierarquia = "nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo", # nolint # nolint
)

# calcular rmse para cada nível de agregação

data |>
  dplyr::mutate(se = (prediction - saldo) ^ 2) |>
  dplyr::group_by(nome_mesorregiao, nome_microrregiao, nome, cnpj_agencia, verbete, modelo) |>
  dplyr::summarise(rmse = sqrt(mean(se))) |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(rmse = mean(rmse))

# calcular rmse para cada nível de agregação
data |>
  dplyr::mutate(se = (prediction - saldo) ^ 2) |>
  dplyr::group_by(nome_mesorregiao, modelo) |>
  dplyr::summarise(rmse = sqrt(mean(se))) |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(rmse = mean(rmse))

# calcular rmse para cada nível de agregação
data |>
  dplyr::mutate(se = (prediction - saldo) ^ 2) |>
  dplyr::group_by(nome_microrregiao, modelo) |>
  dplyr::summarise(mse = mean(se)) |>
  dplyr::mutate(rmse = sqrt(mse)) |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(rmse = mean(rmse))

# calcular rmse para cada nível de agregação
data |>
  dplyr::mutate(se = (prediction - saldo) ^ 2) |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(mse = sum(se), n = dplyr::n()) |>
  dplyr::mutate(rmse = sqrt(mse)) |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(rmse = mean(rmse))

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
  agregado = c("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)"), # nolint
  mesorregiao = c("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", "nome_mesorregiao"), # nolint
  microrregiao = c("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", "nome_microrregiao"), # nolint
  municipio = c("is_aggregated(verbete) & is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", "nome"), # nolint
  agencia = c("is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", "cnpj_agencia"), # nolint
  verbete = c("!is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao) & !is_aggregated(modelo)", "verbete"), # nolint
  hierarquia = c("!is_aggregated(modelo)") # nolint
)

# acurácia
data_acc = lapply(names(combinacoes), function(nivel) {
  data = tsibble::as_tibble(data) |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]][1])) |>
    dplyr::mutate(se = (prediction - saldo) ^ 2, modelo = as.character(modelo)) |>
    dplyr::group_by(!!rlang::parse_expr(combinacoes[[nivel]][2]), modelo) |>
    dplyr::summarise(mse = mean(se)) |>
    dplyr::mutate(rmse = sqrt(mse)) |>
    dplyr::group_by(modelo) |>
    dplyr::summarise(rmse = mean(rmse))
  data$serie = nivel

  return(data)
})

# agregando dataframes
acuracia_ml = do.call("rbind", data_acc) |>
  tidyr::pivot_wider(
    names_from = serie,
    values_from = c(rmse)
  ) |>
  as.data.frame(t()) |>
  tibble::as_tibble()
