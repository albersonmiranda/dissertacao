### TRAIN ###


source("scripts/reconcile_ml/5_train_hp.R")

# reprodutibilidade
set.seed(123)

# convertendo test set para data.table
new_data = data.table::as.data.table(new_data)

# xgboost
preds_xgb = lapply(task, function(tarefa) {
  learners$xgb$train(tarefa)
  preds = learners$xgb$predict_newdata(newdata = new_data)

  return(preds)
})

# ranger
preds_ranger = lapply(task, function(tarefa) {
  learners$ranger$train(tarefa)
  preds = learners$ranger$predict_newdata(newdata = new_data)

  return(preds)
})

# glmnet
preds_glmnet = lapply(task, function(tarefa) {
  learners$glmnet$train(tarefa)
  preds = learners$glmnet$predict_newdata(newdata = new_data)

  return(preds)
})

# lasso
preds_lasso = lapply(task, function(tarefa) {
  learners$glmnet_lasso$train(tarefa)
  preds = learners$glmnet_lasso$predict_newdata(newdata = new_data)

  return(preds)
})

# ridge
preds_ridge = lapply(task, function(tarefa) {
  learners$glmnet_ridge$train(tarefa)
  preds = learners$glmnet_ridge$predict_newdata(newdata = new_data)

  return(preds)
})
