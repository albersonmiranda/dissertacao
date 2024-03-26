# BENCHMARK #


# métodos analíticos
analiticos = rbind(
  readRDS("data/tourism_monthly/preds_analitico/acuracia_analiticos.rds")[["rmsse"]],
  readRDS("data/tourism_monthly/preds_analitico/acuracia_analiticos.rds")[["mase"]]
) |>
  transform(metrica = c(rep("rmsse", 3), rep("mase", 3)))

# menor métrica por hierarquia
analiticos_best = lapply(colnames(analiticos)[2:length(colnames(analiticos))], function(nivel) {
  data = subset(analiticos, select = c(".model", "metrica", nivel))
  data = by(data, data$metrica, function(x) x[which.min(x[, nivel]), ])
  data = do.call(rbind, data)
  return(data)
})

# montando tabela
analiticos_best = Reduce(function(x, y) merge(x, y, all = TRUE), analiticos_best)

# removendo coluna com todas entradas NA
analiticos_best = analiticos_best[sapply(analiticos_best, function(x) !all(is.na(x)))]

# dividindo dataframe por métrica
analiticos_best = split(analiticos_best, analiticos_best$metrica)

# tipo
tipo = "one-step-ahead"
cv = "_fcv"

# métodos de ML
ml = rbind(
  readRDS(paste0("data/tourism_monthly/preds_ml/preds/", tipo, "/resumo", cv, ".RDS"))[["rmsse"]],
  readRDS(paste0("data/tourism_monthly/preds_ml/preds/", tipo, "/resumo", cv, ".RDS"))[["mase"]]
) |>
  transform(metrica = c(rep("rmsse", 7), rep("mase", 7)))

# split por métrica
ml = janitor::clean_names(ml)
ml = split(ml, ml$metrica)

# avaliar se os modelos de ML são melhores que os analíticos
lapply(list(rmsse = "rmsse", mase = "mase"), function(metrica) {
  data = lapply(colnames(ml[[metrica]][sapply(ml[[metrica]], is.numeric)]), function(nivel) {
    # melhor analítico
    bench = min(analiticos_best[[metrica]][nivel], na.rm = TRUE)
    # comparar com os ML
    data = ml[[metrica]][nivel] < bench
  })
  do.call(cbind, data)
}) |> print()
