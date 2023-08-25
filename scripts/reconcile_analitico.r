# BENCHMARKING ANALÍTICOS #


# modelo previsões base
estban_arima = readRDS("data/estban_arima.rds")

# mint e bottom-up
estban_ets_mint = estban_ets |>
    reconcile(
        mint = min_trace(ets, "mint_shrink"),
        bu = bottom_up(ets)
    )