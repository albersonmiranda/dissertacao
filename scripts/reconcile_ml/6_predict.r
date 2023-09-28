### TRAIN ###


source("scripts/reconcile_ml/5_train_hp.R")

# reprodutibilidade
set.seed(123)

# convertendo test set para data.table
new_data = data.table::as.data.table(new_data)

# nomeando listas
nomes_tasks = lapply(task, function(tarefa) {
  varname = tarefa$id
}) |> unlist()

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
xgb_time = difftime(fim, ini, units = "hours")
names(preds_xgb) = nomes_tasks
list(preds_xgb, xgb_time) |> saveRDS("data/preds_xgb.RDS", compress = FALSE)

# ranger
ini = Sys.time()
preds_ranger = lapply(task, function(tarefa) {
  learners$ranger$train(tarefa) |> progressr::with_progress()
  preds = learners$ranger$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
ranger_time = difftime(fim, ini, units = "hours")
names(preds_ranger) = nomes_tasks
list(preds_ranger, ranger_time) |> saveRDS("data/preds_ranger.RDS", compress = FALSE)

# glmnet
ini = Sys.time()
preds_glmnet = lapply(task, function(tarefa) {
  learners$glmnet$train(tarefa) |> progressr::with_progress()
  preds = learners$glmnet$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
glmnet_time = difftime(fim, ini, units = "hours")
names(preds_glmnet) = nomes_tasks
list(preds_glmnet, glmnet_time) |> saveRDS("data/preds_glmnet.RDS", compress = FALSE)

# lasso
ini = Sys.time()
preds_lasso = lapply(task, function(tarefa) {
  learners$glmnet_lasso$train(tarefa) |> progressr::with_progress()
  preds = learners$glmnet_lasso$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
lasso_time = difftime(fim, ini, units = "hours")
names(preds_lasso) = nomes_tasks
list(preds_lasso, lasso_time) |> saveRDS("data/preds_lasso.RDS", compress = FALSE)

# ridge
ini = Sys.time()
preds_ridge = lapply(task, function(tarefa) {
  learners$glmnet_ridge$train(tarefa) |> progressr::with_progress()
  preds = learners$glmnet_ridge$predict_newdata(newdata = new_data)

  return(preds)
})
fim = Sys.time()
ridge_time = difftime(fim, ini, units = "hours")
names(preds_ridge) = nomes_tasks
list(preds_ridge, ridge_time) |> saveRDS("data/preds_ridge.RDS", compress = FALSE)