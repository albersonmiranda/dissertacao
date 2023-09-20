### TRAIN ###


source("scripts/reconcile_ml/5_train_hp.R")

# reprodutibilidade
set.seed(123)

# lasso
lasso_coef = lapply(task, function(tarefa) {
  # realiza treino
  learners$glmnet_lasso$train(tarefa)
  # obtém s ótimo
  s = learners$glmnet_lasso$model$learner$model$regr.glmnet$param_vals$s
  # obtém coeficientes
  coeficientes = as.matrix(coef(learners$glmnet_lasso$learner$model$regr.glmnet$model, s = s))
  # obtém variáveis em que coeficientes são diferentes de zero
  variaveis = subset(coeficientes, coeficientes[, 1] != 0)

  return(variaveis)
})

# nomeando listas
nomes_tasks = lapply(task, function(tarefa) {
  varname = tarefa$id
}) |> unlist()

names(lasso_coef) = nomes_tasks
names(task) = nomes_tasks

saveRDS(lasso_coef, "data/lasso_coef.RDS", compress = FALSE)

medidas = lapply(preds_lasso, function(preds) {
  preds$score(msr("regr.rmse"))
})

obj_names = lapply(task[1:2], function(tarefa) {
  varname = tarefa$id
}) |> unlist()

names(medidas) = obj_names

# exportar
export = cbind(tibble::as_tibble(new_data), tibble::as_tibble(data.table::as.data.table(preds_lasso[[1]])))

# salvar
saveRDS(model, "data/model.RDS", compress = FALSE)
