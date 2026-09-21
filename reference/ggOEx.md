# Plot the Observed/Expected Ratios and Exclusivity

The function calculates Observed/Expected (O/E) ratios and disease
exclusivity for each latent class and displays them graphically.
Diseases exceeding the specified O/E and exclusivity thresholds are
highlighted.

## Usage

``` r
ggOEx(
  obj,
  cutoff_OE = 2,
  cutoff_Ex = 0.25,
  table = F,
  ci = F,
  nsample = 1000,
  names = F,
  classes_lab = "Latent class"
)
```

## Arguments

- obj:

  A fitted `poLCA` object.

- cutoff_OE:

  Numeric indicating the cut-off for the Observed/Expected ratio.

- cutoff_Ex:

  Numeric indicating the cut-off for Exclusivity.

- table:

  Logical; if `TRUE`, returns the underlying table in addition to the
  plot. Default is `FALSE`.

- ci:

  Logical; if `TRUE`, approximate 95% confidence intervals for the O/E
  ratios are obtained by Monte Carlo simulation using the estimated
  disease prevalences and their standard errors from the fitted latent
  class model. Default is `FALSE`.

- nsample:

  Integer specifying the number of Monte Carlo samples used to estimate
  the confidence intervals when `ci = TRUE`. Default is 1000.

- names:

  Logical; if `TRUE`, an additional panel displays diseases that
  simultaneously exceed both the O/E and Exclusivity thresholds. Default
  is `FALSE`.

## Value

A ggplot object. If `table = TRUE`, a list containing the plot and the
summary data frame used to generate it is returned.

## Details

The Observed/Expected (O/E) ratio is calculated as the prevalence of a
disease within a latent class divided by its prevalence in the total
sample. Disease exclusivity is calculated as the proportion of all
individuals with a given disease who belong to a specific latent class.

When `ci = TRUE`, approximate 95% confidence intervals for the O/E
ratios are computed using Monte Carlo sampling. Expected prevalences are
sampled from normal distributions based on the observed sample
prevalence, while class-specific prevalences are sampled using the
estimated probabilities and standard errors from the `poLCA` model. The
2.5th and 97.5th percentiles of the simulated O/E ratios are used as
confidence limits.
