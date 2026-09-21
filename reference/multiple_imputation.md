# Function to obtain imputate multiple imputations of the assigned MM patterns

Function to obtain imputate multiple imputations of the assigned MM
patterns

## Usage

``` r
impute_mmlca(...)

multiple_imputation(obj, data = NULL, nimp = 1)
```

## Arguments

- obj:

  LCA object

- data:

  your dataset

- nimp:

  number of imputated datasets

## Value

list of nimp dataset with assigned MM pattern according to posterior
distribution probabilities
