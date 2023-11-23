## code to prepare `mapas` dataset


# pacotes
library(ggplot2)
library(fabletools)

# dados estban
estban = readRDS("data/estban/estban.rds")

# convert cmyk to hex


# paleta de cores Banestes
cores = list(
  azul_banestes = "#0041C4",
  verde_banestes = "#4FFF00",
  azul_medio_banestes = "#0D8CFF",
  azul_claro_banestes = "#82E3FF",
  azul_escuro_aux = "#002F7A",
  azul_medio_aux = "#0056C4",
  azul_claro_aux = "#0079DB",
  bege_aux = "#E0DB9E",
  cor_quente_aux = "#991F00",
  cinza_aux = "#CDD1D1"
)

# estado do Espírito Santo
brasil = geobr::read_state(
  year = 2020
)

# mesorregiões
mesorregioes = geobr::read_meso_region(
  code_meso = "ES",
  year = 2020
)

# microrregiões
microrregioes = geobr::read_micro_region(
  code_micro = "ES",
  year = 2020
)

# municipalidades
municipalidades = geobr::read_municipality(
  code_muni = "ES",
  year = 2020
) |>
  transform(
    name_muni = gsub(" ", "_", iconv(tolower(name_muni), "UTF-8", "ASCII//TRANSLIT"))
  )

# contagem de agências por município
agencias = aggregate(
  cnpj_agencia ~ nome,
  data = subset(estban, !is_aggregated(nome) & !is_aggregated(cnpj_agencia), select = c("nome", "cnpj_agencia")) |> transform(nome = as.character(nome), cnpj_agencia = as.character(cnpj_agencia)),
  FUN = function(x) length(unique(x))
)

# merge agencia x municipalidades
municipalidades = merge(
  x = municipalidades,
  y = agencias,
  by.x = "name_muni",
  by.y = "nome",
  all.x = TRUE
)

# plots
plot_br = brasil |>
  ggplot(aes(fill = abbrev_state)) +
  geom_sf() +
  scale_fill_manual(
    values = c(ES = "#56AF31")
  ) +
  labs(fill = "Estado") +
  theme_void() +
  theme(legend.position = "none")

plot_meso = mesorregioes |>
  ggplot(aes(fill = name_meso)) +
  geom_sf() +
  coord_sf(xlim = c(-42, -39)) +
  labs(fill = "mesorregiões") +
  theme_void()

plot_micro = mesorregioes |>
  ggplot(aes(fill = name_meso)) +
  geom_sf() +
  geom_sf(data = microrregioes, fill = NA) +
  geom_sf_text(data = microrregioes, aes(label = name_micro, fill = NA, color = "microrregiões")) +
  scale_color_manual(name = NULL, values = c("microrregiões" = "#000000")) +
  coord_sf(xlim = c(-42, -39)) +
  labs(fill = "mesorregiões") +
  theme_void()

plot_municipalidades = municipalidades |>
  ggplot(aes(fill = as.factor(cnpj_agencia))) +
  geom_sf() +
  scale_fill_manual(
    values = with(
      cores,
      c(
        cores$cinza_aux,
        azul_claro_banestes,
        azul_medio_banestes,
        azul_escuro_aux,
        verde_banestes
      )
    ),
    na.value = "white"
  ) +
  coord_sf(xlim = c(-42, -39)) +
  labs(fill = "n agências") +
  theme_void()

# exportar
ggsave(
  filename = "img/mapa-brasil.png",
  plot = plot_br
)

ggsave(
  filename = "img/mapa-microrregioes.png",
  plot = plot_micro
)

ggsave(
  "img/mapa-municipalidades.png",
  plot = plot_municipalidades
)
