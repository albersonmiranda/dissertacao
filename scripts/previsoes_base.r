# PREVISÕES BASE #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
estban = readRDS("data/estban.rds")

# new data
new_data = readRDS("data/estban.RDS") |>
  tsibble::filter_index("2022 jan" ~ "2022 dec")

# obtendo modelos
estban_ets = estban |>
  tsibble::filter_index(~ "2021 dec") |>
  model(base = fable::ETS(saldo))

# portmanteau tests para autocorrelação
testes_lb = estban_ets |>
  augment() |>
  features(.innov, feasts::ljung_box, lag = 12)

# previsões base
previsoes_base_estatica = forecast(estban_ets, h = "1 years")
previsoes_base_fitted = estban_ets |> fitted()

# save
saveRDS(estban_ets, "data/estban_ets.rds")
saveRDS(testes_lb, "data/testes_lb.rds")
saveRDS(previsoes_base_estatica, "data/previsoes_base_estatica.rds")
saveRDS(previsoes_base_fitted, "data/previsoes_base_fitted.rds")
