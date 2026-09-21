# Plot disease prevalences within MM patterns

The function plots the conditional disease prevalence, highlighting
diseases with high O/E, Exclusivity or Entropy

## Usage

``` r
ggprevalence(...)

ggprev(
  obj,
  nclass,
  cutoff_OE = 2,
  cutoff_Ex = 0.25,
  cutoff_P = NULL,
  classes_lab = "Latent class"
)
```

## Arguments

- cutoff_OE:

  numeric or "a" for adaptive

- cutoff_Ex:

  numeric or "a" for adaptive

- cutoff_P:

  numeric
