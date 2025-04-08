#' Function to get the entropy from LCA object
#'
#' @param obj fit object of class poLCA.
#' @param X matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param ratio boolen indicating whether the ratio between the prior and the posterior entropy should be returned. Default to TRUE.
#'
#' @return numeric
#' @export
#'
#' @examples
get_entropy <- function(obj, X, ratio = T) {
  error_prior <- entropy(obj$P)
  posterior_probs <- poLCA::poLCA.posterior(obj, dat)
  error_post <- mean(apply(posterior_probs, 1, entropy), na.rm = TRUE)
  entropy_value <- 1 - (error_post / error_prior)
  if (!ratio) {
    entropy_value <- 1 - error_post
  }
  return(entropy_value)
}


entropy <- function(p) sum(-p * log(p))
