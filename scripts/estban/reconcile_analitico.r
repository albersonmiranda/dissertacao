# BENCHMARKING ANALÍTICOS #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
estban = readRDS("data/estban/estban.rds") |>
  subset(ref <= tsibble::yearmonth("2022 dec"))

# modelo previsões base
modelo = readRDS("data/estban/previsoes_base/modelo.rds")

# reconciliação mint e bottom-up
modelo_reconcile = modelo |>
  reconcile(
    mint = min_trace(base, "mint_shrink"),
    bu = bottom_up(base)
  )

# previsões reconciliadas
preds = modelo_reconcile |>
  forecast(h = "1 years")

# combinações para acurácia
combinacoes = list(
  agregado = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao)", # nolint
  mesorregiao = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  microrregiao = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  municipio = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  agencia = "is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  verbete = "!is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao)", # nolint
  bottom = "!is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  hierarquia = "!is.null(.mean)" # nolint
)

# acurácia
acuracia = lapply(names(combinacoes), function(nivel) {
  data = preds |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]])) |>
    fabletools::accuracy(
      data = estban,
      measures = list(
        mae = fabletools::MAE,
        rmse = fabletools::RMSE,
        mape = fabletools::MAPE,
        mase = fabletools::MASE,
        rmsse = fabletools::RMSSE
      )
    ) |>
    dplyr::group_by(.model) |>
    dplyr::summarise(
      rmse = mean(rmse),
      mae = mean(mae),
      mape = mean(mape),
      mase = mean(mase),
      rmsse = mean(rmsse)
    )

  data$serie = nivel

  return(data)
})

# agregando dataframes
medidas = c("rmse", "mae", "mape", "mase", "rmsse")
acuracia_analiticos = lapply(medidas, function(medida) {
  do.call("rbind", acuracia)[, c(".model", medida, "serie")] |>
    tidyr::pivot_wider(
      names_from = serie,
      values_from = rlang::parse_expr(medida)
    ) |>
    as.data.frame(t()) |>
    tibble::as_tibble()
})

names(acuracia_analiticos) = medidas

# save
saveRDS(modelo_reconcile, "data/estban/preds_analitico/modelo_reconcile.rds")
saveRDS(preds, "data/estban/preds_analitico/preds.rds")
saveRDS(acuracia_analiticos, "data/estban/preds_analitico/acuracia_analiticos.rds")
