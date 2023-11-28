# PREVISÕES BASE #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
tourism = readRDS("data/tourism/tourism.rds")

# new data
new_data = tourism |>
  tsibble::filter_index("2016 Q1" ~ "2017 Q4")

# obtendo modelos
modelo = tourism |>
  tsibble::filter_index(~ "2015 Q4") |>
  model(base = fable::ETS(Trips))

# portmanteau tests para autocorrelação
testes_lb = modelo |>
  augment() |>
  features(.innov, feasts::ljung_box, lag = 4)

# previsões base
previsoes_base = forecast(modelo, h = "2 years")

# fitted values
fitted_values = modelo |>
  fitted()

# save
saveRDS(modelo, "data/tourism/previsoes_base/modelo.rds")
saveRDS(testes_lb, "data/tourism/previsoes_base/testes_lb.rds")
saveRDS(previsoes_base, "data/tourism/previsoes_base/previsoes_base.rds")
saveRDS(fitted_values, "data/tourism/previsoes_base/fitted_values.rds")
