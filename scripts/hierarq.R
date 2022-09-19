nodes = tibble::tribble(
    ~id, ~tipo, ~label,
    1, "total", "Total",
    2, "estado", "Espírito Santo",
    3, "município", "Vitória",
    4, "município", "Vila Velha",
    5, "município", "...",
    6, "estado", "Rio de Janeiro",
    7, "município", "Rio de Janeiro",
    8, "município", "Duque de Caxias",
    9, "município", "...",
    10, "estado", "...",
    11, "município", "..."
)

nodes = within(nodes, {
    shape = "rectangle"
    fontname = "Times New Roman"
    fillcolor = "#003468"
    fillcolor = ifelse(tipo == "estado", "#004B8D", fillcolor)
    fillcolor = ifelse(tipo == "município", "white", fillcolor)
    fontcolor = ifelse(tipo == "município", "#004B8D", "white")
    color = ifelse(tipo == "município", "#004B8D", fillcolor)
    width = 1.5
})

edges = tibble::tribble(
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

edges = within(edges, {
    arrowhead = "none"
    color = "#004B8D"
})

DiagrammeR::create_graph(attr_theme = "tb") |>
    DiagrammeR::add_nodes_from_table(
        table = nodes,
        label_col = label
    ) |>
    DiagrammeR::add_edges_from_table(
        table = edges,
        from_col = from,
        to_col = to,
        from_to_map = id_external
    ) |>
    DiagrammeR::export_graph(
        file_name = "img/hierarq.png",
        file_type = "PNG",
        width = 1200)
