# BENCHMARKING ANALÍTICOS #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
tourism = readRDS("data/tourism/tourism.rds") |>
  tsibble::filter_index("2017 Q1" ~ "2017 Q4")

# modelo previsões base
modelo = readRDS("data/tourism/previsoes_base/modelo.rds")

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
  agregado = "is_aggregated(State) & is_aggregated(Region) & is_aggregated(Purpose)", # nolint
  State = "!is_aggregated(State) & is_aggregated(Region) & is_aggregated(Purpose)", # nolint
  Region = "!is_aggregated(State) & !is_aggregated(Region) & is_aggregated(Purpose)", # nolint
  Purpose = "is_aggregated(State) & is_aggregated(Region) & !is_aggregated(Purpose)", # nolint
  bottom = "!is_aggregated(State) & !is_aggregated(Region) & !is_aggregated(Purpose)", # nolint
  hierarquia = "!is.null(.mean)" # nolint
)

# acurácia
acuracia = lapply(names(combinacoes), function(nivel) {
  data = preds |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]])) |>
    fabletools::accuracy(
      data = tourism,
      measures = list(mae = fabletools::MAE, rmse = fabletools::RMSE, mape = fabletools::MAPE)
    ) |>
    dplyr::group_by(.model) |>
    dplyr::summarise(rmse = mean(rmse), mae = mean(mae), mape = mean(mape))

  data$serie = nivel

  return(data)
})

# agregando dataframes
acuracia_analiticos = lapply(list("rmse", "mae", "mape"), function(medida) {
  do.call("rbind", acuracia)[, c(".model", medida, "serie")] |>
    tidyr::pivot_wider(
      names_from = serie,
      values_from = rlang::parse_expr(medida)
    ) |>
    as.data.frame(t()) |>
    tibble::as_tibble()
})

# save
saveRDS(modelo_reconcile, "data/tourism/preds_analitico/modelo_reconcile.rds")
saveRDS(preds, "data/tourism/preds_analitico/preds.rds")
saveRDS(acuracia_analiticos, "data/tourism/preds_analitico/acuracia_analiticos.rds")
