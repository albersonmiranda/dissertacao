### TRAIN ###


source("scripts/reconcile_ml/3_hyperparameters.R")

# reprodutibilidade
set.seed(123)

# convertendo test set para data.table
new_data = data.table::as.data.table(new_data)

# treino
preds_xgboost = lapply(task[1:2], function(tarefa) {
  learners$xgb$train(tarefa)
  preds = learners$xgb$predict_newdata(newdata = new_data)

  return(preds)
})

lapply(preds_xgboost, function(preds) {
  preds$score(msr("regr.rmse"))
})

obj_names = lapply(task[1:2], function(tarefa) {
  varname = tarefa$id
}) |> unlist()

# predições
preds = lapply(model_xgboost, function(model) {
  model = model$predict_newdata(newdata = new_data)
})

# exportar
export = cbind(tibble::as_tibble(new_data), tibble::as_tibble(data.table::as.data.table(preds)))

# salvar
saveRDS(model, "data/model.RDS", compress = FALSE)