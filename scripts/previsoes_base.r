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
estban_ets = estban |>
    tsibble::filter_index("2010 jan" ~ "2014 dec") |>
    model(ets = fable::ETS(saldo))

# one-step-ahead preds
new_data = estban |>
    tsibble::filter_index("2015 jan" ~ "2019 dec")

# validation set
validation_set = estban |>
    tsibble::filter_index("2020 jan" ~ "2021 dec")

estban_ets_preds = refit(estban_ets, new_data, reestimate = FALSE) |> fitted()

# portmanteau tests para autocorrelação
testes_lb = estban_ets |>
    augment() |>
    features(.innov, feasts::ljung_box, lag = 12)

# save
saveRDS(estban_ets, "data/estban_ets.rds")
saveRDS(estban_ets_preds, "data/estban_ets_preds.rds")
saveRDS(testes_lb, "data/testes_lb.rds")
saveRDS(new_data, "data/test_set.rds")
saveRDS(validation_set, "data/validation_set.rds")
