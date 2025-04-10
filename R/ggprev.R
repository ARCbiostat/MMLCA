#' Plot disease prevalences within MM patterns
#' @description The function plots the conditional disease prevalence, highlighting diseases with high O/E, Exclusivity or Entropy
#' @param obj
#' @param nclass
#' @param cutoff_OE
#' @param cutoff_Ex
#' @param cutoff_P
#'
#' @return
#' @export
#'
#' @examples
ggprev <- function(obj,nclass,cutoff_OE=2,cutoff_Ex=0.25,cutoff_P=NULL){



  nclass <- nrow(obj$probs[[1]])

  E <- apply(obj$y - 1, 2, mean)
  n <- list()
  for (j in 1:nclass) {
    n[[j]] <- rep(NA, ncol(obj$y))
    for (i in 1:ncol(obj$y)) {
      n[[j]][i] <- obj$probs[[i]][j, 2]
    }
  }

  O <- do.call("cbind",n)
  R <- O/E

  O %<>% as.data.frame() %>% rownames_to_column("Disease") %>% pivot_longer(2:(nclass+1),
                                                                            names_to = "Multimorbidity profile",
                                                                            values_to = "Prevalence") %>%
    mutate(`Multimorbidity profile`=as.numeric (gsub("\\D", "", `Multimorbidity profile`)))


  R %<>% as.data.frame() %>% rownames_to_column("Disease") %>% pivot_longer(2:(nclass+1),
                                                                            names_to = "Multimorbidity profile",
                                                                            values_to = "O/E") %>%
    mutate(`Multimorbidity profile`=as.numeric (gsub("\\D", "", `Multimorbidity profile`)))%>%
    mutate(label=ifelse(`O/E`<cutoff_OE,NA_integer_,Disease))


  ######## Exclusivity ########

  N <-apply(obj$y-1,2,sum)

  n <- list()
  for (j in 1:nclass){
    n[[j]] <- apply(obj$y[obj$predclass==j,]-1,2,sum)
  }

  Ex <- do.call("cbind",n)

  Ex <- Ex/N
  Ex %<>% as.data.frame() %>% rownames_to_column("Disease") %>% pivot_longer(2:(nclass+1),
                                                                             names_to = "Multimorbidity profile",
                                                                             values_to = "Exclusivity") %>%
    mutate(`Multimorbidity profile`=as.numeric (gsub("\\D", "", `Multimorbidity profile`)))%>%
    mutate(label2=ifelse(`Exclusivity`<cutoff_Ex,NA_integer_,Disease))


  Char_MP <- R %>% left_join(Ex) %>% left_join(O)
  Char_MP %<>% mutate(char=ifelse(!is.na(label) & !is.na(label2),1,NA_integer_))


  Char_MP %<>% mutate(`Multimorbidity profile`=as.factor(`Multimorbidity profile`)) %>%
    dplyr::select(`Multimorbidity profile`,Disease,Prevalence,Exclusivity,`O/E`,char) %>%
    mutate(Prevalence=Prevalence*100,
           Exclusivity=Exclusivity*100,
           Disease=gsub("_"," ",Disease),
           `O/E`=round(`O/E`,2)) %>%
    arrange(`Multimorbidity profile`,Disease) %>%
    mutate_at(3:4,round,0)

  Char_MP$`Multimorbidity profile` <- factor(as.factor(Char_MP$`Multimorbidity profile`),
                                             labels=c('Unspecific','Neuropsychiatric', 'Psychiatric\nRespiratory',"Sensory impairment\nAnemia","Cardiometabolic"),
                                             levels = c("3","1","2","4","5"))
  Char_MP$char <- replace_na(Char_MP$char ,0)
  gg <- ggplot(Char_MP)+
    geom_point(aes(1,Disease,size=Prevalence/10,color=as.factor(char),alpha=as.factor(char)))+
    scale_y_discrete("",limits=rev)+
    scale_x_continuous("",breaks = NULL)+
    facet_grid(~`Multimorbidity profile`)+
    theme_prism()+
    scale_color_manual(values = c("white","grey60"),guide=NULL)+
    scale_alpha_manual(values = c(0,1),guide=NULL)+
    scale_size_continuous("Prevalence (%)",
                          guide=guide_legend(override.aes=list(col="grey60")),
                          breaks = c(1,2.5,5,8),
                          labels = c(10,25,50,80))+
    theme(axis.ticks.x = element_blank(),
          legend.title =element_text(),
          legend.position = "bottom",
          panel.grid.major.y = element_line(color = "grey90",linetype="dashed",linewidth = 0.3),
          strip.text.x = element_text(size=13,angle = 90))


  print(gg)
  return(gg)
}

