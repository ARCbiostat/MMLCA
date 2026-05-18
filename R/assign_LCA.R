#' Assign subjects to the their most probable mm pattern according to LCA model
#' @description This function assign a subject to a latent mm pattern according to a LCA model and disease combinations at a specific point in time. The assignment is done according to the mode of the posterior membership probability given by the LCA model.
#' @param obj poLCA object
#' @param X matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param returnprob boolean indicating whether posterior probabilities are returned along side assignment (default to FALSE).
#' @return numeric vector with LCA class assignment for each row in X or matrix containing posterior probability classes (see  also \link{poLCA.posterior}) and LCA class assignement
#' @export
#'
#' @examples
assign_LCA <- function(obj, X,returnprob=F) {
  if(ncol(X %>% dplyr::select(any_of(colnames(obj$y))))!=length(colnames(obj$y))) stop("Some diseases used for the LCA are missing from X")
  pClY <- poLCA::poLCA.posterior(obj, y = X %>% dplyr::select(any_of(colnames(obj$y))))
  ng <- ncol(pClY)
  pred <- as.numeric(apply(pClY, 1, function(x) which.max(x))) # MODE
  if(returnprob){
    res <- cbind(pClY,pred)
    colnames(res)[ncol(res)] <- "Class"
    return(res)
  }else return(pred)
}
