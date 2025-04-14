#' Plot disease prevalences within MM patterns
#' @description The function plots the conditional disease prevalence, highlighting diseases with high O/E, Exclusivity or Entropy
#' @param obj
#' @param nclass
#' @param cutoff_OE
#' @param cutoff_Ex
#' @param cutoff_P
#'
#' @return
#' @export
#'
#' @examples
ggprev <- function(obj, nclass, cutoff_OE = 2, cutoff_Ex = 0.25, cutoff_P = NULL) {
  suppressMessages({
    suppressWarnings({
      nclass <- nrow(obj$probs[[1]])
      if (is.null(cutoff_Ex)) cutoff_Ex <- 0
      if (is.null(cutoff_OE)) cutoff_OE <- 0
      if (is.null(cutoff_P)) cutoff_P <- 0

      E <- apply(obj$y - 1, 2, mean)
      n <- list()
      for (j in 1:nclass) {
        n[[j]] <- rep(NA, ncol(obj$y))
        for (i in 1:ncol(obj$y)) {
          n[[j]][i] <- obj$probs[[i]][j, 2]
        }
      }

      O <- do.call("cbind", n)
      rownames(O) <- colnames(obj$y)
      R <- O / E

      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Multimorbidity profile",
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`)),
                      label_P = ifelse(Prevalence < cutoff_P, NA_integer_, Disease))


      R %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Multimorbidity profile",
          values_to = "O/E"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`))) %>%
        dplyr::mutate(
          label = ifelse(`O/E` < cutoff_OE, NA_integer_, Disease)
        )


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
          names_to = "Multimorbidity profile",
          values_to = "Exclusivity"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`))) %>%
        dplyr::mutate(label2 = ifelse(`Exclusivity` < cutoff_Ex, NA_integer_, Disease))


      Char_MP <- R %>%
        dplyr::left_join(Ex) %>%
        dplyr::left_join(O)

      Char_MP %<>% dplyr::mutate(char = ifelse(!is.na(label) & !is.na(label2) & !is.na(label_P), 1,0))


      Char_MP %<>%
        dplyr::select(`Multimorbidity profile`, Disease, Prevalence, Exclusivity, `O/E`, char) %>%
        dplyr::mutate(
          Prevalence = Prevalence * 100,
          Exclusivity = Exclusivity * 100,
          `O/E` = round(`O/E`, 2)
        )

      datn <- data.frame(
        `Multimorbidity profile` = 1:nclass,
        N = as.numeric(table(obj$predclass)),
        P = round(as.numeric(table(obj$predclass)) / length(obj$predclass) * 100, 0)
      )

      colnames(datn)[1] <- "Multimorbidity profile"
      Char_MP %<>% dplyr::left_join(datn)
      Char_MP %<>% dplyr::left_join(datn) %>%
        dplyr::mutate(`Multimorbidity profile` = paste0(`Multimorbidity profile`, " (", P, "%)"))

      gg <- ggplot2::ggplot(Char_MP) +
        ggplot2::geom_point(ggplot2::aes(1, Disease, size = Prevalence / 10, color = as.factor(char))) +
        ggplot2::scale_x_continuous("", breaks = NULL) +
        ggplot2::facet_grid(~`Multimorbidity profile`) +
        ggprism::theme_prism() +
        ggplot2::scale_color_manual("Overexpression above threshold", values = c("grey60", "indianred"), labels = c("No", "Yes")) +
        ggplot2::scale_size_continuous("Prevalence (%)",
          guide = ggplot2::guide_legend(override.aes = list(col = "grey60")),
          breaks = c(1, 2.5, 5, 8),
          labels = c(10, 25, 50, 80)
        ) +
        ggplot2::ggtitle("Multimorbidity Profiles")
        ggplot2::theme(
          axis.ticks.x = ggplot2::element_blank(),
          legend.title = ggplot2::element_text(),
          legend.position = "bottom",
          panel.grid.major.y = ggplot2::element_line(color = "grey90", linetype = "dashed", linewidth = 0.3)

        )


      print(gg)
      return(gg)
    })
  })
}
