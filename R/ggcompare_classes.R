#' Compare class assignments across latent class solutions
#'
#' Generates an alluvial plot showing how subjects are classified across
#' latent class models with different numbers of classes. Class labels are
#' matched sequentially between adjacent solutions based on maximum overlap
#' in posterior classifications, providing a consistent labeling scheme
#' across models.
#'
#' For each fitted model, posterior class membership probabilities are
#' computed and converted to modal class assignments. The resulting classifications are displayed
#' as an alluvial diagram using \pkg{ggalluvial}.
#'
#' @param obj An object returned by function select_mmlca
#' @returns
#' A \code{ggplot2} object containing an alluvial plot that visualizes
#' transitions in class membership across solutions with different numbers
#' of latent classes.
#'
#' @export
#'
#' @examples
#' fit <- select_mmlca(
#'nclasses = 2:6,
#'X = X,
#'conditions = disease_names,
#'nrep = 20)
#' ggcompare_classes(fit)
#' }
ggcompare_classes <- function(obj){
  nclass <- as.numeric(as.data.frame(obj$metrics)$nclass)
  post <- lapply(obj$obj,function(x)poLCA::poLCA.posterior(x,y=obj$obj[[1]]$y))
  post_data <- lapply(post, function(x){
    x <- as.data.frame(x)
    y  <- data.frame(id = 1:nrow(x),
                     pred = apply(x, 1, which.max))
    return(y)
  })

  ## Initial labels for the first solution
  new_labels <- vector("list", length(post_data))
  new_labels[[1]] <- 1:max(post_data[[1]]$pred)
  labels <- 1:max(nclass)

  ## Relabel subsequent solutions
  for (m in 2:length(post_data)) {

    tab <- table(
      post_data[[m-1]]$pred,
      post_data[[m ]]$pred
    )

    tab <- as.matrix(tab)

    parent <- rep(NA, ncol(tab))
    used <- integer(0)

    for (j in order(apply(tab, 2, max), decreasing = TRUE)) {

      ord <- order(tab[, j], decreasing = TRUE)

        if (!ord[1] %in% used) {
          parent[j] <- ord[1]
          used <- c(used, ord[1])
        }
      }

    labels_prev <- labels[1:ncol(tab)]

    labels_new <- rep(NA,ncol(tab))



    for (j in seq_len(ncol(tab))) {

      if (!is.na(parent[j])) {
        labels_new[j] <- labels_prev[parent[j]]
      }
    }

    if(any(is.na(labels_new))){
      labels_new[is.na(labels_new)] <- setdiff(labels_prev,na.omit(labels_new))
    }

    ## Inherit the label from the parent class
    new_labels[[m]] <- labels_new
  ## Change values

    post_data[[m]]$pred <- new_labels[[m]][match(post_data[[m]]$pred, labels_prev)]
  }

  for (m in 1:length(post_data)){
    post_data[[m]]$pred <- as.factor(post_data[[m]]$pred)
  }
  ## We merge the classification of the models :
  dat_class <- merge(post_data[[1]][,c(1:2)], post_data[[2]][,c(1:2)], by="id")
  colnames(dat_class) <-c("id",paste(nclass[1:2],"classes"))
  for (c in 3:length(nclass)){
    dat_class <- merge(dat_class, post_data[[c]][,c(1:2)], by="id")
    colnames(dat_class)[c+1] <-paste(nclass[c],"classes")
  }

  axes <- colnames(dat_class)[-1]

  aes_dyn <- do.call(
    ggplot2::aes,
    c(
      setNames(lapply(axes, rlang::sym),
               paste0("axis", seq_along(axes))),
      list(
        fill = quote(ggplot2::after_stat(stratum)),
        label = quote(ggplot2::after_stat(stratum))
      )
    )
  )

  ## We plot the flows :
  gg <- ggplot2::ggplot(dat_class,
         aes_dyn) +
    ggplot2::scale_x_discrete(limits = axes) +
    ggalluvial::geom_flow() +
    ggalluvial::geom_stratum() +
    #ggalluvial::geom_text(stat = "stratum", size = 6) +
    ggplot2::theme_classic()+
    ggplot2::theme(legend.position = "null",
          axis.title = ggplot2::element_text(size = 18),
          axis.text = ggplot2::element_text(size = 16),
          legend.title = ggplot2::element_text(size = 16),
          legend.text = ggplot2::element_text(size = 14)) +
    ggplot2::labs(y = "Number of subjects",
         x = "Model",
         fill = "Class")

gg
}





