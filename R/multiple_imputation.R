#' Function to obtain imputate multiple imputations of the assigned MM patterns
#'
#' @param obj LCA object
#' @param data your dataset
#' @param nimp number of imputated datasets
#'
#' @return list of nimp dataset with assigned MM pattern according to posterior distribution probabilities
#' @export
#'
#' @examples
multiple_imputation <- function(obj, data, nimp) {
  X <- data %>% dplyr::select(dplyr::any_of(colnames(obj$y)))
  if (ncol(X) != length(colnames(obj$y))) {
    stop("Some disease columns are missing!")
  }
  lev <- unique(unlist(lapply(1:ncol(X), function(y) {
    unique(X[
      ,
      y
    ])
  })))
  if (NA %in% lev) {
    stop("Disease columns cannot contain missing values.")
  }
  if (!all(lev %in% c(0, 1)) | any(sapply(lev, is.character))) {
    stop("Disease columns must be numeric 0/1 variables.")
  }
  X %<>% dplyr::mutate_all(function(x) x + 1)
  data_imp <- list()
  pClY <- poLCA::poLCA.posterior(obj, y = X)
  ng <- ncol(pClY)
  for (i in 1:nimp) {
    data_imp[[i]] <- data
    data_imp[[i]]$MP <- unlist(lapply(1:nrow(data), function(x) sample(1:ng, size = 1, replace = TRUE, prob = pClY[x, ])))
  }
  return(data_imp)
}
