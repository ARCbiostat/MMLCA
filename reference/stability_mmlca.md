# Function to run LCA with different number of classes/resamples and compare the goodness-of-fit

This is a helper function to select the number of latent classes using
poLCA. For details regarding poLCA see the package documentation and
https://statistics.ohlsen-web.de/latent-class-analysis-polca/.

## Usage

``` r
stability_mmlca(
  nclasses,
  X,
  conditions,
  plot = T,
  nrep = 50,
  nboot = 10,
  seed = 123
)
```

## Arguments

- nclasses:

  Numeric vector indicating the number of latent classes to investigate.

- X:

  Matrix with chronic diseases variables (coded as 1:no and 2:yes) to
  use for the calculation.

- conditions:

  Vector of columns names indicating the conditions to use for the LCA.
  It can be the object returned from the function select_conditions.

- plot:

  Boolean indicating whether the goodness-of-fit measures should be
  plotted.

- nrep:

  Number of times to estimate the model, using different values of
  probs.start. The default is one. Setting nrep\>1 automates the search
  for the global—rather than just a local—maximum of the log-likelihood
  function. poLCA returns the parameter estimates corresponding to the
  model with the greatest log-likelihood. Default to 50. Reduce to save
  computation time.

- nboot:

  Number of re-samples, default to 10

## Value

A list containing the following elements:

- metrics:

  A dataframe containing the goodness-of-fit measures for the different
  models.

- obj:

  A list of poLCA objects.

- plot:

  ggplot object for the plot if plot=T

- accuracy_matrix:

  A list of matrices containing the mislassification probabilities.

- elapsed_time:

  Numeric indicating the time elapsed.
