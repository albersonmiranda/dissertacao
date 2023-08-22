# BENCHMARKING - MINT - TOP-DOWN #


# pacotes
pacman::p_load(
    fabletools
)

# modelo previsões base
estban_ets = readRDS("data/estban_ets.rds")

# mint
estban_ets_mint = estban_ets |>
    reconcile(
        mint = min_trace(ets, "mint_shrink"),
        bu = bottom_up(ets)
    )

