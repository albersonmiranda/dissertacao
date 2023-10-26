# DIAGRAMAS #

# pacotes
library(DiagrammeR)

# séries hierárquicas
node_chapters = create_node_df(
  n = 3,
  label = c(
    "País",
    "Estado",
    "Município"
  ),
  rank = c(
    "total",
    "estado",
    "município"
  ),
  type = "chapter",
  group = "left"
)

nodes_h = tibble::tribble(
  ~type, ~label,
  "total", "Total",
  "estado", "A",
  "município", "AA",
  "município", "AB",
  "estado", "B",
  "município", "BA",
  "município", "BB",
  "estado", "C",
  "município", "CA",
  "município", "CB"
)

nodes = combine_ndfs(node_chapters, nodes_h) |>
  transform(rank = ifelse(type != "chapter", type, rank))

nodes = within(nodes, {
  shape = "rectangle"
  fontname = "Times New Roman"
  fillcolor = ifelse(type == "chapter", "#56AF31", "#003468")
  fillcolor = ifelse(type == "estado", "#004B8D", fillcolor)
  fillcolor = ifelse(type == "município", "white", fillcolor)
  fontcolor = ifelse(type == "município", "#004B8D", "white")
  color = ifelse(type == "município", "#004B8D", fillcolor)
  width = 1.5
})

edges_h = tibble::tribble(
  ~from, ~to, ~style,
  1, 2, "invis",
  2, 3, "invis",
  4, 5, NA,
  4, 8, NA,
  4, 11, NA,
  5, 6, NA,
  5, 7, NA,
  8, 9, NA,
  8, 10, NA,
  11, 12, NA,
  11, 13, NA
)

edges_h = within(edges_h, {
  arrowhead = "none"
  color = "#004B8D"
})

create_graph(attr_theme = "tb") |>
  add_nodes_from_table(
    table = nodes,
    label_col = label
  ) |>
  add_edges_from_table(
    table = edges_h,
    from_col = from,
    to_col = to,
    from_to_map = id_external
  ) |>
  export_graph(
    file_name = "img/hierarq.png",
    file_type = "PNG",
    width = 1200
  )

# séries agrupadas
nodes_a = tibble::tribble(
  ~id, ~type, ~label,
  1, "total", "Total",
  2, "setor", "Agricultura",
  3, "setor", "Ind. Extrativa",
  4, "setor", "Ind. Transf.",
  5, "setor", "Eletricidade",
  6, "setor", "Construção",
  7, "setor", "..."
)

nodes_a = within(nodes_a, {
  shape = "rectangle"
  fontname = "Times New Roman"
  fillcolor = "#003468"
  fillcolor = ifelse(type == "setor", "#56AF31", fillcolor)
  fontcolor = "white"
  color = fillcolor
  width = 1.5
})

edges_a = tibble::tribble(
  ~from, ~to,
  1, 2,
  1, 3,
  1, 4,
  1, 5,
  1, 6,
  1, 7
)

edges_a = within(edges_a, {
  arrowhead = "none"
  color = "#004B8D"
})

create_graph(attr_theme = "tb") |>
  add_nodes_from_table(
    table = nodes_a,
    label_col = label
  ) |>
  add_edges_from_table(
    table = edges_a,
    from_col = from,
    to_col = to,
    from_to_map = id_external
  ) |>
  export_graph(
    file_name = "img/agrupadas.png",
    file_type = "PNG",
    width = 1200
  )

# séries hierárquicas e agrupadas
nodes_ha = tibble::tribble(
  ~id, ~type, ~label,
  1, "total", "Total",
  2, "setor", "Agr. (X)",
  3, "setor", "Ind. (Y)",
  4, "estado", "A (XA)",
  5, "estado", "B (XB)",
  6, "estado", "C (XC)",
  7, "estado", "A (YA)",
  8, "estado", "B (YB)",
  9, "estado", "C (YC)"
)

nodes_ha = within(nodes_ha, {
  shape = "rectangle"
  fontname = "Times New Roman"
  fillcolor = "#003468"
  fillcolor = ifelse(type %in% c("setor", "chapter"), "#56AF31", fillcolor)
  fillcolor = ifelse(type == "estado", "#004B8D", fillcolor)
  fillcolor = ifelse(type == "municipio", "white", fillcolor)
  fontcolor = ifelse(type == "municipio", "#004B8D", "white")
  color = ifelse(type == "municipio", "#004B8D", fillcolor)
  width = ifelse(type %in% c("municipio", "setor"), 1.5, 1)
})

edges_ha = tibble::tribble(
  ~from, ~to, ~style,
  1, 2, NA,
  1, 3, NA,
  2, 4, NA,
  2, 5, NA,
  2, 6, NA,
  3, 7, NA,
  3, 8, NA,
  3, 9, NA
)

edges_ha = within(edges_ha, {
  arrowhead = "none"
  color = "#004B8D"
})

create_graph(attr_theme = "tb") |>
  add_nodes_from_table(
    table = nodes_ha,
    label_col = label
  ) |>
  add_edges_from_table(
    table = edges_ha,
    from_col = from,
    to_col = to,
    from_to_map = id_external
  ) |>
  export_graph(
    file_name = "img/hier_agrup.png",
    file_type = "PNG",
    width = 1200
  )

# séries agrupadas em outra ordem
nodes_ha = tibble::tribble(
  ~id, ~type, ~label,
  1, "total", "Total",
  2, "estado", "A",
  3, "estado", "B",
  4, "estado", "C",
  5, "setor", "Agr. (AX)",
  6, "setor", "Ind. (AY)",
  7, "setor", "Agr. (BX)",
  8, "setor", "Ind. (BY)",
  9, "setor", "Agr. (CX)",
  10, "setor", "Ind. (CY)"
)

nodes_ha = within(nodes_ha, {
  shape = "rectangle"
  fontname = "Times New Roman"
  fillcolor = "#003468"
  fillcolor = ifelse(type %in% c("setor", "chapter"), "#56AF31", fillcolor)
  fillcolor = ifelse(type == "estado", "#004B8D", fillcolor)
  fillcolor = ifelse(type == "municipio", "white", fillcolor)
  fontcolor = ifelse(type == "municipio", "#004B8D", "white")
  color = ifelse(type == "municipio", "#004B8D", fillcolor)
  width = ifelse(type %in% c("municipio", "setor"), 1.5, 1)
})

edges_ha = tibble::tribble(
  ~from, ~to, ~style,
  1, 2, NA,
  1, 3, NA,
  1, 4, NA,
  2, 5, NA,
  2, 6, NA,
  3, 7, NA,
  3, 8, NA,
  4, 9, NA,
  4, 10, NA
)

edges_ha = within(edges_ha, {
  arrowhead = "none"
  color = "#004B8D"
})

create_graph(attr_theme = "tb") |>
  add_nodes_from_table(
    table = nodes_ha,
    label_col = label
  ) |>
  add_edges_from_table(
    table = edges_ha,
    from_col = from,
    to_col = to,
    from_to_map = id_external
  ) |>
  export_graph(
    file_name = "img/hier_agrup_2.png",
    file_type = "PNG",
    width = 1200
  )

# unload packages
detach("package:DiagrammeR")
