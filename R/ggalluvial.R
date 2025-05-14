
#' Describe mm patterns longitudinally through an alluvial plot
#'
#' @param data dataset to use.
#' @param time_var string containing the name of the time variable.
#' @param id_var string containing the name of the id variable.
#' @param mm_var string containing the name of the multimorbidity patterns variable.
#' @param colors colors to use (one for each mm pattern and death, loss-to follow-up)
#' @param space numeric indicating the spacing between nodes
#'
#' @return ggplot object and data
#' @export
#'
#' @examples
ggalluvial <- function(data,time_var="time",id_var,mm_var,colors,space=0){

  expanded_dat <- tidyr::expand_grid(id=unique(data[[id_var]]),
                       time=unique(round(data[[time_var]])))

colnames(expanded_dat)[1] <- id_var
  n<- length(unique(data[[mm_var]]))


   dat_alluvial <- data %>%
    dplyr::select(.data[[id_var]],.data[[time_var]],.data[[mm_var]]) %>%
     dplyr::mutate(time=round(.data[[time_var]]))%>%
     dplyr::full_join(expanded_dat)%>%
     dplyr::arrange(.data[[id_var]],time)%>%
     dplyr::group_by(.data[[id_var]]) %>%
     dplyr::mutate(min_time=round(min(.data[[time_var]],na.rm = T)),
           max_time=round(max(.data[[time_var]],na.rm = T))) %>%
   dplyr::filter(time>=min_time)%>%
     tidyr::fill(.data[[mm_var]], .direction = "down") %>%
     dplyr::mutate(mm_pattern=.data[[mm_var]]) %>%
   dplyr::mutate(mm_pattern=ifelse(time>max_time & mm_pattern!=n, NA_integer_, mm_pattern),
           next_time = lead(time),
           next_mm_pattern = lead(mm_pattern)) %>%
     dplyr::ungroup() %>%
    tidyr::drop_na(mm_pattern)


   duplicated <- dat_alluvial %>%
     group_by(.data[[id_var]],time,next_time) %>%
     distinct(.data[[id_var]],time,next_time,.data[[mm_var]]) %>%
     nrow()

   message(paste("There are",duplicated,"overlapping transitions!"))

  ggalluvial <- ggplot2::ggplot(dat_alluvial, aes(x = time,
                                       next_x = next_time,
                                       node = mm_pattern,
                                       next_node = next_mm_pattern,
                                       fill = factor(mm_pattern),
                                       label=mm_pattern,
                                       node.fill=mm_pattern)) +
    ggsankey::geom_sankey(flow.alpha=0.8,node.col=1,space=space) +
    ggplot2::scale_fill_manual("",values=colors) +
    ggsankey::theme_sankey(base_size = 30)+
    ggplot2::scale_x_continuous(time_var)+
    ggplot2::theme(legend.position = "bottom",legend.text = element_text(size=17,face = "bold"),
          axis.line = element_line(linewidth = 1,linetype = "solid",color="black",arrow = arrow(type = "closed",ends = "last",length = unit(0.1,"inches"))),
          line = element_line(),
          panel.background = element_blank(),
          axis.ticks.x = element_blank())

  print(ggalluvial)
 return(list(plot=ggalluvial,data=dat_alluvial))

}
