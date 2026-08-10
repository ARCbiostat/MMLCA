#' Function to run LCA with different number of classes/resamples and compare the goodness-of-fit
#' @description  This is a helper function to select the number of latent classes using poLCA. For  details regarding poLCA see the package documentation and https://statistics.ohlsen-web.de/latent-class-analysis-polca/.
#' @param nclasses Numeric vector indicating the number of latent classes to investigate.
#' @param X Matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param conditions Vector of columns names indicating the conditions to use for the LCA. It can be the object returned from the function select_conditions.
#' @param plot Boolean indicating whether the goodness-of-fit measures should be plotted.
#' @param nrep Number of times to estimate the model, using different values of probs.start. The default is one. Setting nrep>1 automates the search for the global—rather than just a local—maximum of the log-likelihood function. poLCA returns the parameter estimates corresponding to the model with the greatest log-likelihood. Default to 50. Reduce to save computation time.
#' @param nboot Number of re-samples, default to 10
#' @return A list containing the following elements:
#' \item{metrics}{A dataframe containing the goodness-of-fit measures for the different models.}
#' \item{obj}{A list of poLCA objects.}
#' \item{plot}{ggplot object for the plot if plot=T}
#' \item{accuracy_matrix}{A list of matrices containing the mislassification probabilities.}
#' \item{elapsed_time}{Numeric indicating the time elapsed.}
#' @export
#'
#' @examples
stability_mmlca <- function(nclasses, X, conditions, plot = T, nrep = 50, nboot = 10,seed=123) {
  tictoc::tic()

    future::plan(future::multisession)
    set.seed(seed)
    boot <- lapply(1:nboot,function(x)sample(1:nrow(X),nrow(X),replace = T))
    results <- future.apply::future_lapply(1:nboot, FUN = function(x)select_number_LCA(nclasses, X[boot[[x]],-1], conditions, nrep))
    #results <- do.call("rbind", lapply(1:nboot, FUN = function(x)select_number_LCA(nclasses, X[boot[[x]],-1], conditions, nrep)))
    metrics <-do.call(rbind,lapply(1:nboot,function(x){
      out <- results[[x]]$metrics%>%
        as.data.frame()
      out$nboot <- x
      return(out)}))

    if (plot) {
      dat_res_wide <- metrics %>%
        as.data.frame() %>%
        tidyr::pivot_longer(5:11, values_to = "metrics", names_to = "name") %>%
        dplyr::mutate(
          metrics = as.numeric(metrics),
          nclass = as.numeric(nclass)
        )
      dat_res_wide$nboot <- as.factor(dat_res_wide$nboot)
      gg <- ggplot2::ggplot(dat_res_wide) +
        ggplot2::geom_line(ggplot2::aes(nclass, metrics,group=nboot,color=nboot)) +
        ggplot2::geom_point(ggplot2::aes(nclass, metrics,group=nboot,color=nboot)) +
        ggplot2::facet_wrap(~name, scales = "free_y") +
        ggplot2::scale_y_continuous("") +
        ggplot2::scale_x_continuous("Number of latent classes", breaks = nclasses) +
        ggplot2::theme_bw()

      print(gg)
    } else {
      gg <- NULL
    }
    elapsed_time <- tictoc::toc(quiet = TRUE)$toc - tictoc::toc(quiet = TRUE)$tic
    return(list(plot = gg, results = results,elapsed_time=elapsed_time,metrics=metrics))
}
