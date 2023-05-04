# DIAGRAMAS #

# pacotes
library(DiagrammeR)

# séries hierárquicas
nodes_h = tibble::tribble(
    ~id, ~tipo, ~label,
    1, "total", "Total",
    2, "estado", "Espírito Santo (A)",
    3, "município", "Vitória (AA)",
    4, "município", "Vila Velha (AB)",
    5, "município", "... (AC)",
    6, "estado", "Rio de Janeiro (B)",
    7, "município", "Rio de Janeiro (BA)",
    8, "município", "Duque de Caxias (BB)",
    9, "município", "... (BC)",
    10, "estado", "... (C)",
    11, "município", "... (CA)"
)

nodes_h = within(nodes_h, {
    shape = "rectangle"
    fontname = "Times New Roman"
    fillcolor = "#003468"
    fillcolor = ifelse(tipo == "estado", "#004B8D", fillcolor)
    fillcolor = ifelse(tipo == "município", "white", fillcolor)
    fontcolor = ifelse(tipo == "município", "#004B8D", "white")
    color = ifelse(tipo == "município", "#004B8D", fillcolor)
    width = 1.5
})

edges_h = tibble::tribble(
    ~from, ~to,
    1, 2,
    1, 6,
    1, 10,
    2, 3,
    2, 4,
    2, 5,
    6, 7,
    6, 8,
    6, 9,
    10, 11
)

edges_h = within(edges_h, {
    arrowhead = "none"
    color = "#004B8D"
})

create_graph(attr_theme = "tb") |>
    add_nodes_from_table(
        table = nodes_h,
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
        width = 1200)

# séries agrupadas
nodes_a = tibble::tribble(
    ~id, ~tipo, ~label,
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
    fillcolor = ifelse(tipo == "setor", "#56AF31", fillcolor)
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
        width = 1200)

# séries hierárquicas e agrupadas
# séries agrupadas
nodes_ha = tibble::tribble(
    ~id, ~tipo, ~label,
    1, "total", "Total",
    2, "setor", "Agro (X)",
    3, "setor", "Ind (Y)",
    4, "setor", "... (Z)",
    5, "estado", "ES (AX)",
    6, "estado", "RJ (BX)",
    7, "estado", "... (CX)",
    8, "estado", "ES (AY)",
    9, "estado", "RJ (BY)",
    10, "estado", "... (CY)",
    11, "estado", "... (CZ)",
    12, "municipio", "Vitória (AAY)",
    13, "municipio", "Vila Velha (ABY)",
    14, "municipio", "... (ACY)",
    15, "municipio", "Rio de Janeiro (BAY)",
    16, "municipio", "Duque de Caxias (BBY)",
    17, "municipio", "... (BCY)"
)

nodes_ha = within(nodes_ha, {
    shape = "rectangle"
    fontname = "Times New Roman"
    fillcolor = "#003468"
    fillcolor = ifelse(tipo == "setor", "#56AF31", fillcolor)
    fillcolor = ifelse(tipo == "estado", "#004B8D", fillcolor)
    fillcolor = ifelse(tipo == "municipio", "white", fillcolor)
    fontcolor = ifelse(tipo == "municipio", "#004B8D", "white")
    color = ifelse(tipo == "municipio", "#004B8D", fillcolor)
    width = ifelse(tipo == "municipio", 1.5, 1)
})

edges_ha = tibble::tribble(
    ~from, ~to,
    1, 2,
    1, 3,
    1, 4,
    2, 5,
    2, 6,
    2, 7,
    3, 8,
    3, 9,
    3, 10,
    4, 11,
    8, 12,
    8, 13,
    8, 14,
    9, 15,
    9, 16,
    9, 17
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
        width = 1200)

# séries agrupadas em outra ordem
nodes_ha = tibble::tribble(
    ~id, ~tipo, ~label,
    1, "total", "Total",
    2, "setor", "Agro (AX)",
    3, "setor", "Ind (AY)",
    4, "setor", "... (AZ)",
    5, "estado", "ES (A)",
    6, "estado", "RJ (B)",
    7, "estado", "... (C)",
    8, "setor", "Agro (BX)",
    9, "setor", "Ind (BY)",
    10, "setor", "... (BZ)",
    11, "setor", "Agro (CX)",
    12, "setor", "Ind (CY)",
    13, "setor", "... (CZ)",
)

nodes_ha = within(nodes_ha, {
    shape = "rectangle"
    fontname = "Times New Roman"
    fillcolor = "#003468"
    fillcolor = ifelse(tipo == "setor", "#56AF31", fillcolor)
    fillcolor = ifelse(tipo == "estado", "#004B8D", fillcolor)
    fillcolor = ifelse(tipo == "municipio", "white", fillcolor)
    fontcolor = ifelse(tipo == "municipio", "#004B8D", "white")
    color = ifelse(tipo == "municipio", "#004B8D", fillcolor)
    width = 1
})

edges_ha = tibble::tribble(
    ~from, ~to,
    1, 5,
    1, 6,
    1, 7,
    5, 2,
    5, 3,
    5, 4,
    6, 8,
    6, 9,
    6, 10,
    7, 11,
    7, 12,
    7, 13
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
        width = 1200)

# unload packages
detach("package:DiagrammeR")
