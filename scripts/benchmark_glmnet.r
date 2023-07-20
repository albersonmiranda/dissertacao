# BENCHMARK GLMNET #


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
