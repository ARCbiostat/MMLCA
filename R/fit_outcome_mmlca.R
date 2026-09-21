
#' Regression model with multimorbidity pattern as covariate taking into account of class-uncertainty
#'
#' @param object poLCA object
#' @param formula Two-sided model formula specifying the outcome and covariates.
#' @param data Data frame containing the variables used in the model.
#' @param model Outcome model. Either `"glm"` for generalized linear models  `"coxph"` for Cox proportional hazards models.
#' @param family Family object passed to `glm()` when `model = "glm"`. Defaults to `gaussian()`.
#' @param method Method used to account for latent class uncertainty. Either `"pmi"` (posterior multiple imputation) or `"weighted"`
#' @param M Number of imputations when `method = "pmi"`.
#' @param class_var String containing name of the variable of multimorbidity pattern assignments. Defaults to `"mm_pattern"`.
#' @param ref_class Reference pattern used in regression models. Defaults to `"1"`.
#' @param conf.level Confidence level for confidence intervals. Defaults to `0.95`.
#' @param exponentiate Logical. If `TRUE`, exponentiates model coefficients and confidence intervals (e.g. odds ratios or hazard ratios).
#' @param seed Optional random seed for reproducibility.
#' @param boot Logical. If `TRUE`, confidence intervals are obtained using bootstrap resampling to take into account of uncertainty from LCA model.
#' @param nboot Number of bootstrap samples.
#' @param nrep Number of random starting values for bootstrap LCA runs, if applicable.
#'
#' @returns
#' @export
#'
fit_outcome_mmlca <- function(
    object,
    formula,
    data,
    model = c("glm","coxph"),
    family = gaussian(),
    method = c("pmi","weighted"),
    M = 50,
    class_var = "mm_pattern",
    ref_class="1",
    conf.level= 0.95,
    exponentiate=F,
    seed = NULL,
    boot=F,
    nboot=NULL,
    nrep=NULL
){

  model <- match.arg(model)
  method <- match.arg(method)
if(!method%in%c("pmi","weighted"))stop("invalid method selected")
  if(!is.null(seed))
    set.seed(seed)

  post <- object$posterior

  if(is.null(post))
    stop("object$posterior not found.")

  K <- ncol(post)

  if(boot){
    if(is.null(nboot)) stop("Number of bootstrap replicates need to be specified")
    if(is.null(nrep)) stop("Number of random initial starting values need to be specified")

    #========================================================
    # WEIGHTED APPROACH
    #========================================================

    if(method == "weighted"){

      long_dat <- do.call(
        rbind,
        lapply(seq_len(K), function(k){

          tmp <- data

          tmp[[class_var]] <- factor(
            k,
            levels = seq_len(K)
          )
          tmp[[class_var]] <- relevel(
            tmp[[class_var]],
            ref = ref_class
          )
          tmp$.weight <- pmax(post[,k],0.001)
          tmp$id <- paste0(1:nrow(tmp),k)

          tmp
        })
      )

      if(model == "glm"){

        fit <- glm(
          formula,
          data = long_dat,
          family = family,
          weights = .weight
        )

      } else if(model == "coxph"){

        fit <- survival::coxph(
          formula,
          data = long_dat,
          weights = .weight,
          cluster = id
        )

      }else{
        stop("Other regression methods not yet implemented")
      }


      est <- fit$coefficients
      beta_boot <- matrix(NA,nrow=nboot,ncol=length(fit$coefficients))


    }

    if(method=="pmi"){
      #========================================================
      # PMI
      #========================================================

      fits <- vector("list", M)

      coef_list <- vector("list", M)
      var_list <- vector("list", M)

      data_imp <- impute_mmlca(object,nimp=M)

      for(m in seq_len(M)){

        dat_m <- data


        cls <- data_imp[[m]]$mm_pattern

        dat_m[[class_var]] <-
          factor(
            cls,
            levels = seq_len(K)
          )

        dat_m[[class_var]] <- relevel(
          dat_m[[class_var]],
          ref = ref_class
        )

        fit_m <- .fit_model(
          formula = formula,
          data = dat_m,
          model = model,
          family = family
        )

        fits[[m]] <- fit_m

        coef_list[[m]] <- stats::coef(fit_m)

        var_list[[m]] <- diag(stats::vcov(fit_m))
      }

      coef_mat <- do.call(
        rbind,
        coef_list
      )

      var_mat <- do.call(
        rbind,
        var_list
      )

      pooled <- .pool_rubin(
        coef_mat,
        var_mat
      )
      est <- pooled$estimates
      beta_boot <- matrix(NA,nrow=nboot,ncol=length(pooled$estimates))

    }

    theta_ref <-  sapply(object$obj$probs, function(x) x[, 2])
    for(b in 1:nboot){

      # bootstrap subjects

      ind <- sample(
        seq_len(nrow(object$y)),
        replace = TRUE
      )

      boot_X <- object$y[ind, ]
      boot_data <- data[ind, ]

      # refit LCA

      lca_b <- run_LCA(K, X = boot_X, conditions = colnames(boot_data), nrep = nrep)
      theta_boot  <- sapply(lca_b$obj$probs, function(x) x[, 2])
      S <- as.matrix(
      proxy::simil( theta_boot,theta_ref, method = "cosine"))
      match <- clue::solve_LSAP(S, maximum = TRUE)

      post <- lca_b$obj$posterior[, match, drop = FALSE]

      if(method=="pmi"){

        fits <- vector("list", M)

        coef_list <- vector("list", M)
        var_list <- vector("list", M)

        data_imp <- impute_mmlca(lca_b,nimp=M)

        for(m in seq_len(M)){

          dat_m <- boot_data


          cls <- data_imp[[m]]$mm_pattern
          inv_match <- integer(length(match))
          inv_match[match] <- seq_along(match)
          data_imp[[m]]$mm_pattern <-
            inv_match[data_imp[[m]]$mm_pattern]

          dat_m[[class_var]] <-
            factor(
              cls,
              levels = seq_len(K)
            )

          dat_m[[class_var]] <- relevel(
            dat_m[[class_var]],
            ref = ref_class
          )

          fit_m <- .fit_model(
            formula = formula,
            data = dat_m,
            model = model,
            family = family
          )

          fits[[m]] <- fit_m

          coef_list[[m]] <- stats::coef(fit_m)

          var_list[[m]] <- diag(stats::vcov(fit_m))
        }

        coef_mat <- do.call(
          rbind,
          coef_list
        )

        var_mat <- do.call(
          rbind,
          var_list
        )

        pooled <- .pool_rubin(
          coef_mat,
          var_mat
        )

        beta_boot[b, ] <- pooled$estimate
      }

      if(method=="weighted"){
        long_dat <- do.call(
          rbind,
          lapply(seq_len(K), function(k){

            tmp <- boot_data

            tmp[[class_var]] <- factor(
              k,
              levels = seq_len(K)
            )

            tmp[[class_var]] <- relevel(
              tmp[[class_var]],
              ref = ref_class
            )

            tmp$.weight <- pmax(post[,k],0.001)

            tmp
          })
        )

        if(model == "glm"){

          fit_b <- glm(
            formula,
            data = long_dat,
            family = family,
            weights = .weight
          )



        } else if(model == "coxph") {

          fit_b <- survival::coxph(
            formula,
            data = long_dat,
            weights = .weight
          )
        }else{
          stop("Other regression models not yet implemented")
        }

        beta_boot[b, ] <- fit_b$coefficients
      }

    }

      pooled <- .bootstrap_summary(beta_boot=beta_boot,
                                   est=est,
                                   exponentiate=exponentiate,
                                   conf.level = conf.level )

      structure(
        list(
          method = "boot",
          model = beta_boot,
          pooled = pooled,
          fits = NULL,
          call = match.call()
        ),
        class = "mmlca_outcome"
      )

  }else{
    #========================================================
    # WEIGHTED APPROACH
    #========================================================

    if(method == "weighted"){

      long_dat <- do.call(
        rbind,
        lapply(seq_len(K), function(k){

          tmp <- data

          tmp[[class_var]] <- factor(
            k,
            levels = seq_len(K)
          )

          tmp[[class_var]] <- relevel(
            tmp[[class_var]],
            ref = ref_class
          )

          tmp$.weight <- pmax(post[,k],0.001)
          tmp$id <- paste0(1:nrow(tmp),k)

          tmp
        })
      )

      if(model == "glm"){

        fit <- glm(
          formula,
          data = long_dat,
          family = family,
          weights = .weight
        )

      } else if(model == "coxph") {

        fit <- survival::coxph(
          formula,
          data = long_dat,
          weights = .weight,
          cluster = id
        )

      }else{
        stop("Other regression models not yet implemented")
      }

      return(
        fit

      )
    }

    #========================================================
    # PMI
    #========================================================

    fits <- vector("list", M)

    coef_list <- vector("list", M)
    var_list <- vector("list", M)

    data_imp <- impute_mmlca(object,nimp=M)

    for(m in seq_len(M)){

      dat_m <- data


      cls <- data_imp[[m]]$mm_pattern

      dat_m[[class_var]] <-
        factor(
          cls,
          levels = seq_len(K)
        )

      dat_m[[class_var]] <- relevel(
        dat_m[[class_var]],
        ref = ref_class
      )

      fit_m <- .fit_model(
        formula = formula,
        data = dat_m,
        model = model,
        family = family
      )

      fits[[m]] <- fit_m

      coef_list[[m]] <- stats::coef(fit_m)

      var_list[[m]] <- diag(stats::vcov(fit_m))
    }

    coef_mat <- do.call(
      rbind,
      coef_list
    )

    var_mat <- do.call(
      rbind,
      var_list
    )

    pooled <- .pool_rubin(
      coef_mat,
      var_mat
    )

    if(exponentiate){

      pooled$exp_estimate <- exp(pooled$estimate)

      pooled$exp_lower <- exp(pooled$lower)

      pooled$exp_upper <- exp(pooled$upper)
    }

    structure(
      list(
        method = "pmi",
        model = model,
        M = M,
        pooled = pooled,
        fits = fits,
        call = match.call()
      ),
      class = "mmlca_outcome"
    )
  }


}


#----------------------------------------------------------
# Rubin pooling
#----------------------------------------------------------

.pool_rubin <- function(estimates, variances){

  M <- nrow(estimates)

  qbar <- colMeans(estimates)

  ubar <- colMeans(variances)

  b <- apply(estimates, 2, var)

  tvar <- ubar + (1 + 1/M) * b

  se <- sqrt(tvar)

  df <- (M - 1) *
    (1 + ubar / ((1 + 1/M) * b))^2

  p <- 2 * pt(abs(qbar / se),
              df = df,
              lower.tail = FALSE)

  out <- data.frame(
    term = names(qbar),
    estimate = qbar,
    std.error = se,
    statistic = qbar / se,
    df = df,
    p.value = p,
    lower = qbar - qt(0.975, df) * se,
    upper = qbar + qt(0.975, df) * se,
    row.names = NULL
  )

  out
}


#----------------------------------------------------------
# Single complete-data fit
#----------------------------------------------------------

.fit_model <- function(
    formula,
    data,
    model = c("glm","coxph"),
    family = gaussian()
){

  model <- match.arg(model)

  if(model == "glm"){

    fit <- glm(
      formula,
      data = data,
      family = family
    )

  } else if(model == "coxph") {

    fit <- survival::coxph(
      formula,
      data = data
    )
  } else{
    stop("Other regression models not yet implemented")
  }

  fit
}


# -----------------------------------------
# Print
#----------------------------------------------------------
#'@exportS3Method

print.mmlca_outcome <- function(x, ...){

  cat("\n")
  cat("MMLCA Outcome Model\n")
  cat("-------------------\n")
  cat("Method :", x$method, "\n")

  if(!is.null(x$M))
    cat("M      :", x$M, "\n")

  cat("\n")

  print(x$pooled)

  invisible(x)
}

#----------------------------------------------------------
# Summary
#----------------------------------------------------------

#'@exportS3Method

summary.mmlca_outcome <- function(object,digits=3, ...){

  s <- object$pooled
  s[,-1] <- round(s[,-1],digits)
  s
}


  .bootstrap_summary <- function(beta_boot,
                                 est,
                                 conf.level = 0.95,
                                 exponentiate = FALSE){

    alpha <- 1 - conf.level

    est <- est

    se <- apply(beta_boot, 2, sd)

    lower <- apply(
      beta_boot,
      2,
      quantile,
      probs = alpha/2,
      na.rm = TRUE
    )

    upper <- apply(
      beta_boot,
      2,
      quantile,
      probs = 1 - alpha/2,
      na.rm = TRUE
    )


    p <- apply(beta_boot, 2, function(x) {
      2 * min(
        mean(x <= 0, na.rm = TRUE),
        mean(x >= 0, na.rm = TRUE)
      )
    })

    p <- pmin(p, 1)

    out <- data.frame(
      term = colnames(beta_boot),
      estimate = est,
      std.error = se,
      p.value = p,
      lower = lower,
      upper = upper,
      row.names = NULL
    )

    if(exponentiate){

      out$estimate_exp <- exp(out$estimate)
      out$lower_exp <- exp(out$lower)
      out$upper_exp <- exp(out$upper)
    }

    out
  }
