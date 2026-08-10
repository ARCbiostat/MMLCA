#' Accuracy of LCA derived Multimorbidity Patterns
#'
#' @description This function compares and plot the accuracy of LCA models with different number of classes for multimorbidity patterns using the misclassification probability and entropy. The dashed line corresponds to the assignment accuracy based on the prior.
#' @param obj object returned by the function select_number_LCA.
#'
#' @return object of class ggplot.
#' @export
#'
#' @examples
ggaccuracy_LCA <- function(obj) {
  dat <- as.data.frame(obj$metrics)
  dat %<>% dplyr::mutate_at(2:ncol(dat), as.numeric)
  dat$prior <- unlist(lapply(1:nrow(dat), function(x) mean(obj$obj[[x]]$P)))
  gg_train <- ggplot2::ggplot(dat) +
    ggplot2::geom_line(ggplot2::aes(nclass, prior), linetype = "dashed", linewidth = 1) +
    ggplot2::geom_line(ggplot2::aes(nclass, `Assignment accuracy (%)`), linewidth = 1) +
    ggplot2::geom_point(ggplot2::aes(nclass, `Assignment accuracy (%)`)) +
    ggplot2::ggtitle("Train sample") +
    ggplot2::scale_y_continuous("Assignment accuracy (%)", limits = c(0, 1)) +
    ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.title = ggplot2::element_text(face = "bold", size = 14), axis.text = ggplot2::element_text(face = "bold", size = 12))

  ratio_train <- ggplot2::ggplot(dat) +
    ggplot2::geom_line(ggplot2::aes(nclass, `Assignment accuracy (%)` / prior), linewidth = 1) +
    ggplot2::geom_point(ggplot2::aes(nclass, `Assignment accuracy (%)` / prior)) +
    ggplot2::ggtitle("Train sample") +
    ggplot2::scale_y_continuous("Ratio assignment accuracy") +
    ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.title = ggplot2::element_text(face = "bold", size = 14), axis.text = ggplot2::element_text(face = "bold", size = 12))

  gg <- ggpubr::ggarrange(gg_train, ratio_train, ncol = 2, common.legend = F)
  print(gg)
  return(gg)
}
