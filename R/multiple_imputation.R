#' Function to obtain imputate multiple imputations of the assigned MM patterns
#'
#' @param obj LCA object
#' @param data
#' @param nimp
#'
#' @return
#' @export
#'
#' @examples
multiple_imputation <- function(obj, data, nimp) {
  data_imp <- list()
  pClY <- poLCA::poLCA.posterior(obj, y = X)
  ng <- ncol(pClY)
  for (i in 1:nimp) {
    data_imp[[i]] <- data
    data_imp[[i]]$MP <- apply(post, 1, function(p) {
      sample(1:ng,
             size = nimp,
             replace = TRUE,
             prob = pClY)
    })
  }
return(data_imp)
}
