# Prepare the chronic disease dataset for the LCA

The function help you prepare the dataset as needed for the LCA. Only
variables containing chronic diseases are retained and 0/1 are
substituted by 1/2 as needed by the poLCA package. In addition, the
number of chronic condition for each individual is checked and
optionally individuals with only one chronic conditions are removed
since they should to be used to identify MM patterns.

## Usage

``` r
prepare_data(data, dis_cols, keepmm = TRUE, idvar = "id")
```

## Arguments

- data:

  dataframe.

- dis_cols:

  string to identify chronic disease columns or numeric vector of
  chronic disease columns position .

- keepmm:

  boolean indicating whether subjects having less that 2 chronic
  conditions should be removed from the returned dataset.

- idvar:

  string indicating name of id variable

## Value

data.frame.

## Examples

``` r
data(mmdata)
X <- prepare_data(mmdata, "dis", keepmm = TRUE)
#> Number of disease columns detected: 59
#> 139 rows are removed because corrisponding to subjects having less than 2 diseases.
```
