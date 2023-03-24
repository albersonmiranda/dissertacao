## code to prepare `estban` dataset

# pacotes
library(magrittr, include.only = "%>%")

# set Google BigQuery project
basedosdados::set_billing_id("monografia-359922")

estban = basedosdados::read_sql("
SELECT
  CAST(ano AS STRING) AS ano
  , CAST(mes AS STRING) AS mes
  , id_municipio
  , cnpj_agencia
  , CASE
        WHEN id_verbete = '160' THEN 'operações de crédito'
        WHEN id_verbete = '161' THEN 'empréstimos e títulos descontados'
        WHEN id_verbete = '162' THEN 'financiamentos'
        WHEN id_verbete = '163' THEN 'financiamentos rurais'
        WHEN id_verbete = '169' THEN 'financiamentos imobiliários'
        WHEN id_verbete = '172' THEN 'outros créditos'
        WHEN id_verbete = '174' THEN 'provisão para operações de crédito'
        ELSE 'outros'
    END AS verbete
  , valor

FROM `basedosdados.br_bcb_estban.agencia`

WHERE
  cnpj_basico = '28127603'
  AND id_verbete BETWEEN '160' AND '179'
")

# salvando dataframe
saveRDS(estban, "data/estban.RDS", compress = FALSE)
