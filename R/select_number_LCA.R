#' Function to run LCA with different number of classes and compare the goodness-of-fit
#' @description  This is a helper function to select the number of latent classes using poLCA. For  details regarding poLCA see the package documentation and https://statistics.ohlsen-web.de/latent-class-analysis-polca/.
#' @param nclasses Numeric vector indicating the number of latent classes to investigate.
#' @param X Matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param conditions Vector of columns names indicating the conditions to use for the LCA. It can be the object returned from the function select_conditions.
#' @param plot Boolean indicating whether the goodness-of-fit measures should be plotted.
#' @param nrep Number of times to estimate the model, using different values of probs.start. The default is one. Setting nrep>1 automates the search for the global—rather than just a local—maximum of the log-likelihood function. poLCA returns the parameter estimates corresponding to the model with the greatest log-likelihood. Default to 50. Reduce to save computation time.
#'
#' @return A list containing the following elements:
#' \item{metrics}{A dataframe containing the goodness-of-fit measures for the different models.}
#' \item{obj}{A list of poLCA objects.}
#' \item{plot}{ggplot object for the plot if plot=T}
#' \item{accuracy_matrix}{A list of matrices containing the mislassification probabilities.}
#' \item{elapsed_time}{Numeric indicating the time elapsed.}
#' @export
#'
#' @examples
select_number_LCA <- function(nclasses, X, conditions, plot = T, nrep = 50) {
  tictoc::tic()
  res <- lapply(nclasses, function(x) run_LCA(x, X = X, conditions = conditions, nrep = nrep))
  dat_res <- do.call("rbind", lapply(res, function(x) x$metrics))
  objects <- lapply(res, function(x) x$obj)
  names(objects) <- nclasses
  internal_val <- lapply(res, function(x) x$accuracy_matrix)
  names(internal_val) <- nclasses
  colnames(dat_res) <- c(
    "Model",
    "nclass",
    "log_likelihood",
    "df",
    "BIC",
    "AIC",
    "CAIC",
    "ABIC",
    "likelihood_ratio",
    "Assignment accuracy (%)",
    "Entropy"
  )

  if (plot) {
    dat_res_wide <- dat_res %>%
      as.data.frame() %>%
      tidyr::pivot_longer(5:11, values_to = "metrics", names_to = "name") %>%
      dplyr::mutate(
        metrics = as.numeric(metrics),
        nclass = as.numeric(nclass)
      )



    gg <- ggplot2::ggplot(dat_res_wide) +
      ggplot2::geom_line(ggplot2::aes(nclass, metrics)) +
      ggplot2::geom_point(ggplot2::aes(nclass, metrics)) +
      ggplot2::facet_wrap(~name, scales = "free_y") +
      ggplot2::scale_y_continuous("") +
      ggplot2::scale_x_continuous("Number of latent classes", breaks = nclasses) +
      ggplot2::theme_bw()

    print(gg)
  } else {
    gg <- NULL
  }
  elapsed_time <- tictoc::toc(quiet = TRUE)$toc - tictoc::toc(quiet = TRUE)$tic
  return(list(metrics = dat_res, obj = objects, plot = gg, accuracy_matrix = internal_val, elapsed_time = elapsed_time))
}
