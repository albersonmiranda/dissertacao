# DIAGRAMAS #

# pacotes
library(DiagrammeR)

# estban
nodes_ha = tibble::tribble(
    ~id, ~tipo, ~label,
    1, "total", "Total",
    2, "mesorregião", "central",
    3, "mesorregião", "litoral norte",
    4, "mesorregião", "noroeste",
    5, "mesorregião", "sul",
    6, "municipio", "municípios",
    7, "agencia", "agências",
    8, "verbete", "empréstimos",
    9, "verbete", "financiamentos",
    10, "verbete", "imobiliário",
    11, "verbete", "rural"
)

nodes_ha = within(nodes_ha, {
    shape = "rectangle"
    fontname = "Times New Roman"
    fillcolor = "#003468"
    fillcolor = ifelse(tipo == "mesorregião", "#004B8D", fillcolor)
    fillcolor = ifelse(tipo == "municipio", "#02559e", fillcolor)
    fillcolor = ifelse(tipo == "agencia", "#0260b3", fillcolor)
    fillcolor = ifelse(tipo == "verbete", "#56AF31", fillcolor)
    fontcolor = "white"
    color = fillcolor
    width = ifelse(tipo %in% c("municipio", "agencia"), 4.7, 1)
})

edges_ha = tibble::tribble(
    ~from, ~to,
    1, 2,
    1, 3,
    1, 4,
    1, 5,
    2, 6,
    3, 6,
    4, 6,
    5, 6,
    6, 7,
    7, 8,
    7, 9,
    7, 10,
    7, 11
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
        file_name = "img/hier_agrup_est.png",
        file_type = "PNG",
        width = 1200)

# unload packages
detach("package:DiagrammeR")
