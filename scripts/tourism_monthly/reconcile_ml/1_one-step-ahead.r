# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# training set
tourism_monthly = readRDS("data/tourism_monthly/tourism_monthly.rds") |>
  tsibble::filter_index(~ "2002 dec")

# test set
new_data = readRDS("data/tourism_monthly/tourism_monthly.rds") |>
  tsibble::filter_index("2003 jan" ~ "2016 dec")

# obtendo modelos
modelo = tourism_monthly |>
  fabletools::model(base = fable::ARIMA(Trips))

# portmanteau tests para autocorrelação
testes_lb = modelo |>
  fabletools::augment() |>
  fabletools::features(.innov, feasts::ljung_box, lag = 12)

# previsões 1-step-ahead
preds = fabletools::refit(modelo, new_data, reestimate = TRUE) |> fitted()

# save
saveRDS(testes_lb, "data/tourism_monthly/preds_ml/train/testes_lb.rds")
saveRDS(preds, "data/tourism_monthly/preds_ml/train/preds.rds")
