#' Plot the Observed/Expected Ratios and Exclusivity
#' @description The function calculates the Observed/Expected Ratios and the Exclusivity and plot it highlighting diseases above the thresholds. Thresholds are automatically calculated based on pattern size.
#' @param obj poLCA object
#' @param table Boolean indicating whether the table of the O/E should be returned in addition to the plot.
#' @param ci Logical; if \code{TRUE}, approximate 95\% confidence intervals for
#'   the O/E ratios are obtained by Monte Carlo simulation using the estimated
#'   disease prevalences and their standard errors from the fitted latent class
#'   model. Default is \code{FALSE}.
#' @param nsample Integer specifying the number of Monte Carlo samples used to
#'   estimate the confidence intervals when \code{ci = TRUE}. Default is 1000.
#' @param names Logical; if \code{TRUE}, an additional panel displays diseases
#'   that simultaneously exceed both the O/E and Exclusivity thresholds.
#'   Default is \code{FALSE}.
#' @param classes_lab string indicating how classes should be named in the plot. Default is "Latent class"
#' @details The Observed/expected (O/E) ratios is calculated by dividing the prevalence of the condition within the pattern by its prevalence in the total sample. Disease exclusivity refers to the number of participants with the condition within the pattern compared to the total number of participants with the condition in the sample.
#' The adaptive threshold strategy implemented in MMLCA reflects these considerations by progressively relaxing O/E requirements for highly prevalent classes while simultaneously applying more stringent exclusivity criteria. In addition, the exclusivity criteria are also dependent on the total number of classes under investigation. As a result, the identification of characteristic diseases becomes less sensitive to class size and more comparable across patterns of different prevalence.
#' Specifically, for classes representing at least 25% of the population, diseases are considered overrepresented when O/E ≥ 1.15, whereas progressively higher thresholds (1.5, 1.75, and 2.0) are applied as class prevalence decreases below 25%, 15%, and 10%, respectively. For exclusivity, thresholds are defined relative to the theoretical benchmark of Image, where Imageis the number of latent classes. The exclusivity threshold is increased by 20% for highly prevalent classes (Image of the population), remains unchanged for classes with prevalence between 15% and 25%, and is reduced by 20% and 40% for classes with prevalence between 10% and 15% and below 10%, respectively.
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
          names_to = classes_lab,
          values_to = "O/E"
        ) %>%
        dplyr::mutate(!!rlang::sym(classes_lab)  := as.numeric(gsub("\\D", "", .data[[classes_lab]])))

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
          names_to = classes_lab,
          values_to = "Exclusivity"
        ) %>%
        dplyr::mutate(!!rlang::sym(classes_lab)  := as.numeric(gsub("\\D", "", .data[[classes_lab]])))

      O %<>% as.data.frame() %>%
        tibble::rownames_to_column("Disease") %>%
        tidyr::pivot_longer(2:(nclass + 1),
          names_to = classes_lab,
          values_to = "Prevalence"
        ) %>%
        dplyr::mutate(!!rlang::sym(classes_lab)  := as.numeric(gsub("\\D", "", .data[[classes_lab]])))



      Char_MP <- R %>%
        left_join(Ex) %>%
        left_join(O)

      base_cut_oex <- 1/(nclass-1)

      datn <- data.frame(
        `Latent class` = 1:nclass,
        N = as.numeric(table(obj$predclass)),
        P = round(as.numeric(table(obj$predclass)) / length(obj$predclass) * 100, 0)
      ) %>%
        mutate(cut_OE=case_when(P>=25~1.15,
                                P<25 & P>=15~1.5,
                                P<15 & P>=10~1.75,
                                P<10 ~2),
               cut_Ex=case_when(P>25~base_cut_oex*1.2,
                                P<=25 & P>15~base_cut_oex,
                                P<=15 & P>10~base_cut_oex*0.8,
                                P<=10 ~base_cut_oex*0.6))


      colnames(datn)[1] <- classes_lab
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
                              names_to = classes_lab,
                              values_to = "Lower O/E"
          ) %>%
          dplyr::mutate(!!rlang::sym(classes_lab)  := as.numeric(gsub("\\D", "", .data[[classes_lab]])))


        upper %<>% t() %>%
          as.data.frame() %>%
          tibble::rownames_to_column("Disease") %>%
          tidyr::pivot_longer(2:(nclass + 1),
                              names_to = classes_lab,
                              values_to = "Upper O/E"
          ) %>%
          dplyr::mutate(!!rlang::sym(classes_lab)  := as.numeric(gsub("\\D", "", .data[[classes_lab]])))
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
          dplyr::mutate(!!rlang::sym(classes_lab)  := paste0(.data[[classes_lab]], " (", P, "%)")) %>%
          dplyr::mutate(char = ifelse(`Lower O/E` > cut_OE & Exclusivity> cut_Ex, 1, NA_integer_))
          dplyr::mutate(label = ifelse(char==1, Disease, NA_integer_))


        ggOE <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_pointrange(ggplot2::aes(xmin = `Lower O/E`, xmax = `Upper O/E`, y = Disease, x = `O/E`), linewidth = 1) +
          ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity", alpha = 0.5) +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_OE), linetype = "dashed") +
          ggplot2::facet_grid(cols = vars(!!rlang::sym(classes_lab))) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = -1),
            strip.text.x.top = ggplot2::element_text(size = 14),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          ) +
          ggplot2::ggtitle(classes_lab)

        ggex <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_bar(ggplot2::aes(Exclusivity, Disease, fill = Disease), stat = "identity") +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_Ex), linetype = "dashed") +
          ggplot2::facet_grid(cols = vars(!!rlang::sym(classes_lab))) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::scale_x_continuous(limits = c(0, 1)) +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = -1),
            strip.text.x.top = ggplot2::element_blank(),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          )
      }else{

        Char_MP %<>% dplyr::left_join(datn) %>%
          dplyr::mutate(!!rlang::sym(classes_lab)  := paste0(.data[[classes_lab]], " (", P, "%)"))

        ggOE <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_bar(ggplot2::aes(`O/E`, Disease, fill = Disease), stat = "identity") +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_OE), linetype = "dashed") +
          ggplot2::facet_grid(cols = vars(!!rlang::sym(classes_lab))) +
          ggplot2::scale_y_discrete("Disease") +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.position = "null",
            axis.text.y = ggplot2::element_text(hjust = 1),
            strip.text.x.top = ggplot2::element_text(size = 14),
            axis.ticks.y = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = "grey", linewidth = 0.5)
          ) +
          ggplot2::ggtitle(classes_lab)

        ggex <- ggplot2::ggplot(Char_MP) +
          ggplot2::geom_bar(ggplot2::aes(Exclusivity, Disease, fill = Disease), stat = "identity") +
          ggplot2::geom_vline(ggplot2::aes(xintercept = cut_Ex), linetype = "dashed") +
          ggplot2::facet_grid(cols = vars(!!rlang::sym(classes_lab))) +
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


      Char_MP %<>% mutate(!!rlang::sym(classes_lab)  := as.factor(.data[[classes_lab]]))

      Char_MP2 <- Char_MP %>%
        dplyr::ungroup() %>%
        dplyr::filter(char == 1) %>%
        dplyr::group_by(.data[[classes_lab]]) %>%
        dplyr::arrange(desc(`O/E`),desc(Exclusivity)) %>%
        dplyr::mutate(index = row_number())

      ggnames <- ggplot2::ggplot(Char_MP2) +
        ggplot2::geom_text(ggplot2::aes(0.1, index, label = label, hjust = "left",col=ifelse(index%in%c(1:3),"2","1")), size = 4) +
        ggplot2::facet_grid(cols = vars(!!rlang::sym(classes_lab)), drop = F) +
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
      print(Char_MP2 %>% dplyr::select(.data[[classes_lab]],index, label) %>% dplyr::arrange(.data[[classes_lab]],index) %>% dplyr::rename(Disease=label) %>% as.data.frame())
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
