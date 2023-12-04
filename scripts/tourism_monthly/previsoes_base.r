# PREVISÕES BASE #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
tourism_monthly = readRDS("data/tourism_monthly/tourism_monthly.rds")

# obtendo modelos
modelo = tourism_monthly |>
  tsibble::filter_index(~ "2016 dec") |>
  model(base = fable::ARIMA(Trips))

# portmanteau tests para autocorrelação
testes_lb = modelo |>
  augment() |>
  features(.innov, feasts::ljung_box, lag = 12)

# previsões base
previsoes_base = forecast(modelo, h = 12)

# fitted values
fitted_values = modelo |>
  fitted()

# save
saveRDS(modelo, "data/tourism_monthly/previsoes_base/modelo.rds")
saveRDS(testes_lb, "data/tourism_monthly/previsoes_base/testes_lb.rds")
saveRDS(previsoes_base, "data/tourism_monthly/previsoes_base/previsoes_base.rds")
saveRDS(fitted_values, "data/tourism_monthly/previsoes_base/fitted_values.rds")
