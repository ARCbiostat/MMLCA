#' Function to calculate the approximate misclassifications matrix
#'
#' @param fit object of class poLCA.
#' @param X matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#'
#' @details This function calculates the misclassification probabilities as in https://www.stata.com/meeting/uk22/slides/UK22_Tompsett.pdf
#' @return nc x nc matrix where nc is the number of latent multimorbidity patterns containing the probabilities of being assigned to a class given the true class.
#' @export
#'
#' @examples
get_internal_validation_matrix <- function(fit, X) {
  pClY <- poLCA::poLCA.posterior(fit, y = X)
  ng <- ncol(pClY)
  pred <- as.numeric(apply(pClY, 1, function(x) which.max(x))) # MODE



  Ptable <- cbind(pClY, pred)
  Pmatrix <- matrix(0, ng, ng)
  Npmatrix <- matrix(0, ng, ng)
  modclass <- pred


  for (i in 1:ng) {
    for (j in 1:ng) {
      Pmatrix[i, j] <- sum(subset(Ptable, modclass == i)[, j]) / table(modclass)[i]
      Npmatrix[i, j] <- Pmatrix[i, j] * table(modclass)[i]
    }
  }


  denom <- colSums(Npmatrix)
  Qmatrix <- matrix(0, ng, ng)


  for (i in 1:ng) {
    for (j in 1:ng) {
      Qmatrix[j, i] <- Npmatrix[i, j] / denom[j]
    }
  }

  Qmatrix
}
