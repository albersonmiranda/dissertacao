# BENCHMARKING - MINT - TOP-DOWN #


# pacotes
pacman::p_load(
    fabletools
)

# dados
estban = readRDS("data/estban.rds") |>
    subset(
        ref >= "2010-01-01" & ref <= "2023-12-31",
        select = c(
            ref,
            nome_mesorregiao,
            nome_microrregiao,
            nome,
            cnpj_agencia,
            verbete,
            valor
        )
    )

# looping
data = lapply(unique(estban$verbete), function(verbetes) {
    # formatando como tsibble
    estban = estban |>
        subset(verbete == verbetes) |>
        as_tsibble(
            key = c(
                "nome_mesorregiao",
                "nome_microrregiao",
                "nome",
                "cnpj_agencia"
            ),
            index = ref
        ) |>
        tsibble::fill_gaps() |>
        aggregate_key(
            nome_mesorregiao / nome_microrregiao / nome / cnpj_agencia,
            saldo = sum(valor)
        ) |>
        subset(
            is_aggregated(nome_mesorregiao) &
            is_aggregated(nome_microrregiao) &
            is_aggregated(nome) &
            is_aggregated(cnpj_agencia)
        ) |>
        model(
            arima = fable::ARIMA(
                saldo,
                order_constraint = p + q + P + Q <= 4 & (constant + d + D <= 2) & (d <= 1) & (D <= 0)
            ),
        ) |>
        reconcile(
            arima = top_down(arima)
        ) |>
        forecast(h = "1 years")
})
