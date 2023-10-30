# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# fim das janelas de treino
window_end = tsibble::yearmonth(seq(as.Date("2012-12-01"), as.Date("2021-11-01"), by = "month"))

preds = lapply(window_end, function(fim) {
  # training set
  estban = readRDS("data/estban/estban.rds") |>
    tsibble::filter_index(~ as.character.Date(fim))

  # obtendo predições
  preds = estban |>
    fabletools::model(ets = fable::ETS(saldo)) |>
    fabletools::forecast(h = "1 months")

  return(preds)
})


# portmanteau tests para autocorrelação
testes_lb = modelo |>
  fabletools::augment() |>
  fabletools::features(.innov, feasts::ljung_box, lag = 12)

# previsões 1-step-ahead
preds = fabletools::refit(modelo, new_data, reestimate = TRUE) |> fitted()

# save
saveRDS(testes_lb, "data/estban/preds_ml/train/testes_lb_ets.rds")
saveRDS(preds, "data/estban/preds_ml/train/preds.rds")
