#' Plot the Observed/Expected Ratios
#' @description The function calculates the Observed/Expected Ratios and plot it highlighting diseases above the threshold.
#' @param obj poLCA object
#' @param cutoff_OE Numeric indicating the cut-off for the Observed/Expected ratio
#' @param cutoff_P Numeric indicating the prevalence threshold for the Observed/Expected ratio to be calculated. If NULL, all diseases are considered.
#' @param table Boolean indicating whether the table of the O/E should be returned in addition to the plot.
#' @details The Observed/expected (O/E) ratios is calculated by dividing the prevalence of the condition within the pattern by its prevalence in the total sample.
#'
#' @return ggplot object. if table=T then a list of plot and data.frame is returned.
#' @export
#'
#' @examples

ggOE <- function(obj,cutoff_OE=2,cutoff_P=NULL,table=F){

  suppressMessages({
    suppressWarnings({
      nclass <-nrow(obj$probs[[1]])

      E <-apply(obj$y-1,2,mean)
      n <- list()
      for (j in 1:nclass){
        n[[j]] <- rep(NA,ncol(obj$y))
        for ( i in 1:ncol(obj$y)){

          n[[j]][i] <- obj$probs[[i]][j,2]
        }
      }

      O <- do.call("cbind",n)
      rownames(O) <-colnames(obj$y)
      R <- O/E

      if(is.null(cutoff_P)) cutoff_P <- 0
      O %<>% as.data.frame() %>% tibble::rownames_to_column("Disease") %>% tidyr::pivot_longer(2:(nclass+1),
                                                                                               names_to = "Multimorbidity profile",
                                                                                               values_to = "Prevalence") %>%
        dplyr::mutate(`Multimorbidity profile`=as.numeric (gsub("\\D", "", `Multimorbidity profile`))) %>%
        dplyr::mutate(label2=ifelse(Prevalence<cutoff_P,NA_integer_,Disease))


      R %<>% as.data.frame() %>% tibble::rownames_to_column("Disease") %>% tidyr::pivot_longer(2:(nclass+1),
                                                                                               names_to = "Multimorbidity profile",
                                                                                               values_to = "O/E") %>%
        dplyr::mutate(`Multimorbidity profile`=as.numeric (gsub("\\D", "", `Multimorbidity profile`)))%>%
        dplyr::mutate(label=ifelse(`O/E`<cutoff_OE,NA_integer_,Disease))

      Char_MP <- R %>% dplyr::left_join(O)

      Char_MP%<>% dplyr::mutate(char=ifelse(!is.na(label) & !is.na(label2),1,NA_integer_))


      datn <- data.frame(`Multimorbidity profile`=1:nclass,
                         N=as.numeric(table(obj$predclass)),
                         P=round(as.numeric(table(obj$predclass))/length(obj$predclass)*100,0))

      colnames(datn)[1] <- "Multimorbidity profile"
      Char_MP %<>% dplyr::left_join(datn) %>% dplyr::mutate(`Multimorbidity profile`=paste0(`Multimorbidity profile`," (",P,"%)")) %>%
        dplyr::mutate(label3=ifelse(!is.na(label) & !is.na(label2),Disease,NA_integer_))

      ggOE <- ggplot2::ggplot(Char_MP)+
        ggplot2::geom_text(aes(`O/E`,Disease,label=label3,hjust="left"),size=6)+
        ggplot2::geom_bar(aes(`O/E`,Disease,fill=Disease),stat = "identity")+
        ggplot2::geom_vline(aes(xintercept=cutoff_OE),linetype="dashed")+
        ggplot2::facet_grid(.~`Multimorbidity profile`)+
        ggplot2::scale_y_discrete("Chronic conditions")+
        ggprism::theme_prism(base_size = 16)+
        ggplot2::theme(legend.position = "null",
                       axis.text.y =ggplot2::element_text( hjust = 1),
                       strip.text.x.top =ggplot2::element_text(size=16),
                       axis.ticks.y = ggplot2::element_blank(),
                       panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5))+
        ggplot2::ggtitle("Multimorbidity Patterns")


      print(ggOE)
    })


  })


  if(table){
    colnames(Char_MP)[4] <- "O/E above threshold"
    colnames(Char_MP)[6] <- "Prevalence above threshold"
    colnames(Char_MP)[7] <- "Flag for prevalence and O/E above threshold"
    colnames(Char_MP)[10] <- "Prevalence and O/E above threshold"

    return(list(plot=ggOE,table=Char_MP))
  }else return(ggOE)
}
