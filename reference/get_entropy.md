# Function to get the entropy from LCA object

Function to get the entropy from LCA object

## Usage

``` r
get_entropy(obj, X, ratio = T)
```

## Arguments

- obj:

  fit object of class poLCA.

- X:

  matrix with chronic diseases variables (coded as 1:no and 2:yes) to
  use for the calculation.

- ratio:

  boolen indicating whether the ratio between the prior and the
  posterior entropy should be returned. Default to TRUE.

## Value

numeric
