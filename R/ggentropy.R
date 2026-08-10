#' Obtain Entropy plot and train and test data
#'
#' @param obj obtained from select_LCA
#' @param X data
#' @param ratio should the ratio be calculated? Deafult to TRUE.
#'
#' @return ggplot2 object
#' @export
#'
#' @examples
ggentropy <- function(obj, X, ratio = T) {
  dat <- as.data.frame(obj$metrics)
  dat %<>% mutate_at(2:ncol(dat), as.numeric)

  dat$entropy_train <- unlist(lapply(1:nrow(dat), function(x) get_entropy(obj$obj[[x]], X)))
  if (!ratio) dat$entropy_train <- unlist(lapply(1:nrow(dat), function(x) get_entropy(obj$obj[[x]], X, ratio = F)))

  gg <- ggplot2::ggplot(dat) +
    ggplot2::geom_line(ggplot2::aes(nclass, entropy_train), linewidth = 1) +
    ggplot2::geom_point(ggplot2::aes(nclass, entropy_train)) +
    ggplot2::geom_hline(ggplot2::aes(yintercept = 0.6), linetype = "dashed") +
    ggplot2::geom_hline(ggplot2::aes(yintercept = 0.8), linetype = "dashed") +
    ggplot2::scale_y_continuous("Entropy", limits = c(0, 1)) +
    ggplot2::scale_x_continuous("Number of latent classes", breaks = dat$nclass) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.title = ggplot2::element_text(face = "bold", size = 14), axis.text = ggplot2::element_text(face = "bold", size = 12))


  print(gg)
  return(gg)
}
