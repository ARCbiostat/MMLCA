#' Obtain Entropy plot and train and test data
#'
#' @param obj obtained from select_LCA
#' @param train train data
#' @param test test data
#' @param ratio should the ratio be calculated? Deafult to TRUE.
#'
#' @return ggplot2 object
#' @export
#'
#' @examples
ggentropy <- function(obj, train, test=NULL,ratio=T){
  dat <- as.data.frame(obj$metrics)
  dat %<>%mutate_at(2:ncol(dat),as.numeric)

  dat$entropy_train <- unlist(lapply(1:nrow(dat),function(x)get_entropy(obj$obj[[x]],train)))
  if(!ratio)dat$entropy_train <- unlist(lapply(1:nrow(dat),function(x)get_entropy(obj$obj[[x]],train,ratio=F)))

  gg <- ggplot(dat)+
    geom_line(aes(nclass,entropy_train),linewidth=1)+
    geom_point(aes(nclass,entropy_train))+
    geom_hline(aes(yintercept=0.6),linetype="dashed")+
    geom_hline(aes(yintercept=0.8),linetype="dashed")+
    scale_y_continuous("Entropy",limits = c(0,1))+
    scale_x_continuous("Number of latent classes",breaks = dat$nclass)+
    theme_bw()+
    theme(axis.title = element_text(face = "bold",size=14),axis.text = element_text(face = "bold",size=12))

  if(!is.null(test)){


    dat$entropy_test <- unlist(lapply(1:nrow(dat),function(x)get_entropy(obj$obj[[x]],test)))
    if(!ratio)dat$entropy_test <- unlist(lapply(1:nrow(dat),function(x)get_entropy(obj$obj[[x]],test,ratio=F)))

    gg <- ggplot(dat)+
      geom_line(aes(nclass,entropy_train,col="Train"),linewidth=1)+
      geom_point(aes(nclass,entropy_train,col="Train"))+
      geom_line(aes(nclass,entropy_test,col="Test"),linewidth=1)+
      geom_point(aes(nclass,entropy_test,col="Test"))+
      geom_hline(aes(yintercept=0.6),linetype="dashed")+
      geom_hline(aes(yintercept=0.8),linetype="dashed")+
      scale_y_continuous("Entropy",limits = c(0,1))+
      scale_x_continuous("Number of latent classes",breaks = dat$nclass)+
      theme_bw()+
      theme(axis.title = element_text(face = "bold",size=14),axis.text = element_text(face = "bold",size=12))




  }
  print(gg)
  return(gg)
}
