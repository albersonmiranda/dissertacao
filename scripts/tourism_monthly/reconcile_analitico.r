# BENCHMARKING ANALÍTICOS #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
tourism_monthly_full = readRDS("data/tourism_monthly/tourism_monthly.rds")

tourism_monthly = readRDS("data/tourism_monthly/tourism_monthly.rds") |>
  tsibble::filter_index("2017 jan" ~ "2017 dec")

# modelo previsões base
modelo = readRDS("data/tourism_monthly/previsoes_base/modelo.rds")

# reconciliação mint e bottom-up
modelo_reconcile = modelo |>
  reconcile(
    mint = min_trace(base, "mint_shrink"),
    bu = bottom_up(base)
  )

# previsões reconciliadas
preds = modelo_reconcile |>
  forecast(h = 12)

# combinações para acurácia
combinacoes = list(
  agregado = "is_aggregated(State) & is_aggregated(Zone) & is_aggregated(Region)", # nolint
  state = "!is_aggregated(State) & is_aggregated(Zone) & is_aggregated(Region)", # nolint
  zone = "!is_aggregated(State) & !is_aggregated(Zone) & is_aggregated(Region)", # nolint
  region = "!is_aggregated(State) & !is_aggregated(Zone) & !is_aggregated(Region)", # nolint
  hierarquia = "!is.null(.mean)" # nolint
)

# acurácia
acuracia = lapply(names(combinacoes), function(nivel) {
  data = preds |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]]))

  acuracia = data |>
    fabletools::accuracy(
      data = tourism_monthly_full,
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
saveRDS(modelo_reconcile, "data/tourism_monthly/preds_analitico/modelo_reconcile.rds")
saveRDS(preds, "data/tourism_monthly/preds_analitico/preds.rds")
saveRDS(acuracia_analiticos, "data/tourism_monthly/preds_analitico/acuracia_analiticos.rds")
