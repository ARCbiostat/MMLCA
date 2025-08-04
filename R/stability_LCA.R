#' Assess stability of LCA latent class model using non-parametric bootstrap
#'
#' @param nclass Numeric indicating the number of latent classes.
#' @param X Matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param conditions Vector of columns names indicating the conditions to use for the LCA. It can be the object returned from the function select_conditions.
#' @param nrep Number of times to estimate the model, using different values of probs.start. The default is one. Setting nrep>1 automates the search for the global—rather than just a local—maximum of the log-likelihood function. poLCA returns the parameter estimates corresponding to the model with the greatest log-likelihood. Default to 50. Reduce to save computation time.
#' @param fcov Covariates used as predictors.
#' @param probstart A list of matrices of class-conditional response probabilities to be used as the starting values for the estimation algorithm. Each matrix in the list corresponds to one manifest variable, with one row for each latent class, and one column for each outcome. The default is NULL, producing random starting values. Note that if nrep>1, then any user-specified probs.start values are only used in the first of the nrep attempts. Deafult to NULL.
#' @param nboot Number of bootstrap samples
#'
#' @return
#' @export
#'
#' @examples
stability_LCA <- function(nclass, X, conditions, nrep = 50, fcov = NULL, probstart = NULL, nboot) {

}
