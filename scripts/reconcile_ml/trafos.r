# funções de transformação

trafo_glmnet = function(x, param_set) {

  if (!is.null(x$regr.glmnet.s)) {
    x$regr.glmnet.s = 2^(x$regr.glmnet.s)
  }

  return(x)
}

trafo_ranger = function(x, param_set) {

  if (!is.null(x$ranger.min.node.size)) {
    x$regr.ranger.min.node.size = 2^(x$regr.ranger.min.node.size)
  }

  if (!is.null(x$regr.ranger.min.bucket)) {
    x$regr.ranger.min.bucket = 2^(x$regr.ranger.min.bucket)
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
