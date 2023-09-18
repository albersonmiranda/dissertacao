### TRAIN ###


source("scripts/reconcile_ml/5_train_hp.R")

# reprodutibilidade
set.seed(123)

# convertendo test set para data.table
new_data = data.table::as.data.table(new_data)

# lasso
model_lasso = lapply(task, function(tarefa) {
  learners$glmnet_lasso$train(tarefa)
  preds = learners$glmnet_lasso$predict_newdata(newdata = new_data)

  return(preds)
})

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


learners$glmnet_lasso$model
learners$glmnet_lasso$tuning_result
learners$glmnet_lasso$learner$model$regr.glmnet$model$beta
