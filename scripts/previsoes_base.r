# PREVISÕES BASE #


# pacotes
pacman::p_load(
    fabletools
)

# dados
estban = readRDS("data/estban.rds") |>
    subset(
        select = c(
            ref,
            nome_mesorregiao,
            nome_microrregiao,
            nome,
            cnpj_agencia,
            verbete,
            valor
        )
    ) |>
    # alterando referência para mensal
    transform(
        ref = tsibble::yearmonth(ref)
    ) |>
    # formatando como tsibble
    as_tsibble(
        key = c(
            "nome_mesorregiao",
            "nome_microrregiao",
            "nome",
            "cnpj_agencia",
            "verbete"
        ),
        index = ref
    ) |>
    tsibble::fill_gaps() |>
    aggregate_key(
        (nome_mesorregiao / nome_microrregiao / nome / cnpj_agencia) * verbete,
        saldo = sum(valor)
    )

# obtendo modelos
estban_arima = estban |>
    tsibble::filter_index("2010 jan" ~ "2019 dec") |>
    model(
        arima = fable::ARIMA(
            saldo,
            order_constraint = p + q + P + Q <= 4 & (constant + d + D <= 3) & (d <= 1) & (D <= 1)
        )
    )

# portmanteau tests para autocorrelação
testes_lb = estban_arima |>
    augment() |>
    features(.innov, feasts::ljung_box, lag = 12)

# previsões base
previsoes_base = forecast(estban_arima, h = "2 years")

# save
saveRDS(estban_arima, "data/estban_arima.rds")
saveRDS(testes_lb, "data/testes_lb.rds")
saveRDS(previsoes_base, "data/previsoes_base.rds")
