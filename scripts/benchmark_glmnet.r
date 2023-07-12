# BENCHMARK GLMNET #


# pacotes

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