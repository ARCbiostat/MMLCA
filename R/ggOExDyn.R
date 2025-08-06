#' Plot the Observed/Expected Ratios and Exclusivity
#' @description The function calculates the Observed/Expected Ratios and the Exclusivity and plot it highlighting diseases above the thresholds. Thresholds are automatically calculated based on pattern size.
#' @param obj poLCA object
#' @param table Boolean indicating whether the table of the O/E should be returned in addition to the plot.
#' @details The Observed/expected (O/E) ratios is calculated by dividing the prevalence of the condition within the pattern by its prevalence in the total sample. Disease exclusivity refers to the number of participants with the condition within the pattern compared to the total number of participants with the condition in the sample.
#' @return ggplot object. if table=T then a list of plot and data.frame is returned.
#' @export
#'
#' @examples
ggOExDyn <- function(obj, table = F, boot = F, nboot = 1000) {
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
          names_to = "Multimorbidity profile",
          values_to = "O/E"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`)))

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
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`)))

      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Multimorbidity profile",
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(`Multimorbidity profile` = as.numeric(gsub("\\D", "", `Multimorbidity profile`)))



      Char_MP <- R %>%
        left_join(Ex) %>%
        left_join(O)

      datn <- data.frame(
        `Multimorbidity profile` = 1:nclass,
        N = as.numeric(table(obj$predclass)),
        P = round(as.numeric(table(obj$predclass)) / length(obj$predclass) * 100, 0)
      ) %>%
        mutate(cut_OE=case_when(P>=25~1.25,
                                P<25 & P>=15~1.5,
                                P<15 & P>=10~1.75,
                                P<10 ~2),
               cut_Ex=case_when(P>=25~0.3,
                                P<25 & P>=15~0.25,
                                P<15~0.20))


      colnames(datn)[1] <- "Multimorbidity profile"


      Char_MP %<>% dplyr::left_join(datn) %>%
      dplyr::mutate(`Multimorbidity profile` = paste0(`Multimorbidity profile`, " (", P, "%)")) %>%
        dplyr::mutate(char = ifelse(`O/E`>=cut_OE & Exclusivity>=cut_Ex, 1, NA_integer_),
                      label=ifelse(char==1,Disease,NA_character_))

      ggOE <- ggplot2::ggplot(Char_MP) +
        ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity") +
        ggplot2::geom_vline(ggplot2::aes(xintercept = cut_OE), linetype = "dashed") +
        ggplot2::facet_grid(. ~ `Multimorbidity profile`) +
        ggplot2::scale_y_discrete("Chronic conditions") +
        ggprism::theme_prism() +
        ggplot2::theme(
          legend.position = "null",
          axis.text.y = ggplot2::element_text(hjust = 1),
          strip.text.x.top = ggplot2::element_text(size = 16),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
        ) +
        ggplot2::ggtitle("Multimorbidity Profiles")

      ggex <- ggplot2::ggplot(Char_MP) +
        ggplot2::geom_bar(ggplot2::aes(Exclusivity, Disease, fill = Disease), stat = "identity") +
        ggplot2::geom_vline(ggplot2::aes(xintercept = cut_Ex), linetype = "dashed") +
        ggplot2::facet_grid(. ~ `Multimorbidity profile`) +
        ggplot2::scale_y_discrete("Chronic conditions") +
        ggplot2::scale_x_continuous(limits = c(0, 1)) +
        ggprism::theme_prism() +
        ggplot2::theme(
          legend.position = "null",
          axis.text.y = ggplot2::element_text(hjust = 1),
          strip.text.x.top = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
        )

      Char_MP %<>% mutate(`Multimorbidity profile` = as.factor(`Multimorbidity profile`))

      Char_MP2 <- Char_MP %>%
        dplyr::ungroup() %>%
        dplyr::filter(char == 1) %>%
        dplyr::group_by(`Multimorbidity profile`) %>%
        dplyr::mutate(index = row_number())

      ggnames <- ggplot2::ggplot(Char_MP2) +
        ggplot2::geom_text(ggplot2::aes(0.1, index, label = label, hjust = "left"), size = 8) +
        ggplot2::facet_grid(. ~ `Multimorbidity profile`, drop = F) +
        ggplot2::scale_y_reverse("Chronic conditions") +
        ggplot2::scale_x_continuous(limits = c(0, 1)) +
        ggplot2::theme_void() +
        ggplot2::ggtitle("Diseases above thresholds:") +
        ggplot2::theme(
          legend.position = "null",
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          strip.text.x.top = ggplot2::element_blank(),
          text = ggplot2::element_text(face = "bold", size = 16)
        )

if(min(datn$P)<0.05) warning("Attention! MM patterns with less than 5% prevalence!")
      gg <- ggpubr::ggarrange(ggOE, ggex, ggnames, nrow = 3, align = "v")
      print(gg)
      if (table) {
        # colnames(Char_MP)[4] <- "O/E above threshold"
        # colnames(Char_MP)[6] <- "Exclusivity above threshold"
        # colnames(Char_MP)[8] <- "Flag for O/E and exclusivity above threshold"

        return(list(plot = gg, table = Char_MP))
      } else {
        return(gg)
      }
    })
  })
}
