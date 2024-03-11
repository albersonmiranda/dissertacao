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

# acurácia
source("scripts/tourism_monthly/accuracy-gts.r")

acuracia_top_down = lapply(1:3, function(i) {
  accuracy.gts_new(preds_hts, tourism_hts_test, levels = c(i)) |>
  rowMeans()
})

accuracy.gts_new(preds_hts, tourism_hts_test) |>
  rowMeans()

hts::accuracy.gts(preds_hts, tourism_hts_test, levels = 1) |> 
  rowMeans()
# previsões de cada nó
hts::aggts(preds_hts, levels = c(1, 2, 3))
