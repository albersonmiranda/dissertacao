# funções de transformação

trafo_glmnet = function(x, param_set) {

  if (!is.null(x$regr.glmnet.lambda)) {
    x$regr.glmnet.lambda = 2^(x$regr.glmnet.lambda)
  }

  return(x)
}

trafo_ranger = function(x, param_set) {

  if (!is.null(x$ranger.min.node.size)) {
    x$regr.ranger.min.node.size = 2^(x$regr.ranger.min.node.size)
  }

  return(x)
}

trafo_xgb = function(x, param_set) {

  if (!is.null(x$regr.xgboost.eta)) {
    x$regr.xgboost.eta = 10^(x$regr.xgboost.eta)
  }

  if (!is.null(x$regr.xgboost.lambda)) {
    x$regr.xgboost.lambda = 2^(x$regr.xgboost.lambda)
  }

  if (!is.null(x$regr.xgboost.alpha)) {
    x$regr.xgboost.alpha = 2^(x$regr.xgboost.alpha)
  }

  return(x)
}

trafo_svm = function(x, param_set) {

  if (!is.null(x$regr.svm.cost)) {
    x$regr.svm.cost = 2^(x$regr.svm.cost)
  }

  if (!is.null(x$regr.svm.gamma)) {
    x$regr.svm.gamma = 2^(x$regr.svm.gamma)
  }

  return(x)
}

trafo_lightgbm = function(x, param_set) {

  if (!is.null(x$regr.lightgbm.learning_rate)) {
    x$regr.lightgbm.learning_rate = 10^(x$regr.lightgbm.learning_rate)
  }

  if (!is.null(x$regr.lightgbm.min_data_in_leaf)) {
    x$regr.lightgbm.min_data_in_leaf = 2^(x$regr.lightgbm.min_data_in_leaf)
  }

  if (!is.null(x$regr.lightgbm.lambda_l1)) {
    x$regr.lightgbm.lambda_l1 = 2^(x$regr.lightgbm.lambda_l1)
  }

  if (!is.null(x$regr.lightgbm.lambda_l2)) {
    x$regr.lightgbm.lambda_l2 = 2^(x$regr.lightgbm.lambda_l2)
  }

  return(x)
}
