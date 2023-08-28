# PREDIÇÃO DE SALDOS #


# carregando modelo treinado
model = readRDS("data/model.RDS")

# seleção de data
ref = "2023-05-31"

# formato
ref = as.Date(ref)

# mes
mes = format(ref, "%m")
mes_anterior = format(ref - 31, "%m")

# caminho para séries
caminho_series = list.files(
    "data-raw/new-data",
    full.names = TRUE
)

# loop para importar série
series = lapply(caminho_series, function(x) {

    print(x)
    ano = regmatches(x, regexpr("(\\d+)(?=[^\\/]*$)", x, perl = TRUE))
    serie = regmatches(x, regexpr("(?=[^\\/]+$)([a-z]+)(?=\\.)", x, perl = TRUE))

    # selecionando orçado atual e realizado anterior
    data = bees::import_ppo(x) |>
        dplyr::select(tidyselect::starts_with(c(
            "cid",
            "agencia",
            paste0(mes_anterior, "_realizado"),
            paste0(mes, "_orcado")
        )))

    # definindo variação a ser alcançada
    data = within(data, {
        diff = data[[4]] - data[[3]]
        mes = mes
        ano = ano
        serie = serie
        cid_unidade_elaborou = cid
        produto = serie
    })
})

series = do.call("rbind", series)
series = subset(series, cid != "Total")

# corrigindo data types
series = within(series, {
    ano = as.integer(ano)
    mes = as.factor(mes)
    produto = as.factor(produto)
    cid_unidade_elaborou = as.factor(cid_unidade_elaborou)
})

# convertendo para data.table
new_data = data.table::as.data.table(series)

# predições
preds = model$predict_newdata(newdata = new_data)

# exportar
export = cbind(tibble::as_tibble(new_data), tibble::as_tibble(data.table::as.data.table(preds)))

