#' Accuracy of LCA derived Multimorbidity Patterns
#'
#' @description This function derives and plot the accuracy of a LCA model for multimorbidity patterns using the misclassification probability and entropy on both the data used to fit the LCA and on a separate dataset.
#' @param obj fit object of class poLCA.
#' @param test Matrix with chronic diseases variables (coded as 1:no and 2:yes) used as a test set. It should be of the same format as the one used for fitting the LCA model.
#'
#' @return object of class ggplot.
#' @export
#'
#' @examples
ggaccuracy_LCA <- function(obj, test = NULL) {
  dat <- as.data.frame(obj$metrics)
  dat %<>% dplyr::mutate_at(2:ncol(dat), as.numeric)
  dat$prior <- unlist(lapply(1:nrow(dat), function(x) mean(obj$obj[[x]]$P)))
  gg_train <- ggplot2::ggplot(dat) +
    ggplot2::geom_line(aes(nclass, prior), linetype = "dashed", linewidth = 1) +
    ggplot2::geom_line(aes(nclass, `Assignment accuracy (%)`), linewidth = 1) +
    ggplot2::geom_point(aes(nclass, `Assignment accuracy (%)`)) +
    ggplot2::ggtitle("Train sample") +
    ggplot2::scale_y_continuous("Assignment accuracy (%)", limits = c(0, 1)) +
    ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.title = element_text(face = "bold", size = 14), axis.text = element_text(face = "bold", size = 12))

  ratio_train <- ggplot(dat) +
    ggplot2::geom_line(aes(nclass, `Assignment accuracy (%)` / prior), linewidth = 1) +
    ggplot2::geom_point(aes(nclass, `Assignment accuracy (%)` / prior)) +
    ggplot2::ggtitle("Train sample") +
    ggplot2::scale_y_continuous("Ratio assignment accuracy") +
    ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.title = element_text(face = "bold", size = 14), axis.text = element_text(face = "bold", size = 12))

  if (!is.null(test)) {
    dat$ext_accuracy <- unlist(lapply(1:nrow(dat), function(x) mean(diag(get_internal_validation_matrix(obj$obj[[x]], test)))))
    gg_test <- ggplot2::ggplot(dat) +
      ggplot2::geom_line(aes(nclass, prior), linetype = "dashed", linewidth = 1) +
      ggplot2::geom_line(aes(nclass, ext_accuracy, col = "Test"), linewidth = 1) +
      ggplot2::geom_point(aes(nclass, ext_accuracy, col = "Test")) +
      ggplot2::geom_line(aes(nclass, `Assignment accuracy (%)`, col = "Train"), linewidth = 1) +
      ggplot2::geom_point(aes(nclass, `Assignment accuracy (%)`, col = "Train")) +
      ggplot2::scale_y_continuous("Assignment accuracy (%)", limits = c(0, 1)) +
      ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
      ggplot2::theme_bw() +
      ggplot2::theme(axis.title = element_text(face = "bold", size = 14), axis.text = element_text(face = "bold", size = 12))


    ratio_test <- ggplot2::ggplot(dat) +
      ggplot2::geom_line(aes(nclass, ext_accuracy / prior, col = "Test"), linewidth = 1) +
      ggplot2::geom_point(aes(nclass, ext_accuracy / prior, col = "Test")) +
      ggplot2::geom_line(aes(nclass, `Assignment accuracy (%)` / prior, col = "Train"), linewidth = 1) +
      ggplot2::geom_point(aes(nclass, `Assignment accuracy (%)` / prior, col = "Train")) +
      ggplot2::scale_y_continuous("Ratio assignment accuracy") +
      ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
      ggplot2::theme_bw() +
      ggplot2::theme(axis.title = element_text(face = "bold", size = 14), axis.text = element_text(face = "bold", size = 12))
    gg <- ggpubr::ggarrange(gg_test, ratio_test, ncol = 2, common.legend = T)
  } else {
    gg <- ggpubr::ggarrange(gg_train, ratio_train, ncol = 2, common.legend = T)
  }
  print(gg)
  return(gg)
}
