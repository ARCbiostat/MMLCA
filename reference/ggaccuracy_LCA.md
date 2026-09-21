# Accuracy of LCA derived Multimorbidity Patterns

This function compares and plot the accuracy of LCA models with
different number of classes for multimorbidity patterns using the
misclassification probability and entropy. The dashed line corresponds
to the assignment accuracy based on the prior.

## Usage

``` r
ggaccuracy(...)

ggaccuracy_LCA(obj)
```

## Arguments

- obj:

  object returned by the function select_number_LCA.

## Value

object of class ggplot.
