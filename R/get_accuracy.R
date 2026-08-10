#' Function to get the accuracy from LCA object
#'
#' @param obj fit object of class poLCA.
#' @param X matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#'
#' @return numeric
#' @export
#'
#' @examples
get_accuracy <- function(fit,X){
  M <- get_internal_validation_matrix(fit, X)
  w <- colSums(M)
  sum(diag(M)*w)/sum(w)
}
