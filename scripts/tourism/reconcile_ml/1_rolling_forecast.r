# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# pacotes
library(fabletools)

# datas fim para janelas de treino
window_end = tsibble::yearquarter(seq(as.Date("2007-12-01"), as.Date("2015-09-01"), by = "quarter"))

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
    tourism = readRDS("data/tourism/tourism.RDS") |>
      tsibble::filter_index(~ as.character.Date(fim))

    # obtendo predições
    preds = tourism |>
      fabletools::model(ets = fable::ETS(Trips)) |>
      fabletools::forecast(h = 1)

    return(preds)
  })
}

# obter previsões
preds = preds_fun(window_end) |> progressr::with_progress()

# mesclando em um único dataframe
preds = do.call(dplyr::bind_rows, preds)

# save
saveRDS(preds, "data/tourism/preds_ml/train/preds_rolling.rds")
