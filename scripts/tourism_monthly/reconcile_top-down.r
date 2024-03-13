# RECONCILIAÇÃO TOP-DOWN


# * MARK: Necessário pois a reconciliação top-down do pacote {fabletools} está quebrada

# reproducibilidade
set.seed(123)

# dados
tourism_hts = read.csv("data-raw/VN2017.csv") |>
  transform(
    X = NULL,
    X.1 = NULL
  ) |>
  ts(
    start = c(1998, 1),
    end = c(2017, 12),
    frequency = 12
  ) |>
  hts::hts(characters = c(1, 1, 1))

# train sample
tourism_hts_train = window(tourism_hts, end = c(2016, 12))

#test sample
tourism_hts_test = window(tourism_hts, start = c(2017, 1))

# previsão reconciliada
preds_hts = tourism_hts_train |>
  generics::forecast(
    method = "tdfp",
    fmethod = "arima",
    h = 12,
    keep.fitted = TRUE,
    parallel = TRUE
  )

# acurácia de cada nível
source("scripts/tourism_monthly/accuracy-gts.r")
acuracia_top_down = lapply(c(0:3, NULL), function(i) {
  accuracy.gts_new(preds_hts, tourism_hts_test, levels = c(i)) |>
    rowMeans()
})

acuracia_top_down = do.call("rbind", acuracia_top_down)

# acurácia média
acuracia_top_down_hier = accuracy.gts_new(preds_hts, tourism_hts_test) |> rowMeans(na.rm = TRUE)

# juntando
acuracia_top_down = rbind(acuracia_top_down, acuracia_top_down_hier) |>
  t()

# renomeando colunas
colnames(acuracia_top_down) = c("agregado", "state", "zone", "region", "hierarquia")

# adicionar coluna de nome do modelo
acuracia_top_down = transform(acuracia_top_down, .model = "td")

# save
saveRDS(acuracia_top_down, "data/tourism_monthly/preds_analitico/acuracia_top_down.rds")
