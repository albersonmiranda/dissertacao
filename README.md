# DISSERTAÇÃO

Este repositório contém minha dissertação de mestrado, no tema Métodos de Machine Learning para Reconciliação Ótima de Séries Temporais Hierárquicas e Agrupadas. A edição de texto foi realizada em Quarto e Latex.

## RESUMO

<div style="text-align: justify">
Na última década, a previsão de séries temporais hierárquicas experimentou um crescimento substancial, caracterizado por avanços que melhoraram significativamente a precisão dos modelos de previsão. Recentemente, os métodos de *machine learning* foram integrados à literatura de previsão hierárquica como uma nova abordagem para a reconciliação de previsões. Este trabalho se baseia nesses avanços, explorando ainda mais o potencial dos métodos de *machine learning* para otimizar a reconciliação de séries temporais hierárquicas e agrupadas. Além disso, investigou-se o impacto de várias estratégias de aquisição de conjuntos de treinamento, como previsões obtidas por *rolling forecasting*, valores ajustados de modelos reestimados e valores ajustados dos modelos de previsão base, como também estratégias alternativas de validação cruzada. Para avaliar a metodologia proposta, dois estudos de caso foram realizados. O primeiro estudo se concentra no setor financeiro brasileiro, especificamente na previsão de saldos de empréstimos e financiamentos para o Banco do Estado do Espírito Santo. O segundo estudo usa conjuntos de dados de turismo doméstico australiano, que são frequentemente referenciados na literatura de séries temporais hierárquicas. Comparou-se a metodologia proposta com métodos analíticos para reconciliação de previsões, como o *bottom-up*, *top-down* e traço mínimo. Os resultados mostram que não há um método ou estratégia única que supere consistentemente todos os outros. No entanto, a combinação apropriada de método ML e estratégia pode levar a uma melhoria de até 93% na precisão em comparação com o melhor método de reconciliação analítica.
</div>

## ABSTRACT

<div style="text-align: justify">
In the last decade, hierarchical time series forecasting has experienced substantial growth, characterized by advancements that have significantly improved the accuracy of forecasting models. Recently, machine learning methods have been integrated into the literature on hierarchical time series as a new approach for forecasting reconciliation. This work builds upon these advancements by further exploring the potential of ML methods for optimizing the reconciliation of hierarchical and grouped time series. Moreover, the impact of various training set acquisition strategies, such as in-sample forecasts obtained through rolling origin forecasting, fitted values of reestimated models, and fitted values of base forecast models, as well as alternative cross-validation strategies, was investigated. To evaluate the proposed methodology, two case studies were carried out. The first study focuses on the Brazilian financial sector, specifically forecasting loan and financing balances for the State Bank of Espírito Santo. The second study uses Australian domestic tourism datasets, which are frequently referenced in hierarchical time series literature. The proposed methodology was compared with traditional methods for forecasting reconciliation such as bottom-up, top-down and minimum trace. The results show that there is no unique method or strategy that consistently outperforms all others. Nonetheless, the appropriate combination of ML method and strategy can lead to up to a 93% improvement in accuracy compared to the best-performing analytical reconciliation method.
</div>

## ESTRUTURA

├───📁 .devcontainer/\
│ ├───📄 devcontainer.json\
│ ├───📄 Dockerfile\
│ └───📄 requirements.txt\
├───📁 config/\
│ ├───📁 beamer/\
│ ├───📁 elementos/\
│ ├───📁 tema/\
│ └───📄 clean.r\
├───📁 data/\
│ ├───📁 estban/\
│ ├───📁 tourism/\
│ └───📁 tourism_monthly/\
├───📁 data-raw/\
│ ├───📄 estban.R\
│ ├───📄 tourism.R\
│ └───📄 VN2017.csv\
├───📁 docs/\
│ └───📄 academico.xlsx\
├───📁 render/\
│ ├───📄 apresentacao.pdf\
│ ├───📄 dissertacao.pdf\
│ └───📄 projeto.pdf\
├───📁 scripts/\
│ ├───📁 estban/\
│ ├───📁 tourism/\
│ └───📁 tourism_monthly/\
├───📄 .gitignore\
├───📄 apresentacao.qmd\
├───📄 dissertacao.qmd\
├───📄 projeto.qmd\
└───📄 README.md