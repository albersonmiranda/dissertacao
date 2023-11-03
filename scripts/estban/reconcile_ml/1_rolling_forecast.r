# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# pacotes
library(fabletools)

# datas fim para janelas de treino
window_end = tsibble::yearmonth(seq(as.Date("2012-12-01"), as.Date("2021-11-01"), by = "month"))

# paralelização
future::plan("multisession")

# função para obter previsões com rolling window, paralelização e progresso
preds_fun = function(x) {
  # progresso
  p = progressr::progressor(along = x)
  # loop
  future.apply::future_lapply(x, function(fim) {
    # set progress
    p()
    # training set
    estban = readRDS("data/estban/estban.RDS") |>
      tsibble::filter_index(~ as.character.Date(fim))

    # obtendo predições
    preds = estban |>
      fabletools::model(ets = fable::ETS(saldo)) |>
      fabletools::forecast(h = "1 months")

    return(preds)
  })
}

# obter previsões
preds = preds_fun(window_end) |> progressr::with_progress()

# mesclando em um único dataframe
preds = do.call(bind_rows, preds)

# save
saveRDS(preds, "data/estban/preds_ml/train/preds_rolling.rds")