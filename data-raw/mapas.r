## code to prepare `mapas` dataset


# pacotes
library(ggplot2)

# estado do Espírito Santo
brasil = geobr::read_state(
  year = 2020
)

# mesorregiões
mesorregioes = geobr::read_meso_region(
  code_meso = "ES",
  year = 2020
)

# plots
plot_br = brasil |>
  ggplot(aes(fill = abbrev_state)) +
  geom_sf() +
  scale_fill_manual(
    values = c(ES = "#56AF31"),
    na.value = "#003468"
  ) +
  theme_void() +
  theme(legend.position = "none")

plot_meso = mesorregioes |>
  ggplot(aes(fill = name_meso)) +
  geom_sf() +
  coord_sf(xlim = c(-42, -39)) +
  labs(fill = "mesorregiões") +
  theme_void()

# exportar
ggsave(
  filename = "img/mapa-brasil.png",
  plot = plot_br,
  width = 1200,
  units = "px"
)