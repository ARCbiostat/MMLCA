# Function to calculate the approximate misclassifications matrix

Function to calculate the approximate misclassifications matrix

## Usage

``` r
get_internal_validation_matrix(fit, X, norm = T, n_norm = NULL)
```

## Arguments

- fit:

  object of class poLCA.

- X:

  matrix with chronic diseases variables (coded as 1:no and 2:yes) to
  use for the calculation.

## Value

nc x nc matrix where nc is the number of latent multimorbidity patterns
containing the probabilities of being assigned to a class given the true
class.

## Details

This function calculates the misclassification probabilities as in
https://www.stata.com/meeting/uk22/slides/UK22_Tompsett.pdf
