# Assign subjects to the their most probable mm pattern according to LCA model

This function assign a subject to a latent mm pattern according to a LCA
model and disease combinations at a specific point in time. The
assignment is done according to the mode of the posterior membership
probability given by the LCA model.

## Usage

``` r
assign_mmlca(...)

assign_LCA(obj, X, returnprob = F)
```

## Arguments

- obj:

  poLCA object

- X:

  matrix with chronic diseases variables (coded as 1:no and 2:yes) to
  use for the calculation.

- returnprob:

  boolean indicating whether posterior probabilities are returned along
  side assignment (default to FALSE).

## Value

numeric vector with LCA class assignment for each row in X or matrix
containing posterior probability classes (see also poLCA.posterior) and
LCA class assignement
