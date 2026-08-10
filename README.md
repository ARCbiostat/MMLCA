
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MMLCA: an R package to identify multimorbidity patterns

# <img src="man/figures/logo.png" align="right" width="150"/>

<!-- badges: start -->

<!-- badges: end -->

**MMLCA** aims to simplify the identification of multimorbidity patterns
through user-friendly functions. Leveraging the power of Latent Class
Analysis (LCA) as implemented in the `poLCA` package, **MMLCA** provides
an accessible and efficient tool for researchers.

## Installation

You can install the development version of MMLCA from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ARCbiostat/MMLCA")
```

## Overview of the package

## Overview of the package

Main functions are grouped into four analytical steps:

- **Data preparation**
  - `prepare_data()`
  - `select_conditions()`
- **Estimation and model selection**
  - `fit_mmlca()`
  - `fit_mmlca_cv()`
  - `select_mmlca()`
  - `ggaccuracy()`
- **Pattern interpretation**
  - `ggOE()`
  - `ggOEx()`
  - `ggOEx_adaptive()`
  - `ggprev()`
  - `ggprev_spaghetti()`
- **Subsequent analyses**
  - `assign_mmlca()`
  - `impute_mmlca()`

Legacy function names remain supported for backward compatibility.

For the complete index of functions, please visit the
docs/reference/index.html. \## Example

This is an example with all the steps to identify MM patterns using LCA.

### Preparation

Load the package and the data:

``` r
library(MMLCA)
#> Warning: replacing previous import 'magrittr::extract' by 'tidyr::extract' when
#> loading 'MMLCA'
data(mmdata)
```

Prepare the dataset:

``` r
X <- prepare_data(mmdata, dis_cols = "dis", keepmm = T)
#> Number of disease columns detected: 59
#> 139 rows are removed because corrisponding to subjects having less than 2 diseases.
```

The chronic diseases data has 2761 subjects since we removed individuals
with only one chronic condition.

Select the conditions to include in the LCA based on the prevalence:

``` r
threshold <- 0.02 # 2% prevalence
disease_names <- select_conditions(X,
  threshold = threshold
)

disease_names
#>  [1] "dis1"  "dis2"  "dis3"  "dis4"  "dis5"  "dis6"  "dis7"  "dis8"  "dis9" 
#> [10] "dis10" "dis11" "dis12" "dis13" "dis14" "dis15" "dis16" "dis17" "dis18"
#> [19] "dis19" "dis20" "dis21" "dis22" "dis23" "dis24" "dis25" "dis26" "dis27"
#> [28] "dis28" "dis29" "dis30" "dis31" "dis32" "dis33" "dis34" "dis35" "dis36"
#> [37] "dis37" "dis38" "dis39"
```

### Run the LCA

Run the LCA with different number of classes and compare the metrics:

``` r
res <- select_mmlca(
  nclasses = 2:7,
  X = X,
  conditions = disease_names,
  nrep = 10
)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" alt="" width="100%" />

It is important to check that the number of repetition is enough.

### Interpretation of the MM patterns

We now consider the result with 5 classes and try different method to
characterize the patterns in terms of over expressed diseases.

**Method 1:** O/E and Exclusivity:

``` r
OEx_sol4 <- ggOEx(res$obj$`4classes`, table = F)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" alt="" width="100%" />

**Method 2:** O/E and overall prevalence:

``` r
OE_sol4 <- ggOE(res$obj$`4classes`, table = F)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" alt="" width="100%" />

Same method but with 95% CI:

``` r
OEx_sol4 <- ggOE(res$obj$`4classes`, table = F, boot = T)
```

<img src="man/figures/README-unnamed-chunk-8-1.png" alt="" width="100%" />

**Method 3:**

``` r
OExa_sol4 <- ggOEx_adaptive(res$obj$`4classes`, table = F)
```

<img src="man/figures/README-unnamed-chunk-9-1.png" alt="" width="100%" />

**Method 4:**

``` r
prev_sol4 <- ggprev(res$obj$`4classes`)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" alt="" width="100%" />

**Method 5:**

``` r
prev_sol4 <- ggprev_spaghetti(res$obj$`4classes`)
```

<img src="man/figures/README-unnamed-chunk-11-1.png" alt="" width="100%" />

### Run the LCA with cross validation to assess stability

``` r
res_stab <- stability_mmlca(
  nclasses = 2:6,
  X = X,
  nboot=5,
  conditions = disease_names,
  nrep = 10,
  plot=T
)
#> Warning: package 'future' was built under R version 4.5.3
#> Warning: MultisessionFuture ('future_lapply-1') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-1' (0d87a97bbf8e3460dea5247012ca8eef-1); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-1') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-1' (0d87a97bbf8e3460dea5247012ca8eef-1); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: UNRELIABLE VALUE: One of the 'future.apply' iterations
#> ('future_lapply-1') unexpectedly generated random numbers without declaring so.
#> There is a risk that those random numbers are not statistically sound and the
#> overall results might be invalid. To fix this, specify 'future.seed=TRUE'. This
#> ensures that proper, parallel-safe random numbers are produced via a parallel
#> RNG method. To disable this check, use 'future.seed = NULL', or set option
#> 'future.rng.onMisuse' to "ignore". [future 'future_lapply-1'
#> (0d87a97bbf8e3460dea5247012ca8eef-1); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: package 'future' was built under R version 4.5.3
#> Warning: MultisessionFuture ('future_lapply-2') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-2' (0d87a97bbf8e3460dea5247012ca8eef-2); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-2') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-2' (0d87a97bbf8e3460dea5247012ca8eef-2); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: UNRELIABLE VALUE: One of the 'future.apply' iterations
#> ('future_lapply-2') unexpectedly generated random numbers without declaring so.
#> There is a risk that those random numbers are not statistically sound and the
#> overall results might be invalid. To fix this, specify 'future.seed=TRUE'. This
#> ensures that proper, parallel-safe random numbers are produced via a parallel
#> RNG method. To disable this check, use 'future.seed = NULL', or set option
#> 'future.rng.onMisuse' to "ignore". [future 'future_lapply-2'
#> (0d87a97bbf8e3460dea5247012ca8eef-2); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-2') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-2' (0d87a97bbf8e3460dea5247012ca8eef-2); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-2') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-2' (0d87a97bbf8e3460dea5247012ca8eef-2); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: package 'future' was built under R version 4.5.3
#> Warning: MultisessionFuture ('future_lapply-3') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-3' (0d87a97bbf8e3460dea5247012ca8eef-3); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-3') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-3' (0d87a97bbf8e3460dea5247012ca8eef-3); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: UNRELIABLE VALUE: One of the 'future.apply' iterations
#> ('future_lapply-3') unexpectedly generated random numbers without declaring so.
#> There is a risk that those random numbers are not statistically sound and the
#> overall results might be invalid. To fix this, specify 'future.seed=TRUE'. This
#> ensures that proper, parallel-safe random numbers are produced via a parallel
#> RNG method. To disable this check, use 'future.seed = NULL', or set option
#> 'future.rng.onMisuse' to "ignore". [future 'future_lapply-3'
#> (0d87a97bbf8e3460dea5247012ca8eef-3); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-3') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-3' (0d87a97bbf8e3460dea5247012ca8eef-3); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-3') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-3' (0d87a97bbf8e3460dea5247012ca8eef-3); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: package 'future' was built under R version 4.5.3
#> Warning: MultisessionFuture ('future_lapply-4') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-4' (0d87a97bbf8e3460dea5247012ca8eef-4); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-4') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-4' (0d87a97bbf8e3460dea5247012ca8eef-4); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: UNRELIABLE VALUE: One of the 'future.apply' iterations
#> ('future_lapply-4') unexpectedly generated random numbers without declaring so.
#> There is a risk that those random numbers are not statistically sound and the
#> overall results might be invalid. To fix this, specify 'future.seed=TRUE'. This
#> ensures that proper, parallel-safe random numbers are produced via a parallel
#> RNG method. To disable this check, use 'future.seed = NULL', or set option
#> 'future.rng.onMisuse' to "ignore". [future 'future_lapply-4'
#> (0d87a97bbf8e3460dea5247012ca8eef-4); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-4') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-4' (0d87a97bbf8e3460dea5247012ca8eef-4); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-4') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-4' (0d87a97bbf8e3460dea5247012ca8eef-4); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: package 'future' was built under R version 4.5.3
#> Warning: MultisessionFuture ('future_lapply-5') added, removed, or modified
#> devices. A future expression must close any opened devices and must not close
#> devices it did not open. Details: 1 devices differ: index=2, before='NA',
#> after='pdf'. See also help("future.options", package = "future") [future
#> 'future_lapply-5' (0d87a97bbf8e3460dea5247012ca8eef-5); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: MultisessionFuture ('future_lapply-5') opened the default graphics device (1: c("do.call(function(...) {", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "}, args = future.call.arguments)") -> c("(function (...) ", "{", "    \"# future::getGlobalsAndPackages(): FUN() uses '...' internally \"", "    \"# without having an '...' argument. This means '...' is treated\"", "    \"# as a global variable. This may happen when FUN() is an       \"", "    \"# anonymous function.                                          \"", "    \"#                                                              \"", "    \"# If an anonymous function, we will make sure to restore the   \"", "    \"# function environment of FUN() to the calling environment.    \"", 
#> "    \"# We assume FUN() an anonymous function if it lives in the     \"", "    \"# global environment, which is where globals are written.      \"", "    penv <- env <- environment(...future.FUN)", "    repeat {", "        if (identical(env, globalenv()) || identical(env, emptyenv())) ", "            break", "        penv <- env", "        env <- parent.env(env)", "    }", "    if (identical(penv, globalenv())) {", "        environment(...future.FUN) <- environment()", "    }", "    else if (!identical(penv, emptyenv()) && !is.null(penv) && ", 
#> "        !isNamespace(penv)) {", "        parent.env(penv) <- environment()", "    }", "    rm(list = c(\"env\", \"penv\"), inherits = FALSE)", "    {", "        \"# future.apply:::future_xapply(): preserve future option\"", "        ...future.globals.maxSize.org <- getOption(\"future.globals.maxSize\")", "        if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {", "            oopts <- options(future.globals.maxSize = ...future.globals.maxSize)", "            on.exit(options(oopts), add = TRUE)", 
#> "        }", "        {", "            \"# future.apply::future_lapply(): process chunk of elements\"", "            lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "                ...future.X_jj <- ...future.elements_ii[[jj]]", "                {", "                  ...future.FUN(...future.X_jj, ...)", "                }", "            })", "        }", "    }", "})()") -> c("lapply(seq_along(...future.elements_ii), FUN = function(jj) {", "    ...future.X_jj <- ...future.elements_ii[[jj]]", "    {", "        ...future.FUN(...future.X_jj, ...)", "    }", "})") -> ...). This happens for instance if plot() is called without explicitly opening a graphics device before. Using default graphics devices in parallel processing will typically leave behind an 'Rplots.pdf' file on the parallel worker. If the intention is to plot to file, please open a graphics device explicitly (e.g. pdf() or png()) [recommended], or set your preferred `options(device = ...)` [not recommended], then plot, and make sure to close it at the end (i.e. dev.off()). See also help("future.options", package = "future") [future 'future_lapply-5' (0d87a97bbf8e3460dea5247012ca8eef-5); on 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
#> Warning: UNRELIABLE VALUE: One of the 'future.apply' iterations
#> ('future_lapply-5') unexpectedly generated random numbers without declaring so.
#> There is a risk that those random numbers are not statistically sound and the
#> overall results might be invalid. To fix this, specify 'future.seed=TRUE'. This
#> ensures that proper, parallel-safe random numbers are produced via a parallel
#> RNG method. To disable this check, use 'future.seed = NULL', or set option
#> 'future.rng.onMisuse' to "ignore". [future 'future_lapply-5'
#> (0d87a97bbf8e3460dea5247012ca8eef-5); on
#> 0d87a97bbf8e3460dea5247012ca8eef@CATERINA-DFG4<21496>]
```

<img src="man/figures/README-unnamed-chunk-12-1.png" alt="" width="100%" />

### Assignment of subjects into the latent classes

**Warning**: If additional analyses are performed, it is recommended to
take into account for the uncertainty in the classification.

``` r
mm_pattern <- assign_mmlca(res$obj$`4classes`, X)
table(mm_pattern)
#> mm_pattern
#>    1    2    3    4 
#> 1251  902  338  270
```

### Multiple imputation

``` r
mm_patterns_imputed <- impute_mmlca(res$obj$`4classes`, X)
```
