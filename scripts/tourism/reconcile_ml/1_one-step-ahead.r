# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# training set
tourism = readRDS("data/tourism/tourism.rds") |>
  tsibble::filter_index(~ "2007 Q4")

# test set
new_data = readRDS("data/tourism/tourism.rds") |>
  tsibble::filter_index("2008 Q1" ~ "2015 Q4")

# obtendo modelos
modelo = tourism |>
  fabletools::model(ets = fable::ETS(
    Trips
  ))

# portmanteau tests para autocorrelação
testes_lb = modelo |>
  fabletools::augment() |>
  fabletools::features(.innov, feasts::ljung_box, lag = 4)

# previsões 1-step-ahead
preds = fabletools::refit(modelo, new_data, reestimate = TRUE) |> fitted()

# save
saveRDS(testes_lb, "data/tourism/preds_ml/train/testes_lb.rds")
saveRDS(preds, "data/tourism/preds_ml/train/preds.rds")
