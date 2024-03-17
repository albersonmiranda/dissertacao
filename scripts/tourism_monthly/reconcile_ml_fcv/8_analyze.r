### TRAIN ###


source("scripts/reconcile_ml/5_train_hp.r")

# reprodutibilidade
set.seed(123)

# parallelization
future::plan("multisession")

# lasso
lasso_coef = lapply(task, function(tarefa) {
  # realiza treino
  learners$glmnet_lasso$train(tarefa)
  # obtém s ótimo
  lambda = learners$glmnet_lasso$model$learner$model$regr.glmnet$param_vals$lambda
  # obtém coeficientes
  coeficientes = as.matrix(coef(learners$glmnet_lasso$learner$model$regr.glmnet$model, s = lambda))
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

# salvando coeficientes do lasso
saveRDS(lasso_coef, "data/lasso_coef.RDS", compress = FALSE)
