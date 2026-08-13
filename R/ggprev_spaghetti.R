#' Plot disease prevalences within MM patterns
#' @description The function plots the conditional disease prevalence using a spaghetti plot, highlighting diseases with high O/E, Exclusivity or Entropy
#' @param obj
#' @param nclass
#' @param cutoff_P
#'
#' @return
#' @export
#'
#' @examples
ggprev_spaghetti <- function(obj, cutoff_P = 0,classes_lab="Latent class") {
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



      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Latent class",
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))


      E %<>% as.data.frame()
      rownames(E) <- colnames(obj$y)
      E %<>%
        tibble::rownames_to_column("Disease")


      colnames(E)[2] <- "Overall prevalence"

      E %<>% dplyr::arrange(desc(`Overall prevalence`)) %>%
        dplyr::mutate(index = row_number())

      Char_MP <- E %>%
        dplyr::left_join(O) %>%
        mutate(label_P = ifelse(`Overall prevalence` < cutoff_P, NA_integer_, Disease))

      Char_MP %<>%
        tidyr::drop_na(label_P) %>%
        dplyr::arrange(index)


      Char_MP_ov <- Char_MP %>%
        dplyr::distinct(Disease, .keep_all = T) %>%
        dplyr::arrange(index)


      Char_MP$`Latent class` <- as.factor(Char_MP$`Latent class`)
      gg <- ggplot2::ggplot() +
        ggplot2::geom_point(
          data = Char_MP, ggplot2::aes(index,
            Prevalence,
            color = `Latent class`,
            group = `Latent class`
          ),
          size = 3
        ) +
        ggplot2::geom_line(
          data = Char_MP, ggplot2::aes(index,
            Prevalence,
            color = `Latent class`,
            group = `Latent class`
          ),
          linewidth = 1
        ) +
        ggplot2::geom_point(
          data = Char_MP_ov, ggplot2::aes(
            index,
            `Overall prevalence`
          ),
          size = 3
        ) +
        ggplot2::geom_line(
          data = Char_MP_ov, ggplot2::aes(index,
            `Overall prevalence`,
            group = 1
          ),
          linewidth = 1
        ) +
        ggplot2::scale_x_continuous("", breaks = unique(Char_MP$index), labels = unique(as.character(Char_MP$Disease))) +
        ggplot2::theme_bw() +
        ggplot2::theme(
          legend.title = ggplot2::element_text(),
          #legend.position = "bottom",
          panel.grid.major.y = ggplot2::element_line(color = "grey90", linetype = "dashed", linewidth = 0.3),
          axis.text.x = ggplot2::element_text(angle = 90,
                                              hjust = 1,
                                              vjust = 0.5)
        )


      print(gg)
      return(gg)
    })
  })
}
