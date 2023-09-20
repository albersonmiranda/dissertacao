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
