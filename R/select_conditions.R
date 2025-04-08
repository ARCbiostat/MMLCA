# return conditions that satisfy threshold

select_conditions <- function(dat_dis,threshold, string){
  require(tidyverse)
  require(magrittr)
  prev <-
    dat_dis %>% dplyr::select(contains(string),-dis_date) %>%summarise_all( function(x)
      mean(x,na.rm = T)) %>%
    t() %>%
    as.data.frame() %>%
    rename(prev = V1) %>%
    filter(prev>=threshold)

  select_cond <- row.names(prev)
  return(select_cond)
}
