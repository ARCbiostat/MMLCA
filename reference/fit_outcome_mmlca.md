# Regression model with multimorbidity pattern as covariate taking into account of class-uncertainty

Regression model with multimorbidity pattern as covariate taking into
account of class-uncertainty

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
  class_var = "mm_pattern",
  ref_class = "1",
  conf.level = 0.95,
  exponentiate = F,
  seed = NULL,
  boot = F,
  nboot = NULL,
  nrep = NULL
)
```

## Arguments

- object:

  poLCA object

- formula:

  Two-sided model formula specifying the outcome and covariates.

- data:

  Data frame containing the variables used in the model.

- model:

  Outcome model. Either \`"glm"\` for generalized linear models
  \`"coxph"\` for Cox proportional hazards models.

- family:

  Family object passed to \`glm()\` when \`model = "glm"\`. Defaults to
  \`gaussian()\`.

- method:

  Method used to account for latent class uncertainty. Either \`"pmi"\`
  (posterior multiple imputation) or \`"weighted"\`

- M:

  Number of imputations when \`method = "pmi"\`.

- class_var:

  String containing name of the variable of multimorbidity pattern
  assignments. Defaults to \`"mm_pattern"\`.

- ref_class:

  Reference pattern used in regression models. Defaults to \`"1"\`.

- conf.level:

  Confidence level for confidence intervals. Defaults to \`0.95\`.

- exponentiate:

  Logical. If \`TRUE\`, exponentiates model coefficients and confidence
  intervals (e.g. odds ratios or hazard ratios).

- seed:

  Optional random seed for reproducibility.

- boot:

  Logical. If \`TRUE\`, confidence intervals are obtained using
  bootstrap resampling to take into account of uncertainty from LCA
  model.

- nboot:

  Number of bootstrap samples.

- nrep:

  Number of random starting values for bootstrap LCA runs, if
  applicable.
