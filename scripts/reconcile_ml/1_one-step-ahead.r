# BENCHMARK ML #


# reproducibilidade
set.seed(123)

# training set
estban = readRDS("data/estban.rds") |>
  tsibble::filter_index(~ "2012 dec")

# test set
new_data = readRDS("data/estban.rds") |>
  tsibble::filter_index("2013 jan" ~ "2021 dec")

# obtendo modelos
estban_ets = estban |>
  fabletools::model(ets = fable::ETS(saldo))

# portmanteau tests para autocorrelação
testes_lb = estban_ets |>
  fabletools::augment() |>
  fabletools::features(.innov, feasts::ljung_box, lag = 12)

# previsões 1-step-ahead
estban_ets_preds = fabletools::refit(estban_ets, new_data, reestimate = FALSE) |> fitted()

# save
saveRDS(testes_lb, "data/testes_lb_ets.rds")
saveRDS(estban_ets_preds, "data/estban_ets_preds.rds")
