## code to prepare `estban` dataset

# pacotes
library(magrittr, include.only = "%>%")

# set Google BigQuery project
basedosdados::set_billing_id("monografia-359922")

# municípios x regiões imediatas
municipios = basedosdados::read_sql("
SELECT
  id_municipio
  , nome
  , nome_mesorregiao
  , nome_microrregiao
  , nome_regiao
  , nome_regiao_imediata
  , nome_regiao_intermediaria
FROM `basedosdados.br_bd_diretorios_brasil.municipio`
WHERE sigla_uf = 'ES'
")

# estban
estban = basedosdados::read_sql("
WITH estban AS (
  SELECT
    CAST(ano AS STRING) AS ano
    , CAST(mes AS STRING) AS mes
    , id_municipio
    , cnpj_agencia
    , CASE
          WHEN id_verbete = '160' THEN 'operações de crédito'
          WHEN id_verbete = '161' THEN 'empréstimos e títulos descontados'
          WHEN id_verbete = '162' THEN 'financiamentos'
          WHEN id_verbete IN ('163', '164', '165', '166') THEN 'financiamentos rurais'
          WHEN id_verbete IN ('167') THEN 'financiamentos agroindustriais'
          WHEN id_verbete = '169' THEN 'financiamentos imobiliários'
          WHEN id_verbete IN ('171', '172', '176') THEN 'outros créditos'
          WHEN id_verbete = '174' THEN 'provisão para operações de crédito'
          ELSE 'outros'
      END AS verbete
    , valor

  FROM `basedosdados.br_bcb_estban.agencia`

  WHERE
    cnpj_basico = '28127603'
    AND id_verbete BETWEEN '161' AND '162'
)

SELECT
  ano
  , mes
  , id_municipio
  , cnpj_agencia
  , verbete
  , SUM(valor) AS valor
FROM estban
GROUP BY
  ano
  , mes
  , id_municipio
  , cnpj_agencia
  , verbete
")

# formatando datas
estban = within(estban, {
  mes = formatC(as.numeric(mes), format = "d", width = 2, flag = "0")
  ref = as.Date(paste(ano, mes, "01", sep = "-"))
})

# identificando agências em atividade
agencias_fim = subset(estban, ref == max(ref), select = cnpj_agencia) |>
  (\(x) unique(x$cnpj_agencia))()

# identificando agências que já estavam em atividade ao início da série
agencias_ini = subset(estban, ref == min(ref), select = cnpj_agencia) |>
  (\(x) unique(x$cnpj_agencia))()

# filtrando apenas agências em atividade durante todo período
estban = subset(
  estban,
  cnpj_agencia %in% agencias_fim
  & cnpj_agencia %in% agencias_ini
)

# criando modelo de dados
estban$pk = seq_len(nrow(estban))
dm::dm(estban, municipios) |>
  # indicando chave primária
  dm::dm_add_pk(estban, pk) |>
  dm::dm_add_pk(municipios, id_municipio) |>
  # indicando chave estrangeira
  dm::dm_add_fk(estban, id_municipio, municipios, id_municipio, check = FALSE) |>
  dm::dm_draw(view_type = "all") |>
  DiagrammeRsvg::export_svg() |>
  xml2::read_xml() |>
  xml2::write_xml("img/data_model.svg")

# mesclando com tabela municípios
estban = merge(estban, municipios, by = "id_municipio")

# formatando em tsibble
estban = estban |>
  subset(
    select = c(
      ref,
      nome_mesorregiao,
      nome_microrregiao,
      nome,
      cnpj_agencia,
      verbete,
      valor
    )
  ) |>
  # alterando referência para mensal
  transform(
    ref = tsibble::yearmonth(ref)
  ) |>
  # formatando como tsibble
  tsibble::as_tsibble(
    key = c(
      "nome_mesorregiao",
      "nome_microrregiao",
      "nome",
      "cnpj_agencia",
      "verbete"
    ),
    index = ref
  ) |>
  tsibble::fill_gaps() |>
  fabletools::aggregate_key(
    (nome_mesorregiao / nome_microrregiao / nome / cnpj_agencia) * verbete,
    saldo = sum(valor)
  )

# salvando dataframe
saveRDS(estban, "data/estban.RDS", compress = FALSE)
