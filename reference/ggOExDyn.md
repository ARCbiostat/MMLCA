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

## Value

ggplot object. if table=T then a list of plot and data.frame is
returned.

## Details

The Observed/expected (O/E) ratios is calculated by dividing the
prevalence of the condition within the pattern by its prevalence in the
total sample. Disease exclusivity refers to the number of participants
with the condition within the pattern compared to the total number of
participants with the condition in the sample.
