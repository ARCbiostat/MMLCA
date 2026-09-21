# Plot Observed/Expected Ratios

Calculates Observed/Expected (O/E) ratios for each disease within each
Multimorbidity profile and displays them graphically. Diseases exceeding
the specified O/E threshold can be highlighted and optionally filtered
by a minimum within-class prevalence threshold.

## Usage

``` r
ggOE(
  obj,
  cutoff_OE = 2,
  cutoff_P = NULL,
  table = F,
  ci = F,
  nsample = 1000,
  classes_lab = "Multimorbidity profile"
)
```

## Arguments

- obj:

  A fitted `poLCA` object.

- cutoff_OE:

  Numeric indicating the cut-off value used to identify diseases with
  elevated O/E ratios. Default is 2.

- cutoff_P:

  Numeric indicating the minimum disease prevalence within a
  Multimorbidity profile required for a disease to be considered in the
  characterization. If `NULL`, all diseases are considered.

- table:

  Logical; if `TRUE`, returns the underlying table in addition to the
  plot. Default is `FALSE`.

- ci:

  Logical; if `TRUE`, approximate 95% confidence intervals for the O/E
  ratios are estimated using Monte Carlo simulation and displayed in the
  plot. Default is `FALSE`.

- nsample:

  Integer specifying the number of Monte Carlo samples used to estimate
  confidence intervals when `ci = TRUE`. Default is 1000.

## Value

A `ggplot2` object. If `table = TRUE`, a list containing the plot and
the data frame used to generate it is returned.

## Details

Plot Observed/Expected Ratios

The Observed/Expected (O/E) ratio is calculated as the prevalence of a
disease within a Multimorbidity profile divided by its prevalence in the
overall sample. Values greater than one indicate that the disease is
more common within the Multimorbidity profile than expected based on its
population prevalence.

When `ci = TRUE`, approximate 95% confidence intervals for the O/E
ratios are obtained through Monte Carlo sampling. Overall disease
prevalences are sampled assuming a normal approximation to the binomial
distribution, while class-specific prevalences are sampled using the
estimated probabilities and standard errors from the fitted `poLCA`
model. Confidence limits correspond to the 2.5th and 97.5th percentiles
of the simulated O/E distribution.

Diseases are considered characteristic of a Multimorbidity profile when
their O/E ratio exceeds `cutoff_OE` and their prevalence exceeds
`cutoff_P`.
