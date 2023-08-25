# BENCHMARK GLMNET #


# one-step-ahead preds
new_data = estban |>
    tsibble::filter_index("2015 jan" ~ "2019 dec")

# validation set
validation_set = estban |>
    tsibble::filter_index("2020 jan" ~ "2021 dec")

estban_ets_preds = refit(estban_ets, new_data, reestimate = FALSE) |> fitted()

# fitted values
fitted = data.frame(
    augment(estban_arima$arima[[i]])[, c("ref", "saldo")]
)

for (i in seq_len(nrow(estban_arima))) {

    temp = augment(estban_arima$arima[[i]])
    temp = data.frame(fitted = temp$.fitted)
    names(temp) = estban_arima$cnpj_agencia[i]
    fitted = dplyr::bind_cols(fitted, temp)
}

# TROCAR POR MERGE

temp = within(temp, {
        nome_mesorregiao = estban_arima$nome_mesorregiao[i]
        nome_microrregiao = estban_arima$nome_microrregiao[i]
        nome = estban_arima$nome[i]
        cnpj_agencia = estban_arima$cnpj_agencia[i]
        verbete = estban_arima$verbete[i]
    })

# obtendo lambda ótimo (quantidade de regularização)
cv = glmnet::cv.glmnet(
    data$.fitted,
    data$y,
    # para lasso, alpha = 1
    alpha = 1
)
