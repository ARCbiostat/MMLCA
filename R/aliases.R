# ==========================================================
# Aliases for a cleaner MMLCA interface
# ==========================================================

# ----------------------------------------------------------
# Estimation and model selection
# ----------------------------------------------------------

#' @rdname run_LCA
#' @export
fit_mmlca <- function(...) {
  run_LCA(...)
}

#' @rdname select_number_LCA
#' @export
select_mmlca <- function(...) {
  select_number_LCA(...)
}

# ----------------------------------------------------------
# Diagnostics
# ----------------------------------------------------------

#' @rdname ggaccuracy_LCA
#' @export
ggaccuracy <- function(...) {
  ggaccuracy_LCA(...)
}

# ----------------------------------------------------------
# Pattern interpretation
# ----------------------------------------------------------

#' @rdname ggOExDyn
#' @export
ggOEx_adaptive <- function(...) {
  ggOExDyn(...)
}

#' @rdname ggprev
#' @export
ggprevalence <- function(...) {
  ggprev(...)
}

#' @rdname ggprev_spaghetti
#' @export
ggprevalence_spaghetti <- function(...) {
  ggprev_spaghetti(...)
}

# ----------------------------------------------------------
# Class assignment and downstream analyses
# ----------------------------------------------------------

#' @rdname assign_LCA
#' @export
assign_mmlca <- function(...) {
  assign_LCA(...)
}

#' @rdname multiple_imputation
#' @export
impute_mmlca <- function(...) {
  multiple_imputation(...)
}
