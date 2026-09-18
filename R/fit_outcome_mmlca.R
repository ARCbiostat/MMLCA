
#' Title
#'
#' @param object
#' @param formula
#' @param data
#' @param model
#' @param family
#' @param method
#' @param M
#' @param pattern_var
#' @param conf.level
#' @param exponentiate
#' @param seed
#' @param boot
#' @param nboot
#' @param nrep
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
    pattern_var = "mm_pattern",
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

          tmp[[pattern_var]] <- factor(
            k,
            levels = seq_len(K)
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

      } else {

        fit <- survival::coxph(
          formula,
          data = long_dat,
          weights = .weight,
          cluster = id
        )

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

        dat_m[[pattern_var]] <-
          factor(
            cls,
            levels = seq_len(K)
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
      post <- lca_b$obj$posterior

      if(method=="pmi"){

        fits <- vector("list", M)

        coef_list <- vector("list", M)
        var_list <- vector("list", M)

        data_imp <- impute_mmlca(lca_b,nimp=M)

        for(m in seq_len(M)){

          dat_m <- boot_data


          cls <- data_imp[[m]]$mm_pattern

          dat_m[[pattern_var]] <-
            factor(
              cls,
              levels = seq_len(K)
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

            tmp[[pattern_var]] <- factor(
              k,
              levels = seq_len(K)
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



        } else {

          fit_b <- survival::coxph(
            formula,
            data = long_dat,
            weights = .weight
          )
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

          tmp[[pattern_var]] <- factor(
            k,
            levels = seq_len(K)
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

      } else {

        fit <- survival::coxph(
          formula,
          data = long_dat,
          weights = .weight,
          cluster = id
        )

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

      dat_m[[pattern_var]] <-
        factor(
          cls,
          levels = seq_len(K)
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

  } else {

    fit <- survival::coxph(
      formula,
      data = data
    )
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
