#' Plot the Observed/Expected Ratios and Exclusivity
#'
#' @description
#' The function calculates Observed/Expected (O/E) ratios and disease
#' exclusivity for each latent class and displays them graphically.
#' Diseases exceeding the specified O/E and exclusivity thresholds are
#' highlighted.
#'
#' @param obj A fitted \code{poLCA} object.
#' @param cutoff_OE Numeric indicating the cut-off for the Observed/Expected ratio.
#' @param cutoff_Ex Numeric indicating the cut-off for Exclusivity.
#' @param table Logical; if \code{TRUE}, returns the underlying table in addition
#'   to the plot. Default is \code{FALSE}.
#' @param ci Logical; if \code{TRUE}, approximate 95\% confidence intervals for
#'   the O/E ratios are obtained by Monte Carlo simulation using the estimated
#'   disease prevalences and their standard errors from the fitted latent class
#'   model. Default is \code{FALSE}.
#' @param nsample Integer specifying the number of Monte Carlo samples used to
#'   estimate the confidence intervals when \code{ci = TRUE}. Default is 1000.
#' @param names Logical; if \code{TRUE}, an additional panel displays diseases
#'   that simultaneously exceed both the O/E and Exclusivity thresholds.
#'   Default is \code{FALSE}.
#'
#' @details
#' The Observed/Expected (O/E) ratio is calculated as the prevalence of a
#' disease within a latent class divided by its prevalence in the total sample.
#' Disease exclusivity is calculated as the proportion of all individuals with
#' a given disease who belong to a specific latent class.
#'
#' When \code{ci = TRUE}, approximate 95\% confidence intervals for the O/E
#' ratios are computed using Monte Carlo sampling. Expected prevalences are
#' sampled from normal distributions based on the observed sample prevalence,
#' while class-specific prevalences are sampled using the estimated
#' probabilities and standard errors from the \code{poLCA} model. The 2.5th
#' and 97.5th percentiles of the simulated O/E ratios are used as confidence
#' limits.
#'
#' @return
#' A ggplot object. If \code{table = TRUE}, a list containing the plot and the
#' summary data frame used to generate it is returned.
#' @export
ggOEx <- function(obj, cutoff_OE = 2, cutoff_Ex = 0.25, table = F, ci = F, nsample = 1000,names=F,classes_lab="Latent class") {
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
      R %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Latent class",
          values_to = "O/E"
        ) %>%
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`))) %>%
        dplyr::mutate(label = ifelse(`O/E` < cutoff_OE, NA_integer_, Disease))

      N <- apply(obj$y - 1, 2, sum)

      n <- list()
      for (j in 1:nclass) {
        n[[j]] <- apply(obj$y[obj$predclass == j, ] - 1, 2, sum)
      }

      Ex <- do.call("cbind", n)

      Ex <- Ex / N
      Ex %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Latent class",
          values_to = "Exclusivity"
        ) %>%
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`))) %>%
        dplyr::mutate(label2 = ifelse(`Exclusivity` < cutoff_Ex, NA_integer_, Disease))

      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Latent class",
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))


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
            names_to = "Latent class",
            values_to = "Lower O/E"
          ) %>%
          dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))


        upper %<>% t() %>%
          as.data.frame() %>%
          tibble::rownames_to_column("Disease") %>%
          tidyr::pivot_longer(2:(nclass + 1),
            names_to = "Latent class",
            values_to = "Upper O/E"
          ) %>%
          dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))
      }

      Char_MP <- R %>%
        left_join(Ex) %>%
        left_join(O)
      Char_MP %<>% mutate(char = ifelse(!is.na(label) & !is.na(label2), 1, NA_integer_))
      datn <- data.frame(
        `Latent class` = 1:nclass,
        N = as.numeric(table(obj$predclass)),
        P = round(as.numeric(table(obj$predclass)) / length(obj$predclass) * 100, 0)
      )

      colnames(datn)[1] <- "Latent class"


      if(ci){
        Char_MP %<>% left_join(lower) %>% left_join(upper)
        Char_MP %<>% dplyr::left_join(datn) %>%
          dplyr::mutate(`Latent class` = paste0(`Latent class`, " (", P, "%)")) %>%
          dplyr::mutate(label3 = ifelse(!is.na(label) & !is.na(label2), Disease, NA_integer_))
        Char_MP %<>% mutate(char = ifelse(`Lower O/E` > cutoff_OE & Exclusivity> cutoff_Ex, 1, NA_integer_))

        ggOE <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_pointrange(ggplot2::aes(xmin = `Lower O/E`, xmax = `Upper O/E`, y = Disease, x = `O/E`), linewidth = 1) +
          ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity", alpha = 0.5) +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cutoff_OE), linetype = "dashed") +
          ggplot2::facet_grid(. ~ `Latent class`) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = 1),
            strip.text.x.top = ggplot2::element_text(size = 14),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          ) +
          ggplot2::ggtitle("Latent class")

        ggex <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_bar(ggplot2::aes(Exclusivity, Disease, fill = Disease), stat = "identity") +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cutoff_Ex), linetype = "dashed") +
          ggplot2::facet_grid(. ~ `Latent class`) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::scale_x_continuous(limits = c(0, 1)) +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = 1),
            strip.text.x.top = ggplot2::element_blank(),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          )
      }else{

        Char_MP %<>% dplyr::left_join(datn) %>%
          dplyr::mutate(`Latent class` = paste0(`Latent class`, " (", P, "%)"))

        ggOE <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity") +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cutoff_OE), linetype = "dashed") +
          ggplot2::facet_grid(. ~ `Latent class`) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = 1),
            strip.text.x.top = ggplot2::element_text(size = 14),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          ) +
          ggplot2::ggtitle("Latent class")

        ggex <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_bar(ggplot2::aes(Exclusivity, Disease, fill = Disease), stat = "identity") +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cutoff_Ex), linetype = "dashed") +
          ggplot2::facet_grid(. ~ `Latent class`) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::scale_x_continuous(limits = c(0, 1)) +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = 1),
            strip.text.x.top = ggplot2::element_blank(),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          )
      }


      Char_MP %<>% mutate(`Latent class` = as.factor(`Latent class`))

      Char_MP2 <- Char_MP %>%
        dplyr::filter(char == 1) %>%
        dplyr::group_by(`Latent class`) %>%
        dplyr::mutate(index = row_number())

      ggnames <- ggplot2::ggplot(Char_MP2) +
        ggplot2::geom_text(ggplot2::aes(0.1, index, label = label2, hjust = "left"), size = 6) +
        ggplot2::facet_grid(. ~ `Latent class`, drop = F) +
        ggplot2::scale_y_reverse("Disease") +
        ggplot2::scale_x_continuous(limits = c(0, 1)) +
        ggplot2::theme_void() +
        ggplot2::ggtitle("Diseases above thresholds:") +
        ggplot2::theme(
          legend.position = "null",
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          strip.text.x.top = ggplot2::element_blank(),
          text = ggplot2::element_text(size = 14)
        )

if(names){
  gg <- ggpubr::ggarrange(ggOE, ggex, ggnames, nrow = 3, align = "v")
  print(gg)
}else{
  gg <- ggpubr::ggarrange(ggOE, ggex, nrow = 2, align = "v")
}

print("Diseases above threshold:")
print(Char_MP2 %>% dplyr::select(`Latent class`,label2) %>% dplyr::arrange(`Latent class`) %>% dplyr::rename(Disease=label2) %>% as.data.frame())
      if (table) {
        colnames(Char_MP)[4] <- "O/E above threshold"
        colnames(Char_MP)[6] <- "Exclusivity above threshold"
        colnames(Char_MP)[8] <- "Flag for O/E and exclusivity above threshold"

        return(list(plot = gg, table = Char_MP))
      } else {
        return(gg)
      }
    })
  })
}
