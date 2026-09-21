# Title

Title

## Usage

``` r
fit_outcome_mmlca(
  object,
  formula,
  data,
  model = c("glm", "coxph"),
  family = gaussian(),
  method = c("pmi", "weighted"),
  M = 50,
  pattern_var = "mm_pattern",
  conf.level = 0.95,
  exponentiate = F,
  seed = NULL,
  boot = F,
  nboot = NULL,
  nrep = NULL
)
```

## Arguments

- nrep:
