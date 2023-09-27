### TRAIN ###


source("scripts/reconcile_ml/5_train_hp.R")

# reprodutibilidade
set.seed(123)

# convertendo test set para data.table
new_data = data.table::as.data.table(new_data)

# parallelization
future::plan("multisession")

# xgboost
ini = Sys.time()
preds_xgb = lapply(task, function(tarefa) {
  learners$xgb$train(tarefa) |> progressr::with_progress()
  preds = learners$xgb$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
xgb_time = difftime(fim, ini, units = "secs")

# ranger
ini = Sys.time()
preds_ranger = lapply(task, function(tarefa) {
  learners$ranger$train(tarefa) |> progressr::with_progress()
  preds = learners$ranger$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
ranger_time = difftime(fim, ini, units = "secs")

# glmnet
ini = Sys.time()
preds_glmnet = lapply(task, function(tarefa) {
  learners$glmnet$train(tarefa) |> progressr::with_progress()
  preds = learners$glmnet$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
glmnet_time = difftime(fim, ini, units = "secs")

# lasso
ini = Sys.time()
preds_lasso = lapply(task[1], function(tarefa) {
  learners$glmnet_lasso$train(tarefa) |> progressr::with_progress()
  preds = learners$glmnet_lasso$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
lasso_time = difftime(fim, ini, units = "secs")

# ridge
ini = Sys.time()
preds_ridge = lapply(task, function(tarefa) {
  learners$glmnet_ridge$train(tarefa) |> progressr::with_progress()
  preds = learners$glmnet_ridge$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
ridge_time = difftime(fim, ini, units = "secs")
