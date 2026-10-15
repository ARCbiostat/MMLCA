# Plot the Observed/Expected Ratios and Exclusivity

The function calculates the Observed/Expected Ratios and the Exclusivity
and plot it highlighting diseases above the thresholds. Thresholds are
automatically calculated based on pattern size.

## Usage

``` r
ggOEx_adaptive(...)

ggOExDyn(
  obj,
  table = F,
  ci = F,
  nsample = 1000,
  names = F,
  classes_lab = "Latent class"
)
```

## Arguments

- obj:

  poLCA object

- table:

  Boolean indicating whether the table of the O/E should be returned in
  addition to the plot.

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

- classes_lab:

  string indicating how classes should be named in the plot. Default is
  "Latent class"

## Value

ggplot object. if table=T then a list of plot and data.frame is
returned.

## Details

The Observed/expected (O/E) ratios is calculated by dividing the
prevalence of the condition within the pattern by its prevalence in the
total sample. Disease exclusivity refers to the number of participants
with the condition within the pattern compared to the total number of
participants with the condition in the sample. The adaptive threshold
strategy implemented in MMLCA reflects these considerations by
progressively relaxing O/E requirements for highly prevalent classes
while simultaneously applying more stringent exclusivity criteria. In
addition, the exclusivity criteria are also dependent on the total
number of classes under investigation. As a result, the identification
of characteristic diseases becomes less sensitive to class size and more
comparable across patterns of different prevalence. Specifically, for
classes representing at least 25% of the population, diseases are
considered overrepresented when O/E ≥ 1.15, whereas progressively higher
thresholds (1.5, 1.75, and 2.0) are applied as class prevalence
decreases below 25%, 15%, and 10%, respectively. For exclusivity,
thresholds are defined relative to the theoretical benchmark of 1/k,
where k the number of latent classes. The exclusivity threshold is
increased by 20% for highly prevalent classes (≥ 25% of the population),
remains unchanged for classes with prevalence between 15% and 25%, and
is reduced by 20% and 40% for classes with prevalence between 10% and
15% and below 10%, respectively.
