#' Plot Observed/Expected Ratios
#'
#' Plot Observed/Expected Ratios
#' @description
#' Calculates Observed/Expected (O/E) ratios for each disease within each
#' Multimorbidity profile and displays them graphically. Diseases exceeding the
#' specified O/E threshold can be highlighted and optionally filtered by a
#' minimum within-class prevalence threshold.
#'
#' @param obj A fitted \code{poLCA} object.
#' @param cutoff_OE Numeric indicating the cut-off value used to identify
#'   diseases with elevated O/E ratios. Default is 2.
#' @param cutoff_P Numeric indicating the minimum disease prevalence within a
#'   Multimorbidity profile required for a disease to be considered in the
#'   characterization. If \code{NULL}, all diseases are considered.
#' @param table Logical; if \code{TRUE}, returns the underlying table in
#'   addition to the plot. Default is \code{FALSE}.
#' @param ci Logical; if \code{TRUE}, approximate 95\% confidence intervals
#'   for the O/E ratios are estimated using Monte Carlo simulation and
#'   displayed in the plot. Default is \code{FALSE}.
#' @param nsample Integer specifying the number of Monte Carlo samples used
#'   to estimate confidence intervals when \code{ci = TRUE}. Default is 1000.
#'
#' @details
#' The Observed/Expected (O/E) ratio is calculated as the prevalence of a
#' disease within a Multimorbidity profile divided by its prevalence in the overall
#' sample. Values greater than one indicate that the disease is more common
#' within the Multimorbidity profile than expected based on its population prevalence.
#'
#' When \code{ci = TRUE}, approximate 95\% confidence intervals for the O/E
#' ratios are obtained through Monte Carlo sampling. Overall disease
#' prevalences are sampled assuming a normal approximation to the binomial
#' distribution, while class-specific prevalences are sampled using the
#' estimated probabilities and standard errors from the fitted
#' \code{poLCA} model. Confidence limits correspond to the 2.5th and
#' 97.5th percentiles of the simulated O/E distribution.
#'
#' Diseases are considered characteristic of a Multimorbidity profile when their O/E
#' ratio exceeds \code{cutoff_OE} and their prevalence exceeds
#' \code{cutoff_P}.
#'
#' @return
#' A \code{ggplot2} object. If \code{table = TRUE}, a list containing the
#' plot and the data frame used to generate it is returned.
#'
#' @export
ggOE <- function(obj, cutoff_OE = 2, cutoff_P = NULL, table = F, ci = F, nsample = 1000,classes_lab="Multimorbidity profile") {
  suppressMessages({
    suppressWarnings({
      nclass <- nrow(obj$probs[[1]])

      E <- apply(obj$y - 1, 2, mean)
      n <- list()
      for (j in 1:nclass) {
        n[[j]] <- apply(obj$y[obj$predclass == j, ] - 1, 2, mean)
      }



      O <- do.call("cbind", n)
      rownames(O) <- colnames(obj$y)
      R <- O / E

      if (ci) {
        observed_ci <- array(NA, dim = c(nclass, nsample, ncol(obj$y)))
        expected_ci <- matrix(NA, nrow = nsample, ncol = ncol(obj$y))
        OE_ci <- array(NA, dim = c(nclass, nsample, ncol(obj$y)))

        for (i in 1:ncol(obj$y)) {
          expected_ci[, i] <- rnorm(nsample, mean = E[i], sd = sqrt((E[i] * (1 - E[i]) / nrow(obj$y))))
        }
        for (j in 1:nclass) {
          for (i in 1:ncol(obj$y)) {
            observed_ci[j, , i] <- rnorm(nsample, mean = obj$probs[[i]][j, 2], sd = obj$probs.se[[i]][j, 2])
            OE_ci[j, , i] <- observed_ci[j, , i] / expected_ci[, i]
          }
        }

        lower <- apply(OE_ci, c(1, 3), quantile, prob = 0.025, na.rm = T)
        upper <- apply(OE_ci, c(1, 3), quantile, prob = 0.975, na.rm = T)

        colnames(lower) <- colnames(upper) <- colnames(obj$y)


        lower %<>% t() %>%
          as.data.frame() %>%
          tibble::rownames_to_column("Disease") %>%
          tidyr::pivot_longer(2:(nclass + 1),
            names_to = "Multimorbidity profile",
            values_to = "Lower O/E"
          ) %>%
          dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`)))


        upper %<>% t() %>%
          as.data.frame() %>%
          tibble::rownames_to_column("Disease") %>%
          tidyr::pivot_longer(2:(nclass + 1),
            names_to = "Multimorbidity profile",
            values_to = "Upper O/E"
          ) %>%
          dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`)))
      }

      if (is.null(cutoff_P)) cutoff_P <- 0
      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Multimorbidity profile",
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`))) %>%
        dplyr::mutate(label2 = ifelse(Prevalence < cutoff_P, NA_integer_, Disease))


      R %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Multimorbidity profile",
          values_to = "O/E"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`))) %>%
        dplyr::mutate(label = ifelse(`O/E` < cutoff_OE, NA_integer_, Disease))

      Char_MP <- R %>% dplyr::left_join(O)

      Char_MP %<>% dplyr::mutate(char = ifelse(!is.na(label) & !is.na(label2), 1, NA_integer_))


      datn <- data.frame(
        `Multimorbidity profile` = 1:nclass,
        N = as.numeric(table(obj$predclass)),
        P = round(as.numeric(table(obj$predclass)) / length(obj$predclass) * 100, 0)
      )

      colnames(datn)[1] <- "Multimorbidity profile"


      if (ci) {
        Char_MP %<>% left_join(lower) %>% left_join(upper)
        Char_MP %<>% dplyr::left_join(datn) %>%
          dplyr::mutate(`Multimorbidity profile` = paste0(`Multimorbidity profile`, " (", P, "%)")) %>%
          dplyr::mutate(label3 = ifelse(!is.na(label) & !is.na(label2), Disease, NA_integer_))
        Char_MP %<>% mutate(sign = ifelse(`Lower O/E` > cutoff_OE & Prevalence >= cutoff_P, Disease, NA_integer_))
suppressWarnings({
  ggOE <- ggplot2::ggplot(Char_MP) +
    ggplot2::geom_text(ggplot2::aes(`Upper O/E`, Disease, label = sign, hjust = "left"), size = 5,na.rm = T) +
    ggplot2::geom_pointrange(ggplot2::aes(xmin = `Lower O/E`, xmax = `Upper O/E`, y = Disease, x = `O/E`), linewidth = 1) +
    ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity", alpha = 0.5) +
    ggplot2::geom_vline(ggplot2::aes(xintercept = cutoff_OE), linetype = "dashed") +
    ggplot2::facet_grid(. ~ `Multimorbidity profile`) +
    ggplot2::scale_y_discrete("Disease") +
    ggplot2::scale_x_continuous("O/E") +
    ggplot2::theme_bw(base_size = 14) +
    ggplot2::theme(
      legend.position = "null",
      axis.text.y = ggplot2::element_text(hjust = 1),
      strip.text.x.top = ggplot2::element_text(size = 14),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
    ) +
    ggplot2::ggtitle("Multimorbidity Patterns")
  print(ggOE)
})




      } else {
        Char_MP %<>% dplyr::left_join(datn) %>%
          dplyr::mutate(`Multimorbidity profile` = paste0(`Multimorbidity profile`, " (", P, "%)")) %>%
          dplyr::mutate(label3 = ifelse(!is.na(label) & !is.na(label2), Disease, NA_integer_))

        suppressWarnings({
          ggOE <- ggplot2::ggplot(Char_MP) +
            ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity") +
            ggplot2::geom_text(ggplot2::aes(`O/E`, Disease, label = label3, hjust = "left"), size = 5,na.rm = T) +
            ggplot2::geom_vline(ggplot2::aes(xintercept = cutoff_OE), linetype = "dashed") +
            ggplot2::facet_grid(. ~ `Multimorbidity profile`) +
            ggplot2::scale_y_discrete("Disease") +
            ggplot2::scale_x_continuous("O/E")+
            ggplot2::theme_bw(base_size = 14) +
            ggplot2::theme(
              legend.position = "null",
              axis.text.y = ggplot2::element_text(hjust = 1),
              strip.text.x.top = ggplot2::element_text(size = 14),
              axis.ticks.y = ggplot2::element_blank(),
              panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
            ) +
            ggplot2::ggtitle("Multimorbidity Patterns")
          print(ggOE)
        })

      }
      if (table) {
        colnames(Char_MP)[4] <- "O/E above threshold"
        colnames(Char_MP)[6] <- "Prevalence above threshold"
        colnames(Char_MP)[7] <- "Flag for prevalence and O/E above threshold"
        colnames(Char_MP)[10] <- "Prevalence and O/E above threshold"

        return(list(plot = ggOE, table = Char_MP))
      } else {
        invisible(return(ggOE))
      }
    })
  })
}
