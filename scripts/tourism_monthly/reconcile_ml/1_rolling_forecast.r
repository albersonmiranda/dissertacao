# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# pacotes
library(fabletools)

# datas fim para janelas de treino
window_end = tsibble::yearmonth(seq(as.Date("2002-12-01"), as.Date("2016-11-01"), by = "month"))

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
    tourism_monthly = readRDS("data/tourism_monthly/tourism_monthly.RDS") |>
      tsibble::filter_index(~ as.character.Date(fim))

    # obtendo predições
    preds = tourism_monthly |>
      fabletools::model(base = fable::ARIMA(Trips)) |>
      fabletools::forecast(h = 1)

    return(preds)
  })
}

# obter previsões
preds = preds_fun(window_end) |> progressr::with_progress()

# mesclando em um único dataframe
preds = do.call(dplyr::bind_rows, preds)

# save
saveRDS(preds, "data/tourism_monthly/preds_ml/train/preds_rolling.rds")
