#' Identify chronic conditions above threshold prevalence
#'
#' @param X Matrix with chronic diseases variables (coded as 1:no and 2:yes) to use for the calculation.
#' @param threshold Numeric prevalence threshold to use.
#' @import magrittr
#' @import dplyr
#' @import tidyr

#' @return A character vector.
#' @export
#'
#' @examples
#' X <- as.matrix(data.frame(dis_1 = rbinom(prob = 0.1, size = 1, n = 100)+1, dis_2 = rbinom(prob = 0.3, size = 1, n = 100)+1, dis_3 = rbinom(prob = 0.05, size = 1, n = 100)+1))
#' select_conditions(X, 0.02)
select_conditions <- function(X, threshold) {
  prev <-
    as.data.frame(X-1) %>%
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
