## code to prepare `tourism` dataset


# formatando em séries temporais hierárquicas e agrupadas
tourism = tsibble::tourism |>
  transform(
    State = iconv(tolower(gsub("-|, | |'", "_", State)), "UTF-8", "ASCII//TRANSLIT"),
    Region = iconv(tolower(gsub("-|, | |'", "_", Region)), "UTF-8", "ASCII//TRANSLIT"),
    Purpose = iconv(tolower(gsub("-|, | |'", "_", Purpose)), "UTF-8", "ASCII//TRANSLIT")
  ) |>
  tsibble::as_tsibble(
    key = c(State, Region, Purpose),
    index = Quarter
  ) |>
  fabletools::aggregate_key(
    (State / Region) * Purpose,
    Trips = sum(Trips)
  )

# turismo mensal
# TODO: Thanks to professor Nikolaos Kourentzes for the dataset
tourism_monthly = read.csv("data-raw/VN2017.csv") |>
  transform(
    ref = seq.Date(as.Date("1998-01-01"), as.Date("2017-12-01"), by = "month"),
    X = NULL,
    X.1 = NULL
  ) |>
  tidyr::pivot_longer(
    cols = -ref,
    names_to = "Region",
    values_to = "Trips"
  ) |>
  transform(
    State = substr(Region, 1, 1),
    Zone = substr(Region, 1, 2),
    ref = tsibble::yearmonth(ref)
  ) |>
  tsibble::as_tsibble(
    key = c(State, Zone, Region),
    index = ref
  ) |>
  fabletools::aggregate_key(
    (State / Zone / Region),
    Trips = sum(Trips)
  )

# salvando dataframe
saveRDS(tourism, "data/tourism/tourism.RDS")
saveRDS(tourism_monthly, "data/tourism_monthly/tourism_monthly.RDS")
