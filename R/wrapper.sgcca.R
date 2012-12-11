# -----------------------------------------------------------------------------------------
# wrapper.sgcca.R
# Author:    KA Le Cao
# Date started:  7/09/2013
# Last updated:	
# Objective:	wrapper fr sgcca function from package RGCCA
# Latest update:  
# -----------------------------------------------------------------------------------

wrapper.sgcca = function(
  data,
  design = 1 - diag(length(data)),
  penalty = rep(1, length(data)),
  ncomp = rep(1, length(data)), 
  scheme = "centroid",
  scale = TRUE, 
  init = "svd", 
  bias = TRUE,
  tol = .Machine$double.eps, 
  verbose = FALSE  
  ){
  
  # call function
  #function (A, C = 1-diag(length(A)), c1 = rep(1, length(A)), ncomp = rep(1, length(A)), scheme = "centroid", scale = TRUE, init = "svd", bias = TRUE, tol = .Machine$double.eps, verbose = FALSE)
    
  result.sgcca = sgcca(A = data, C = design, c1 = penalty, 
                       ncomp = ncomp,
                       scheme = scheme, scale = scale,
                       init = init, bias = bias, tol = tol, verbose = verbose)
  
  # outputs
  #this is the output from sgcca
#   out <- list(Y = shave.matlist(Y, ncomp), 
#               a = shave.matlist(a, ncomp), 
#               astar = shave.matlist(astar, ncomp),
#               C = C, c1 = c1, scheme = scheme,
#               ncomp = ncomp, crit = crit,
#               AVE = AVE,
#               #KA added names of rows and cols for plotIndiv and plotVar
#               names = list(indiv = rownames(A[[1]]))
#   )
#  class(out) <- "sgcca"
#  return(out)
  
  cl = match.call()
  cl[[1]] = as.name('sgcca')
  
  output = list(
    class = cl,
    data = data,
    variates = result.sgcca$Y,
    loadings = result.sgcca$a,
    loadings.star = result.sgcca$astar,
    design = design,
    penalty = penalty,
    scheme = scheme,
    ncomp = ncomp, 
    crit = result.sgcca$crit,
    AVE = list(AVE.data = result.sgcca$AVE$AVE_X, result.sgcca$AVE$AVE_outer, result.sgcca$AVE$AVE_inner), #rename?
    names = list(indiv = rownames(data[[1]]), var = sapply(data, colnames))
    
  )
#     call = cl,
#                 X = X, Y = Y, ncomp = ncomp, mode = mode, 
#                 keepX = keepX,
#                 keepY = keepY,
#                 mat.c = mat.c,
#                 mat.d = mat.d,
#                 mat.e = mat.e, 
#                 variates = list(X = mat.t, Y = mat.u),
#                 loadings = list(X = mat.a, Y = mat.b),
#                 names = list(X = X.names, Y = Y.names, indiv = ind.names))
#   if ((near.zero.var == T) & (length(nzv$Position > 0))) result$nzv = nzv
#   
#   class(result) = c("spls", "pls") 
  class(output) = 'sgcca'
  return(invisible(output))
  
}