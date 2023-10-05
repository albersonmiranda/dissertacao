# BENCHMARKING ANALÍTICOS #


# reproducibilidade
set.seed(123)

# pacotes
pacman::p_load(
  fabletools
)

# dados
estban = readRDS("data/estban.rds") |>
  tsibble::filter_index("2022 jan" ~ "2022 dec")

# modelo previsões base
estban_ets = readRDS("data/estban_ets.rds")

# reconciliação mint e bottom-up
estban_analiticos = estban_ets |>
  reconcile(
    mint = min_trace(base, "mint_shrink"),
    bu = bottom_up(base)
  )

# previsões reconciliadas
estban_analiticos_preds = estban_analiticos |>
  forecast(h = "1 years")

# combinações para acurácia
combinacoes = list(
  agregado = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & is_aggregated(nome_mesorregiao)", # nolint
  mesorregiao = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  microrregiao = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  municipio = "is_aggregated(verbete) & is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  agencia = "is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  verbete = "!is_aggregated(verbete) & !is_aggregated(cnpj_agencia) & !is_aggregated(nome) & !is_aggregated(nome_microrregiao) & !is_aggregated(nome_mesorregiao)", # nolint
  hierarquia = "!is.null(.mean)" # nolint
)

# acurácia
estban_analiticos_acc = lapply(names(combinacoes), function(nivel) {
  data = estban_analiticos_preds |>
    dplyr::filter(!!rlang::parse_expr(combinacoes[[nivel]])) |>
    fabletools::accuracy(
      data = estban,
      measures = list(mase = fabletools::MASE, rmse = fabletools::RMSE)
    ) |>
    dplyr::group_by(.model) |>
    dplyr::summarise(rmse = mean(rmse))

  data$serie = nivel

  return(data)
})

# agregando dataframes
acuracia_analiticos = do.call("rbind", estban_analiticos_acc) |>
  tidyr::pivot_wider(
    names_from = serie,
    values_from = c(rmse)
  ) |>
  as.data.frame(t()) |>
  tibble::as_tibble()

# save
saveRDS(acuracia_analiticos, "data/acuracia_analiticos.rds")
