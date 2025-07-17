run_lca_cv <- function(fold,nclasses,X,conditions,nrep){
  res <- lapply(nclasses, function(x) run_LCA(x, X = X[-fold,], conditions = conditions, nrep = nrep))
  objects <- lapply(res, function(x) x$obj)
  names(objects) <- nclasses
  entropy <- unlist(lapply(objects, function(x) function(x)get_entropy(x,X[fold,],ratio=F)))
  names(entropy) <- nclasses
  ext_accuracy <- unlist(lapply(1:length(objects), function(x) sum(diag(get_internal_validation_matrix(objects[[x]], X[fold,])))/nclasses[x]))
  dat_res <- data.frame(cv=fold,
                    nclass=nclasses,
                    acc=ext_accuracy,
                    entropy=entropy)


  colnames(dat_res) <- c(
    "CV",
    "nclass",
    "Assignment accuracy (%)",
    "Entropy")
  return(dat_res)
}
