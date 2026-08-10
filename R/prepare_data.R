#' Prepare the chronic disease dataset for the LCA
#' @description The function help you prepare the dataset as needed for the LCA. Only variables containing chronic diseases are retained and 0/1 are substituted by 1/2 as needed by the poLCA package. In addition, the number of chronic condition for each individual is checked and optionally individuals with only one chronic conditions are removed since they should to be used to identify MM patterns.
#'
#' @param data dataframe.
#' @param dis_cols string to identify chronic disease columns or numeric vector of chronic disease columns position .
#' @param keepmm boolean indicating whether subjects having less that 2 chronic conditions should be removed from the returned dataset.
#' @param idvar  string indicating name of id variable
#' @return data.frame.
#' @export
#'
#' @examples
#' data(mmdata)
#' X <- prepare_data(mmdata, "dis", keepmm = TRUE)
prepare_data <- function(data, dis_cols, keepmm = TRUE,idvar="id") {
  if(is.character(dis_cols)){
    X <- data %>% dplyr::select(dplyr::contains(dis_cols))
  }

  if(is.numeric(dis_cols)){
    X <- data %>% dplyr::select(dis_cols)
  }

  id <- data[idvar]
  if(nrow(id)!=nrow(data)) stop("idvar not found")

  lev <- unique(unlist(lapply(1:ncol(X), function(y) unique(X[, y]))))
  if (NA %in% lev) stop("Disease columns cannot contain missing values.")
  if (!all(X %% 1 == 0) | any(sapply(lev, is.character))) stop("Disease columns must be numeric variables containing integers.")
  if(!all(min(lev)==0)) warning("Some disease columns don't have 0 as the lowest level as expected.")
  nvar <- ncol(X)
  message(paste("Number of disease columns detected:", nvar))

  X %<>% dplyr::mutate_all(function(x) x + 1)
  ndis <- apply(X - 1, 1, function(x)sum(ifelse(x!=0,1,0)))
  nomm <- sum(ndis < 2)
  if (keepmm) {
    if (nomm > 0) {
      X <- X[-which(ndis < 2), ]
      id <- id[-which(ndis < 2),]
      message(paste(nomm, "rows are removed because corrisponding to subjects having less than 2 diseases."))
      #message(paste("rows removed:", which(ndis < 2)))
    } else {
      message("All subjects have at least 2 diseases.")
    }
  } else {
    if (nomm > 0) {
      warning(paste(nomm, "subject have less than two diseases."))
    }
  }
  return(cbind(id,X))
}
