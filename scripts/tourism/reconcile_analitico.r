# BENCHMARKING ANALÍTICOS #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
tourism_full = readRDS("data/tourism/tourism.rds")

tourism = readRDS("data/tourism/tourism.rds") |>
  tsibble::filter_index("2016 Q1" ~ "2017 Q4")

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
  forecast(h = "2 years")

# combinações para acurácia
combinacoes = list(
  agregado = "is_aggregated(State) & is_aggregated(Region) & is_aggregated(Purpose)", # nolint
  state = "!is_aggregated(State) & is_aggregated(Region) & is_aggregated(Purpose)", # nolint
  region = "!is_aggregated(State) & !is_aggregated(Region) & is_aggregated(Purpose)", # nolint
  purpose = "is_aggregated(State) & is_aggregated(Region) & !is_aggregated(Purpose)", # nolint
  bottom = "!is_aggregated(State) & !is_aggregated(Region) & !is_aggregated(Purpose)", # nolint
  hierarquia = "!is.null(.mean)" # nolint
)

# acurácia
acuracia = lapply(names(combinacoes), function(nivel) {
  data = preds |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]]))

  acuracia = data |>
    fabletools::accuracy(
      data = tourism_full,
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

  acuracia$serie = nivel

  return(acuracia)
})

# agregando dataframes
acuracia_analiticos = lapply(list("rmse", "mae", "mape", "mase", "rmsse"), function(medida) {
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
