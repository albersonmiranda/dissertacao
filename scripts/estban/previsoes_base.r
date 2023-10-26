# PREVISÕES BASE #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
estban = readRDS("data/estban/estban.rds")

# new data
new_data = readRDS("data/estban/estban.RDS") |>
  tsibble::filter_index("2022 jan" ~ "2022 dec")

# obtendo modelos
modelo = estban |>
  tsibble::filter_index(~ "2021 dec") |>
  model(base = fable::ETS(saldo))

# portmanteau tests para autocorrelação
testes_lb = modelo |>
  augment() |>
  features(.innov, feasts::ljung_box, lag = 12)

# previsões base
previsoes_base = forecast(modelo, h = "1 years")

# save
saveRDS(modelo, "data/estban/previsoes_base/modelo.rds")
saveRDS(testes_lb, "data/estban/previsoes_base/testes_lb.rds")
saveRDS(previsoes_base, "data/estban/previsoes_base/previsoes_base.rds")
