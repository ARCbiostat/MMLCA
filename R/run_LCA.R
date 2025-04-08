#' Main function to run the LCA
#'
#' @param nclass Numeric indicating the number of latent classes.
#' @param X Matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param conditions Vector of columns names indicating the conditions to use for the LCA. It can be the object returned from the function select_conditions.
#' @param nrep Number of times to estimate the model, using different values of probs.start. The default is one. Setting nrep>1 automates the search for the global—rather than just a local—maximum of the log-likelihood function. poLCA returns the parameter estimates corresponding to the model with the greatest log-likelihood. Default to 50. Reduce to save computation time.
#' @param fcov Covariates used as predictors.
#' @param probstart A list of matrices of class-conditional response probabilities to be used as the starting values for the estimation algorithm. Each matrix in the list corresponds to one manifest variable, with one row for each latent class, and one column for each outcome. The default is NULL, producing random starting values. Note that if nrep>1, then any user-specified probs.start values are only used in the first of the nrep attempts. Deafult to NULL.
#'
#' @return A list containing the following elements:
#' \item{obj}{An object of class 'poLCA' representing the fitted LCA model.}
#' \item{accuracy_matrix}{A matrix containing the mislassification probabilities.}
#' \item{metrics}{A vector containing goodness-of-fit measures.}
#' @export
#'
#' @examples
run_LCA <- function(nclass, X, conditions, nrep = 50, fcov = NULL, probstart = NULL) {
  gc()
  f <- dat_long %>%
    dplyr::select(any_of(conditions)) %>%
    as.matrix()
  if (!is.null(fcov)) {
    formula <- as.formula(paste0("f~", fcov))
  } else {
    formula <- as.formula(paste0("f~1"))
  }

  if (is.null(probstart)) {
    myresult <- poLCA::poLCA(formula,
      dat_long,
      nclass = nclass,
      maxiter = 3000,
      na.rm = F,
      nrep = nrep,
      verbose = T
    )
  } else {
    myresult <- poLCA::poLCA(formula,
      dat_long,
      nclass = nclass,
      maxiter = 3000,
      na.rm = F,
      probs.start = probstart,
      verbose = T
    )
  }

  print(paste("Completed LCA with", nclass, "..."))

  Modell <- paste("Model", nclass)
  log_likelihood <- myresult$llik
  df <- myresult$resid.df
  BIC <- myresult$bic
  AIC <- myresult$aic
  ABIC <- (-2 * myresult$llik) + ((log((myresult$N + 2) / 24)) * myresult$npar)
  CAIC <- (-2 * myresult$llik) + myresult$npar * (1 + log(myresult$N))
  likelihood_ratio <- myresult$Gsq
  internal_val_matrix <- get_internal_validation_matrix(myresult, dat_long)
  acc <- sum(diag(internal_val_matrix)) / nclass
  entropy <- get_entropy(myresult, dat_long)
  return(list(
    obj = myresult,
    accuracy_matrix = internal_val_matrix,
    metrics = c(Modell,
      nclass,
      log_likelihood,
      df,
      BIC,
      AIC,
      CAIC,
      ABIC,
      likelihood_ratio,
      acc = acc,
      entropy = entropy
    )
  ))
}
