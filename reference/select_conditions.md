# Identify chronic conditions above threshold prevalence

Identify chronic conditions above threshold prevalence

## Usage

``` r
select_conditions(X, threshold)
```

## Arguments

- X:

  Matrix with chronic diseases variables (coded as 1:no and 2:yes) to
  use for the calculation.

- threshold:

  Numeric prevalence threshold to use.

## Value

A character vector.

## Examples

``` r
X <- as.matrix(data.frame(dis_1 = rbinom(prob = 0.1, size = 1, n = 100) + 1, dis_2 = rbinom(prob = 0.3, size = 1, n = 100) + 1, dis_3 = rbinom(prob = 0.05, size = 1, n = 100) + 1))
select_conditions(X, 0.02)
#> [1] "dis_2" "dis_3"
```
