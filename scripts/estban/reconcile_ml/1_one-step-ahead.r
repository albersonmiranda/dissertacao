# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# training set
estban = readRDS("data/estban/estban.rds") |>
  tsibble::filter_index(~ "2012 dec")

# test set
new_data = readRDS("data/estban/estban.rds") |>
  tsibble::filter_index("2013 jan" ~ "2021 dec")

# obtendo modelos
modelo = estban |>
  fabletools::model(ets = fable::ETS(saldo))

# portmanteau tests para autocorrelação
testes_lb = modelo |>
  fabletools::augment() |>
  fabletools::features(.innov, feasts::ljung_box, lag = 12)

# previsões 1-step-ahead
# ? Refit significa reajustar o modelo usando os mesmos hiperparâmetros (ex.: ARIMA(2,1,1)),
# ? mas com outro conjunto de dados. Pode-se optar por usar os mesmos coeficientes (reestimate = FALSE)
# ? ou estimar novos coeficientes (reestimate = TRUE).
preds = fabletools::refit(modelo, new_data, reestimate = TRUE) |> fitted()

# save
saveRDS(testes_lb, "data/estban/preds_ml/train/testes_lb.rds")
saveRDS(preds, "data/estban/preds_ml/train/preds.rds")