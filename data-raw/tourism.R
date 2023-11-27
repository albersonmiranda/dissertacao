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
    (State / Region),
    Trips = sum(Trips)
  )

# salvando dataframe
saveRDS(tourism, "data/tourism/tourism.RDS")
