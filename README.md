# DISSERTAÇÃO

Este repositório contém minha dissertação de mestrado, no tema MÉTODOS DE MACHINE LEARNING PARARECONCILIAÇÃO ÓTIMA DE SÉRIESTEMPORAIS HIERÁRQUICAS E AGRUPADAS

## RESUMO

Na última década, a previsão de séries temporais hierárquicas experimentou um crescimento substancial, caracterizado por avanços que melhoraram significativamente a precisão dos modelos de previsão. Recentemente, os métodos de \textit{machine learning} foram integrados à literatura de previsão hierárquica como uma nova abordagem para a reconciliação de previsões. Este trabalho se baseia nesses avanços, explorando ainda mais o potencial dos métodos de \textit{machine learning} para otimizar a reconciliação de séries temporais hierárquicas e agrupadas. Além disso, investigou-se o impacto de várias estratégias de aquisição de conjuntos de treinamento, como previsões obtidas por \textit{rolling forecasting}, valores ajustados de modelos reestimados e valores ajustados dos modelos de previsão base, como também estratégias alternativas de validação cruzada. Para avaliar a metodologia proposta, dois estudos de caso foram realizados. O primeiro estudo se concentra no setor financeiro brasileiro, especificamente na previsão de saldos de empréstimos e financiamentos para o Banco do Estado do Espírito Santo. O segundo estudo usa conjuntos de dados de turismo doméstico australiano, que são frequentemente referenciados na literatura de séries temporais hierárquicas. Comparou-se a metodologia proposta com métodos analíticos para reconciliação de previsões, como o \textit{bottom-up}, \textit{top-down} e traço mínimo. Os resultados mostram que não há um método ou estratégia única que supere consistentemente todos os outros. No entanto, a combinação apropriada de método ML e estratégia pode levar a uma melhoria de até 93\% na precisão em comparação com o melhor método de reconciliação analítica.

## ESTRUTURA

📦dissertacao
 ┣ 📂config
 ┃ ┣ 📂beamer
 ┃ ┣ 📂elementos
 ┃ ┃ ┣ 📜dissertacao.bib
 ┃ ┃ ┣ 📜packages.bib
 ┃ ┃ ┣ 📜pos_textuais.tex
 ┃ ┃ ┗ 📜pre_textuais.tex
 ┃ ┗ 📂tema
 ┃ ┃ ┣ 📜customizacao.tex
 ┃ ┃ ┣ 📜ppgecotex.sty
 ┃ ┃ ┗ 📜preamble.tex
 ┣ 📂data
 ┃ ┣ 📂estban
 ┃ ┣ 📂tourism
 ┃ ┗ 📂tourism_monthly
 ┣ 📂data-raw
 ┣ 📂render
 ┃ ┣ 📜apresentacao.pdf
 ┃ ┣ 📜dissertacao.pdf
 ┃ ┗ 📜projeto.pdf
 ┣ 📂scripts
 ┃ ┣ 📂estban
 ┃ ┃ ┣ 📂reconcile_ml
 ┃ ┃ ┗ 📂reconcile_ml_fcv
 ┃ ┣ 📂tourism
 ┃ ┃ ┣ 📂reconcile_ml
 ┃ ┃ ┗ 📂reconcile_ml_fcv
 ┃ ┗ 📂tourism_monthly
 ┃ ┃ ┣ 📂reconcile_ml
 ┃ ┃ ┗ 📂reconcile_ml_fcv
 ┣ 📜apresentacao.qmd
 ┣ 📜dissertacao.qmd
 ┣ 📜projeto.qmd
 ┗ 📜_quarto.yml
