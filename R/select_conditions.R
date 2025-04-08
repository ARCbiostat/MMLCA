#' Identify chronic conditions above threshold prevalence
#'
#' @param dat_dis Dataframe.
#' @param threshold Numeric prevalence threshold to use.
#' @param string String to identify chronic conditions in the dataset.
#' @import magrittr
#' @import dplyr
#' @import tidyr

#' @return A character vector.
#' @export
#'
#' @examples
#' dat <- data.frame(dis_1 = rbinom(prob = 0.1, size = 1, n = 100), dis_2 = rbinom(prob = 0.3, size = 1, n = 100), dis_3 = rbinom(prob = 0.05, size = 1, n = 100))
#' select_conditions(dat, 0.02, "dis_")
select_conditions <- function(dat_dis, threshold, string) {
  prev <-
    dat_dis %>%
    dplyr::select(contains(string)) %>%
    dplyr::summarise_all(function(x) {
      mean(x, na.rm = T)
    }) %>%
    t() %>%
    as.data.frame() %>%
    dplyr::rename(prev = V1) %>%
    dplyr::filter(prev >= threshold)

  select_cond <- row.names(prev)
  return(select_cond)
}
