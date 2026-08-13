#' Plot the Observed/Expected Ratios and Exclusivity
#' @description The function calculates the Observed/Expected Ratios and the Exclusivity and plot it highlighting diseases above the thresholds. Thresholds are automatically calculated based on pattern size.
#' @param obj poLCA object
#' @param table Boolean indicating whether the table of the O/E should be returned in addition to the plot.
#' @details The Observed/expected (O/E) ratios is calculated by dividing the prevalence of the condition within the pattern by its prevalence in the total sample. Disease exclusivity refers to the number of participants with the condition within the pattern compared to the total number of participants with the condition in the sample.
#' @return ggplot object. if table=T then a list of plot and data.frame is returned.
#' @export
#'
#' @examples
ggOExDyn <- function(obj, table = F, ci = F, nsample = 1000,names=F,classes_lab="Latent class") {
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
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))

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
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))

      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = "Latent class",
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(`Latent class` = as.numeric(gsub("\\D", "", `Latent class`)))



      Char_MP <- R %>%
        left_join(Ex) %>%
        left_join(O)

      datn <- data.frame(
        `Latent class` = 1:nclass,
        N = as.numeric(table(obj$predclass)),
        P = round(as.numeric(table(obj$predclass)) / length(obj$predclass) * 100, 0)
      ) %>%
        mutate(cut_OE=case_when(P>=25~1,
                                P<25 & P>=15~1.5,
                                P<15 & P>=10~1.75,
                                P<10 ~2),
               cut_Ex=case_when(P>25~0.3,
                                P<=25 & P>15~0.25,
                                P<=15 & P>10~0.20,
                                P<=10 ~0))


      colnames(datn)[1] <- "Latent class"
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
        dplyr::left_join(Ex) %>%
        dplyr::left_join(O) %>%
        dplyr::left_join(datn)

      Char_MP %<>%
        dplyr::mutate(char = ifelse(`O/E` > cut_OE & Exclusivity> cut_Ex, 1, NA_integer_)) %>%
      dplyr::mutate(label = ifelse(char==1, Disease, NA_integer_))




      if(ci){
        Char_MP %<>% left_join(lower) %>% left_join(upper)
        Char_MP %<>%
          dplyr::mutate(`Latent class` = paste0(`Latent class`, " (", P, "%)")) %>%
          dplyr::mutate(char = ifelse(`Lower O/E` > cut_OE & Exclusivity> cut_Ex, 1, NA_integer_))
          dplyr::mutate(label = ifelse(char==1, Disease, NA_integer_))


        ggOE <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_pointrange(ggplot2::aes(xmin = `Lower O/E`, xmax = `Upper O/E`, y = Disease, x = `O/E`), linewidth = 1) +
          ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity", alpha = 0.5) +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_OE), linetype = "dashed") +
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
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_Ex), linetype = "dashed") +
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
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_OE), linetype = "dashed") +
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
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_Ex), linetype = "dashed") +
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
        dplyr::ungroup() %>%
        dplyr::filter(char == 1) %>%
        dplyr::group_by(`Latent class`) %>%
        dplyr::arrange(desc(`O/E`),desc(Exclusivity)) %>%
        dplyr::mutate(index = row_number())

      ggnames <- ggplot2::ggplot(Char_MP2) +
        ggplot2::geom_text(ggplot2::aes(0.1, index, label = label, hjust = "left",col=ifelse(index%in%c(1:3),"2","1")), size = 4) +
        ggplot2::facet_grid(. ~ `Latent class`, drop = F) +
        ggplot2::scale_y_reverse("Disease") +
        ggplot2::scale_x_continuous(limits = c(0, 1)) +
        ggplot2::scale_color_manual(values = c("black","red"))+
        ggplot2::theme_void() +
        ggplot2::ggtitle("Diseases above thresholds:") +
        ggplot2::theme(
          legend.position = "null",
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          strip.text.x.top = ggplot2::element_blank(),
          text = ggplot2::element_text( size = 14)
        )

      if(names){
        gg <- ggpubr::ggarrange(ggOE, ggex, ggnames, nrow = 3, align = "v")
        print(gg)
      }else{
        gg <- ggpubr::ggarrange(ggOE, ggex, nrow = 2, align = "v")
      }

      print("Diseases above threshold:")
      print(Char_MP2 %>% dplyr::select(`Latent class`,index, label) %>% dplyr::arrange(`Latent class`,index) %>% dplyr::rename(Disease=label) %>% as.data.frame())
      if (table) {
        colnames(Char_MP)[4] <- "O/E above threshold"
        colnames(Char_MP)[6] <- "Exclusivity above threshold"
        colnames(Char_MP)[8] <- "Flag for O/E and exclusivity above threshold"

        return(list(plot = gg, table = Char_MP))
      } else {
        return(gg)
      }




      # Char_MP %<>% dplyr::left_join(datn) %>%
      # dplyr::mutate(`Latent class` = paste0(`Latent class`, " (", P, "%)")) %>%
      #   dplyr::mutate(char = ifelse(`O/E`>=cut_OE & Exclusivity>=cut_Ex, 1, NA_integer_),
      #                 label=ifelse(char==1,Disease,NA_character_))
      #
      # ggOE <- ggplot2::ggplot(Char_MP) +
      #   ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity") +
      #   ggplot2::geom_vline(ggplot2::aes(xintercept = cut_OE), linetype = "dashed") +
      #   ggplot2::facet_grid(. ~ `Latent class`) +
      #   ggplot2::scale_y_discrete("Chronic conditions") +
      #   ggprism::theme_prism() +
      #   ggplot2::theme(
      #     legend.position = "null",
      #     axis.text.y = ggplot2::element_text(hjust = 1,size=15),
      #     strip.text.x.top = ggplot2::element_text(size = 16),
      #     axis.ticks.y = ggplot2::element_blank(),
      #     panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
      #   ) +
      #   ggplot2::ggtitle("Latent class")
      #
      # ggex <- ggplot2::ggplot(Char_MP) +
      #   ggplot2::geom_bar(ggplot2::aes(Exclusivity, Disease, fill = Disease), stat = "identity") +
      #   ggplot2::geom_vline(ggplot2::aes(xintercept = cut_Ex), linetype = "dashed") +
      #   ggplot2::facet_grid(. ~ `Latent class`) +
      #   ggplot2::scale_y_discrete("Chronic conditions") +
      #   ggplot2::scale_x_continuous(limits = c(0, 1)) +
      #   ggprism::theme_prism() +
      #   ggplot2::theme(
      #     legend.position = "null",
      #     axis.text.y = ggplot2::element_text(hjust = 1,size=15),
      #     strip.text.x.top = ggplot2::element_blank(),
      #     axis.ticks.y = ggplot2::element_blank(),
      #     panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
      #   )
      #
      # Char_MP %<>% mutate(`Latent class` = as.factor(`Latent class`))
      #
      # Char_MP2 <- Char_MP %>%
      #   dplyr::ungroup() %>%
      #   dplyr::filter(char == 1) %>%
      #   dplyr::group_by(`Latent class`) %>%
      #   dplyr::arrange(desc(`O/E`),desc(Exclusivity)) %>%
      #   dplyr::mutate(index = row_number())
      #
      # ggnames <- ggplot2::ggplot(Char_MP2) +
      #   ggplot2::geom_text(ggplot2::aes(0.1, index, label = label, hjust = "left",col=ifelse(index%in%c(1:3),"2","1")), size = 8) +
      #   ggplot2::facet_grid(. ~ `Latent class`, drop = F) +
      #   ggplot2::scale_y_reverse("Chronic conditions") +
      #   ggplot2::scale_x_continuous(limits = c(0, 1)) +
      #   ggplot2::scale_color_manual(values = c("black","red"))+
      #   ggplot2::theme_void() +
      #   ggplot2::ggtitle("Diseases above thresholds:") +
      #   ggplot2::theme(
      #     legend.position = "null",
      #     axis.text.y = ggplot2::element_blank(),
      #     axis.ticks.y = ggplot2::element_blank(),
      #     strip.text.x.top = ggplot2::element_blank(),
      #     text = ggplot2::element_text(face = "bold", size = 16)
      #   )
      #
      #
      # gg <- ggpubr::ggarrange(ggOE, ggex, ggnames, nrow = 3, align = "v")
      # print(gg)
      # if (table) {
      #   Char_MP %<>%
      #     dplyr::group_by(`Latent class`) %>%
      #     dplyr::arrange(`Latent class`,desc(`O/E`),desc(Exclusivity)) %>%
      #     dplyr::mutate(index = row_number()) %>%
      #     dplyr::select(`Latent class`,Disease,index,char,`O/E`,Exclusivity,Prevalence,cut_OE,cut_Ex)
      #   # colnames(Char_MP)[4] <- "O/E above threshold"
      #   # colnames(Char_MP)[6] <- "Exclusivity above threshold"
      #   colnames(Char_MP)[4] <- "Flag for O/E and exclusivity above threshold"
      #
      #   return(list(plot = gg, table = Char_MP))
      # } else {
      #   return(gg)
      # }
    })
  })
}
