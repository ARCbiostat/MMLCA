#' Assign subjects to the their most probable mm pattern according to LCA model
#' @description This function assign a subject to a latent mm pattern according to a LCA model and disease combinations at a specific point in time. The assignment is done according to the mode of the posterior membership probability given by the LCA model.
#' @param obj poLCA object
#' @param X matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#'
#' @return numeric vector with LCA class assignment for each row in X
#' @export
#'
#' @examples
assign_LCA <- function(obj, X) {
  pClY <- poLCA::poLCA.posterior(obj, y = X %>% dplyr::select(any_of(colnames(obj$y))))
  ng <- ncol(pClY)
  pred <- as.numeric(apply(pClY, 1, function(x) which.max(x))) # MODE
  return(pred)
}
