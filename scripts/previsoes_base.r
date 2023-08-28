# PREVISÕES BASE #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
estban = readRDS("data/estban.rds")

# obtendo modelos
estban_arima = estban |>
  tsibble::filter_index("2010 jan" ~ "2021 dec") |>
  model(
    base = fable::ARIMA(
      saldo,
      order_constraint = p + q + P + Q <= 4 & (constant + d + D <= 3) & (d <= 1) & (D <= 1)
    )
  )

# portmanteau tests para autocorrelação
testes_lb = estban_arima |>
  augment() |>
  features(.innov, feasts::ljung_box, lag = 12)

# previsões base
previsoes_base = forecast(estban_arima, h = "1 years")

# save
saveRDS(estban_arima, "data/estban_arima.rds")
saveRDS(testes_lb, "data/testes_lb.rds")
saveRDS(previsoes_base, "data/previsoes_base.rds")
