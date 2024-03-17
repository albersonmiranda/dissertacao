### TRAIN ###


source("scripts/tourism/reconcile_ml_fcv/5_train_hp.R")

# reprodutibilidade
set.seed(123)

# convertendo test set para data.table
new_data = data.table::as.data.table(subset(previsoes_base, select = -xQuarter))

# nomeando listas
nomes_tasks = lapply(task, function(tarefa) {
  varname = tarefa$id
}) |> unlist()

# parallelization
future::plan("multisession")

# xgboost
ini = Sys.time()
preds_xgb = lapply(task, function(tarefa) {
  learners$xgb$train(tarefa)
  preds = learners$xgb$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
xgb_time = difftime(fim, ini, units = "hours")
names(preds_xgb) = nomes_tasks
list(preds_xgb, xgb_time) |> saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_xgb_fcv.RDS"), compress = FALSE)

# ranger
ini = Sys.time()
preds_ranger = lapply(task, function(tarefa) {
  learners$ranger$train(tarefa)
  preds = learners$ranger$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
ranger_time = difftime(fim, ini, units = "hours")
names(preds_ranger) = nomes_tasks
list(preds_ranger, ranger_time) |> saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_ranger_fcv.RDS"), compress = FALSE)

# glmnet
ini = Sys.time()
preds_glmnet = lapply(task, function(tarefa) {
  learners$glmnet$train(tarefa)
  preds = learners$glmnet$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
glmnet_time = difftime(fim, ini, units = "hours")
names(preds_glmnet) = nomes_tasks
list(preds_glmnet, glmnet_time) |> saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_glmnet_fcv.RDS"), compress = FALSE)

# lasso
ini = Sys.time()
preds_lasso = lapply(task, function(tarefa) {
  learners$glmnet_lasso$train(tarefa)
  preds = learners$glmnet_lasso$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
lasso_time = difftime(fim, ini, units = "hours")
names(preds_lasso) = nomes_tasks
list(preds_lasso, lasso_time) |> saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_lasso_fcv.RDS"), compress = FALSE)

# ridge
ini = Sys.time()
preds_ridge = lapply(task, function(tarefa) {
  learners$glmnet_ridge$train(tarefa)
  preds = learners$glmnet_ridge$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
ridge_time = difftime(fim, ini, units = "hours")
names(preds_ridge) = nomes_tasks
list(preds_ridge, ridge_time) |> saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_ridge_fcv.RDS"), compress = FALSE)

# svm
ini = Sys.time()
preds_svm = lapply(task, function(tarefa) {
  learners$svm$train(tarefa)
  preds = learners$svm$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
svm_time = difftime(fim, ini, units = "hours")
names(preds_svm) = nomes_tasks
list(preds_svm, svm_time) |>
  saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_svm_fcv.RDS"), compress = FALSE)

# lightgbm
ini = Sys.time()
preds_lightgbm = lapply(task, function(tarefa) {
  learners$lightgbm$train(tarefa)
  preds = learners$lightgbm$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
lightgbm_time = difftime(fim, ini, units = "hours")
names(preds_lightgbm) = nomes_tasks
list(preds_lightgbm, lightgbm_time) |>
  saveRDS(paste0("data/tourism/preds_ml/preds/", tipo, "/preds_lightgbm_fcv.RDS"), compress = FALSE)
