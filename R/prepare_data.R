#' Prepare the chronic disease dataset for the LCA
#' @description The function help you prepare the dataset as needed for the LCA. Only variables containing chronic diseases are retained and 0/1 are substituted by 1/2 as needed by the poLCA package. In addition, the number of chronic condition for each individual is checked and optionally individuals with only one chronic conditions are removed since they should to be used to identify MM patterns.
#'
#' @param data dataframe.
#' @param dis_string string to identify chronic disease columns.
#' @param keepmm boolean indicating whether subjects having less that 2 chronic conditions should be removed from the returned dataset.
#'
#' @return data.frame.
#' @export
#'
#' @examples
#' data(mmdata)
#' X <- prepare_data(mmdata, "dis", keepmm = TRUE)
prepare_data <- function(data, dis_string, keepmm = TRUE) {
  X <- data %>% dplyr::select(dplyr::contains(dis_string))
  lev <- unique(unlist(lapply(1:ncol(X), function(y) unique(X[, y]))))
  if (NA %in% lev) stop("Disease columns cannot contain missing values.")
  if (!all(lev %in% c(0, 1)) | any(sapply(lev, is.character))) stop("Disease columns must be numeric 0/1 variables.")
  X %<>% dplyr::mutate_all(function(x) x + 1)
  ndis <- apply(X - 1, 1, sum)
  nomm <- sum(ndis < 2)
  if (keepmm) {
    if (nomm > 0) {
      X <- X[-which(ndis < 2), ]
      message(paste(nomm, "rows are removed because corrisponding to subjects having less than 2 chornic conditions."))
      message(paste("rows removed:", which(ndis < 2)))
    } else {
      message("All subjects have at least 2 chronic conditions.")
    }
  } else {
    if (nomm > 0) {
      warning(paste(nomm, "subject have less than two chronic conditions. These should be not used for the LCA!"))
    }
  }
  return(X)
}
