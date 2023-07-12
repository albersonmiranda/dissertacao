# PREVISÕES BASE #


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
    ) |>
    # alterando referência para mensal
    transform(
        ref = tsibble::yearmonth(ref)
    )

# obtendo previsões base
estban_preds = estban |>
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
    ) |>
    model(
        arima = fable::ARIMA(
            saldo,
            order_constraint = p + q + P + Q <= 4 & (constant + d + D <= 3) & (d <= 1) & (D <= 1)
        ),
    ) |>
    forecast(h = "1 years")
