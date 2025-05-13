
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MMLCA

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

For the index of all functions, please visit the [Reference
Documentation](docs/reference/index.html).

## Example

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
X <- prepare_data(mmdata, dis_string = "dis", keepmm = T)
#> 139 subject are removed because having less than 2 chornic conditions.
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

Divide the data in train/test

``` r
set.seed(202112)
train <- sample(1:nrow(X), round(nrow(X) * 0.7))
test <- setdiff(1:nrow(X), train)
```

### Run the LCA

Run the LCA with different number of classes:

``` r
res <- select_number_LCA(
  nclasses = 2:7,
  X = X[train, ],
  conditions = disease_names,
  nrep = 5
)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

    #> Model 1: llik = -21417.98 ... best llik = -21417.98
    #> Model 2: llik = -21417.98 ... best llik = -21417.98
    #> Model 3: llik = -21417.98 ... best llik = -21417.98
    #> Model 4: llik = -21417.98 ... best llik = -21417.98
    #> Model 5: llik = -21417.98 ... best llik = -21417.98
    #> Conditional item response (column) probabilities,
    #>  by outcome variable, for each class (row) 
    #>  
    #> $dis1
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7286 0.2714
    #> class 2:  0.9342 0.0658
    #> 
    #> $dis2
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9440 0.0560
    #> class 2:  0.9177 0.0823
    #> 
    #> $dis3
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7506 0.2494
    #> class 2:  0.9634 0.0366
    #> 
    #> $dis4
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9222 0.0778
    #> class 2:  0.9566 0.0434
    #> 
    #> $dis5
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9038 0.0962
    #> class 2:  0.9810 0.0190
    #> 
    #> $dis6
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9425 0.0575
    #> class 2:  0.9964 0.0036
    #> 
    #> $dis7
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8991 0.1009
    #> class 2:  0.9559 0.0441
    #> 
    #> $dis8
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9303 0.0697
    #> class 2:  0.9861 0.0139
    #> 
    #> $dis9
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9311 0.0689
    #> class 2:  0.9388 0.0612
    #> 
    #> $dis10
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8365 0.1635
    #> class 2:  0.9478 0.0522
    #> 
    #> $dis11
    #>            Pr(1)  Pr(2)
    #> class 1:  0.4629 0.5371
    #> class 2:  0.7045 0.2955
    #> 
    #> $dis12
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6681 0.3319
    #> class 2:  0.9214 0.0786
    #> 
    #> $dis13
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7069 0.2931
    #> class 2:  0.9216 0.0784
    #> 
    #> $dis14
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6697 0.3303
    #> class 2:  0.9804 0.0196
    #> 
    #> $dis15
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8731 0.1269
    #> class 2:  0.9028 0.0972
    #> 
    #> $dis16
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8623 0.1377
    #> class 2:  0.9207 0.0793
    #> 
    #> $dis17
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9245 0.0755
    #> class 2:  0.9312 0.0688
    #> 
    #> $dis18
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7433 0.2567
    #> class 2:  0.3778 0.6222
    #> 
    #> $dis19
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9593 0.0407
    #> class 2:  0.9499 0.0501
    #> 
    #> $dis20
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8964 0.1036
    #> class 2:  0.9587 0.0413
    #> 
    #> $dis21
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6095 0.3905
    #> class 2:  0.9886 0.0114
    #> 
    #> $dis22
    #>            Pr(1)  Pr(2)
    #> class 1:  0.4751 0.5249
    #> class 2:  0.1606 0.8394
    #> 
    #> $dis23
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9261 0.0739
    #> class 2:  0.9752 0.0248
    #> 
    #> $dis24
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6836 0.3164
    #> class 2:  0.8695 0.1305
    #> 
    #> $dis25
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9519 0.0481
    #> class 2:  0.9867 0.0133
    #> 
    #> $dis26
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9553 0.0447
    #> class 2:  0.9715 0.0285
    #> 
    #> $dis27
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9228 0.0772
    #> class 2:  0.8374 0.1626
    #> 
    #> $dis28
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8553 0.1447
    #> class 2:  0.8604 0.1396
    #> 
    #> $dis29
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8485 0.1515
    #> class 2:  0.9476 0.0524
    #> 
    #> $dis30
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8508 0.1492
    #> class 2:  0.9457 0.0543
    #> 
    #> $dis31
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9013 0.0987
    #> class 2:  0.9859 0.0141
    #> 
    #> $dis32
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9188 0.0812
    #> class 2:  0.9574 0.0426
    #> 
    #> $dis33
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9534 0.0466
    #> class 2:  0.9618 0.0382
    #> 
    #> $dis34
    #>           Pr(1) Pr(2)
    #> class 1:  0.973 0.027
    #> class 2:  0.980 0.020
    #> 
    #> $dis35
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9448 0.0552
    #> class 2:  0.9870 0.0130
    #> 
    #> $dis36
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9488 0.0512
    #> class 2:  0.9488 0.0512
    #> 
    #> $dis37
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9816 0.0184
    #> class 2:  0.9714 0.0286
    #> 
    #> $dis38
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8981 0.1019
    #> class 2:  0.8875 0.1125
    #> 
    #> $dis39
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8391 0.1609
    #> class 2:  0.8830 0.1170
    #> 
    #> Estimated class population shares 
    #>  0.3166 0.6834 
    #>  
    #> Predicted class memberships (by modal posterior prob.) 
    #>  0.2871 0.7129 
    #>  
    #> ========================================================= 
    #> Fit for 2 latent classes: 
    #> ========================================================= 
    #> number of observations: 1933 
    #> number of estimated parameters: 79 
    #> residual degrees of freedom: 1854 
    #> maximum log-likelihood: -21417.98 
    #>  
    #> AIC(2): 42993.95
    #> BIC(2): 43433.73
    #> G^2(2): 16104.62 (Likelihood ratio/deviance statistic) 
    #> X^2(2): 6932117495 (Chi-square goodness of fit) 
    #>  
    #> [1] "Completed LCA with 2 ..."
    #> Model 1: llik = -21186.52 ... best llik = -21186.52
    #> Model 2: llik = -21186.52 ... best llik = -21186.52
    #> Model 3: llik = -21395.63 ... best llik = -21186.52
    #> Model 4: llik = -21186.52 ... best llik = -21186.52
    #> Model 5: llik = -21315.36 ... best llik = -21186.52
    #> Conditional item response (column) probabilities,
    #>  by outcome variable, for each class (row) 
    #>  
    #> $dis1
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7401 0.2599
    #> class 2:  0.9245 0.0755
    #> class 3:  0.7093 0.2907
    #> 
    #> $dis2
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9666 0.0334
    #> class 2:  0.9179 0.0821
    #> class 3:  0.9199 0.0801
    #> 
    #> $dis3
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8682 0.1318
    #> class 2:  0.9582 0.0418
    #> class 3:  0.5577 0.4423
    #> 
    #> $dis4
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9271 0.0729
    #> class 2:  0.9549 0.0451
    #> class 3:  0.9153 0.0847
    #> 
    #> $dis5
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8819 0.1181
    #> class 2:  0.9783 0.0217
    #> class 3:  0.9268 0.0732
    #> 
    #> $dis6
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9923 0.0077
    #> class 2:  0.9949 0.0051
    #> class 3:  0.8672 0.1328
    #> 
    #> $dis7
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9356 0.0644
    #> class 2:  0.9542 0.0458
    #> class 3:  0.8427 0.1573
    #> 
    #> $dis8
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9956 0.0044
    #> class 2:  0.9834 0.0166
    #> class 3:  0.8412 0.1588
    #> 
    #> $dis9
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9243 0.0757
    #> class 2:  0.9388 0.0612
    #> class 3:  0.9381 0.0619
    #> 
    #> $dis10
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8233 0.1767
    #> class 2:  0.9454 0.0546
    #> class 3:  0.8352 0.1648
    #> 
    #> $dis11
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6137 0.3863
    #> class 2:  0.6921 0.3079
    #> class 3:  0.2602 0.7398
    #> 
    #> $dis12
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5766 0.4234
    #> class 2:  0.9136 0.0864
    #> class 3:  0.7629 0.2371
    #> 
    #> $dis13
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6152 0.3848
    #> class 2:  0.9155 0.0845
    #> class 3:  0.8035 0.1965
    #> 
    #> $dis14
    #>            Pr(1)  Pr(2)
    #> class 1:  0.3956 0.6044
    #> class 2:  0.9819 0.0181
    #> class 3:  0.9393 0.0607
    #> 
    #> $dis15
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8479 0.1521
    #> class 2:  0.9020 0.0980
    #> class 3:  0.9035 0.0965
    #> 
    #> $dis16
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9592 0.0408
    #> class 2:  0.9182 0.0818
    #> class 3:  0.7280 0.2720
    #> 
    #> $dis17
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9458 0.0542
    #> class 2:  0.9297 0.0703
    #> class 3:  0.9029 0.0971
    #> 
    #> $dis18
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9032 0.0968
    #> class 2:  0.3864 0.6136
    #> class 3:  0.5847 0.4153
    #> 
    #> $dis19
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9615 0.0385
    #> class 2:  0.9499 0.0501
    #> class 3:  0.9595 0.0405
    #> 
    #> $dis20
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8634 0.1366
    #> class 2:  0.9536 0.0464
    #> class 3:  0.9531 0.0469
    #> 
    #> $dis21
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7652 0.2348
    #> class 2:  0.9894 0.0106
    #> class 3:  0.2785 0.7215
    #> 
    #> $dis22
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5647 0.4353
    #> class 2:  0.1692 0.8308
    #> class 3:  0.3968 0.6032
    #> 
    #> $dis23
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9669 0.0331
    #> class 2:  0.9744 0.0256
    #> class 3:  0.8607 0.1393
    #> 
    #> $dis24
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8427 0.1573
    #> class 2:  0.8668 0.1332
    #> class 3:  0.4276 0.5724
    #> 
    #> $dis25
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9557 0.0443
    #> class 2:  0.9860 0.0140
    #> class 3:  0.9406 0.0594
    #> 
    #> $dis26
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9279 0.0721
    #> class 2:  0.9707 0.0293
    #> class 3:  0.9924 0.0076
    #> 
    #> $dis27
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9950 0.0050
    #> class 2:  0.8391 0.1609
    #> class 3:  0.8404 0.1596
    #> 
    #> $dis28
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8862 0.1138
    #> class 2:  0.8596 0.1404
    #> class 3:  0.8164 0.1836
    #> 
    #> $dis29
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8185 0.1815
    #> class 2:  0.9429 0.0571
    #> class 3:  0.8872 0.1128
    #> 
    #> $dis30
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8610 0.1390
    #> class 2:  0.9418 0.0582
    #> class 3:  0.8320 0.1680
    #> 
    #> $dis31
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9455 0.0545
    #> class 2:  0.9845 0.0155
    #> class 3:  0.8242 0.1758
    #> 
    #> $dis32
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9432 0.0568
    #> class 2:  0.9523 0.0477
    #> class 3:  0.9048 0.0952
    #> 
    #> $dis33
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9447 0.0553
    #> class 2:  0.9610 0.0390
    #> class 3:  0.9675 0.0325
    #> 
    #> $dis34
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9576 0.0424
    #> class 2:  0.9798 0.0202
    #> class 3:  0.9927 0.0073
    #> 
    #> $dis35
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8980 0.1020
    #> class 2:  0.9863 0.0137
    #> class 3:  1.0000 0.0000
    #> 
    #> $dis36
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9759 0.0241
    #> class 2:  0.9475 0.0525
    #> class 3:  0.9198 0.0802
    #> 
    #> $dis37
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9823 0.0177
    #> class 2:  0.9719 0.0281
    #> class 3:  0.9809 0.0191
    #> 
    #> $dis38
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9197 0.0803
    #> class 2:  0.8871 0.1129
    #> class 3:  0.8744 0.1256
    #> 
    #> $dis39
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8234 0.1766
    #> class 2:  0.8834 0.1166
    #> class 3:  0.8451 0.1549
    #> 
    #> Estimated class population shares 
    #>  0.1617 0.7194 0.1189 
    #>  
    #> Predicted class memberships (by modal posterior prob.) 
    #>  0.1505 0.7403 0.1092 
    #>  
    #> ========================================================= 
    #> Fit for 3 latent classes: 
    #> ========================================================= 
    #> number of observations: 1933 
    #> number of estimated parameters: 119 
    #> residual degrees of freedom: 1814 
    #> maximum log-likelihood: -21186.52 
    #>  
    #> AIC(3): 42611.04
    #> BIC(3): 43273.5
    #> G^2(3): 15641.71 (Likelihood ratio/deviance statistic) 
    #> X^2(3): 485273639 (Chi-square goodness of fit) 
    #>  
    #> [1] "Completed LCA with 3 ..."
    #> Model 1: llik = -21081.37 ... best llik = -21081.37
    #> Model 2: llik = -21090.47 ... best llik = -21081.37
    #> Model 3: llik = -21081.41 ... best llik = -21081.37
    #> Model 4: llik = -21079.94 ... best llik = -21079.94
    #> Model 5: llik = -21172.11 ... best llik = -21079.94
    #> Conditional item response (column) probabilities,
    #>  by outcome variable, for each class (row) 
    #>  
    #> $dis1
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7104 0.2896
    #> class 2:  0.9554 0.0446
    #> class 3:  0.7708 0.2292
    #> class 4:  0.7626 0.2374
    #> 
    #> $dis2
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9154 0.0846
    #> class 2:  0.8988 0.1012
    #> class 3:  0.9536 0.0464
    #> class 4:  1.0000 0.0000
    #> 
    #> $dis3
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5494 0.4506
    #> class 2:  0.9549 0.0451
    #> class 3:  0.8378 0.1622
    #> class 4:  0.9685 0.0315
    #> 
    #> $dis4
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9149 0.0851
    #> class 2:  0.9554 0.0446
    #> class 3:  0.9141 0.0859
    #> class 4:  0.9538 0.0462
    #> 
    #> $dis5
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9235 0.0765
    #> class 2:  0.9935 0.0065
    #> class 3:  0.8763 0.1237
    #> class 4:  0.9116 0.0884
    #> 
    #> $dis6
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8658 0.1342
    #> class 2:  0.9938 0.0062
    #> class 3:  0.9901 0.0099
    #> class 4:  1.0000 0.0000
    #> 
    #> $dis7
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8384 0.1616
    #> class 2:  0.9477 0.0523
    #> class 3:  0.9234 0.0766
    #> class 4:  0.9792 0.0208
    #> 
    #> $dis8
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8463 0.1537
    #> class 2:  0.9853 0.0147
    #> class 3:  0.9951 0.0049
    #> class 4:  0.9779 0.0221
    #> 
    #> $dis9
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9443 0.0557
    #> class 2:  0.9686 0.0314
    #> class 3:  0.9655 0.0345
    #> class 4:  0.8153 0.1847
    #> 
    #> $dis10
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8395 0.1605
    #> class 2:  0.9570 0.0430
    #> class 3:  0.8210 0.1790
    #> class 4:  0.8766 0.1234
    #> 
    #> $dis11
    #>            Pr(1)  Pr(2)
    #> class 1:  0.2681 0.7319
    #> class 2:  0.7575 0.2425
    #> class 3:  0.7224 0.2776
    #> class 4:  0.4024 0.5976
    #> 
    #> $dis12
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7570 0.2430
    #> class 2:  0.9188 0.0812
    #> class 3:  0.5263 0.4737
    #> class 4:  0.8421 0.1579
    #> 
    #> $dis13
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8008 0.1992
    #> class 2:  0.9562 0.0438
    #> class 3:  0.6002 0.3998
    #> class 4:  0.7218 0.2782
    #> 
    #> $dis14
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9352 0.0648
    #> class 2:  0.9867 0.0133
    #> class 3:  0.2502 0.7498
    #> class 4:  0.9007 0.0993
    #> 
    #> $dis15
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8983 0.1017
    #> class 2:  0.8945 0.1055
    #> class 3:  0.8274 0.1726
    #> class 4:  0.9262 0.0738
    #> 
    #> $dis16
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7338 0.2662
    #> class 2:  0.9135 0.0865
    #> class 3:  0.9629 0.0371
    #> class 4:  0.9379 0.0621
    #> 
    #> $dis17
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8976 0.1024
    #> class 2:  0.9231 0.0769
    #> class 3:  0.9358 0.0642
    #> class 4:  0.9634 0.0366
    #> 
    #> $dis18
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5900 0.4100
    #> class 2:  0.3563 0.6437
    #> class 3:  0.9551 0.0449
    #> class 4:  0.5809 0.4191
    #> 
    #> $dis19
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9580 0.0420
    #> class 2:  0.9431 0.0569
    #> class 3:  0.9502 0.0498
    #> class 4:  0.9814 0.0186
    #> 
    #> $dis20
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9616 0.0384
    #> class 2:  0.9857 0.0143
    #> class 3:  0.9257 0.0743
    #> class 4:  0.7891 0.2109
    #> 
    #> $dis21
    #>            Pr(1)  Pr(2)
    #> class 1:  0.2776 0.7224
    #> class 2:  0.9892 0.0108
    #> class 3:  0.7222 0.2778
    #> class 4:  0.9579 0.0421
    #> 
    #> $dis22
    #>            Pr(1)  Pr(2)
    #> class 1:  0.4071 0.5929
    #> class 2:  0.1682 0.8318
    #> class 3:  0.6388 0.3612
    #> class 4:  0.2263 0.7737
    #> 
    #> $dis23
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8605 0.1395
    #> class 2:  0.9729 0.0271
    #> class 3:  0.9639 0.0361
    #> class 4:  0.9790 0.0210
    #> 
    #> $dis24
    #>            Pr(1)  Pr(2)
    #> class 1:  0.4128 0.5872
    #> class 2:  0.8597 0.1403
    #> class 3:  0.8253 0.1747
    #> class 4:  0.9025 0.0975
    #> 
    #> $dis25
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9370 0.0630
    #> class 2:  0.9831 0.0169
    #> class 3:  0.9437 0.0563
    #> class 4:  0.9964 0.0036
    #> 
    #> $dis26
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9902 0.0098
    #> class 2:  0.9632 0.0368
    #> class 3:  0.9003 0.0997
    #> class 4:  1.0000 0.0000
    #> 
    #> $dis27
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8395 0.1605
    #> class 2:  0.8209 0.1791
    #> class 3:  1.0000 0.0000
    #> class 4:  0.9338 0.0662
    #> 
    #> $dis28
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8172 0.1828
    #> class 2:  0.8640 0.1360
    #> class 3:  0.9048 0.0952
    #> class 4:  0.8417 0.1583
    #> 
    #> $dis29
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8899 0.1101
    #> class 2:  0.9544 0.0456
    #> class 3:  0.8295 0.1705
    #> class 4:  0.8669 0.1331
    #> 
    #> $dis30
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8299 0.1701
    #> class 2:  0.9426 0.0574
    #> class 3:  0.8578 0.1422
    #> class 4:  0.9214 0.0786
    #> 
    #> $dis31
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8257 0.1743
    #> class 2:  0.9843 0.0157
    #> class 3:  0.9382 0.0618
    #> class 4:  0.9785 0.0215
    #> 
    #> $dis32
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9132 0.0868
    #> class 2:  0.9683 0.0317
    #> class 3:  0.9787 0.0213
    #> class 4:  0.8747 0.1253
    #> 
    #> $dis33
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9663 0.0337
    #> class 2:  0.9648 0.0352
    #> class 3:  0.9348 0.0652
    #> class 4:  0.9517 0.0483
    #> 
    #> $dis34
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9931 0.0069
    #> class 2:  0.9833 0.0167
    #> class 3:  0.9560 0.0440
    #> class 4:  0.9639 0.0361
    #> 
    #> $dis35
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9868 0.0132
    #> class 3:  0.8687 0.1313
    #> class 4:  0.9786 0.0214
    #> 
    #> $dis36
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9248 0.0752
    #> class 2:  0.9516 0.0484
    #> class 3:  0.9916 0.0084
    #> class 4:  0.9301 0.0699
    #> 
    #> $dis37
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9794 0.0206
    #> class 2:  0.9666 0.0334
    #> class 3:  0.9884 0.0116
    #> class 4:  0.9881 0.0119
    #> 
    #> $dis38
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8809 0.1191
    #> class 2:  0.9070 0.0930
    #> class 3:  0.9304 0.0696
    #> class 4:  0.8244 0.1756
    #> 
    #> $dis39
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8407 0.1593
    #> class 2:  0.8760 0.1240
    #> class 3:  0.8033 0.1967
    #> class 4:  0.9047 0.0953
    #> 
    #> Estimated class population shares 
    #>  0.1193 0.5799 0.1117 0.1892 
    #>  
    #> Predicted class memberships (by modal posterior prob.) 
    #>  0.1128 0.6218 0.1081 0.1573 
    #>  
    #> ========================================================= 
    #> Fit for 4 latent classes: 
    #> ========================================================= 
    #> number of observations: 1933 
    #> number of estimated parameters: 159 
    #> residual degrees of freedom: 1774 
    #> maximum log-likelihood: -21079.94 
    #>  
    #> AIC(4): 42477.87
    #> BIC(4): 43363
    #> G^2(4): 15428.54 (Likelihood ratio/deviance statistic) 
    #> X^2(4): 476743115 (Chi-square goodness of fit) 
    #>  
    #> [1] "Completed LCA with 4 ..."
    #> Model 1: llik = -21032.08 ... best llik = -21032.08
    #> Model 2: llik = -21031.92 ... best llik = -21031.92
    #> Model 3: llik = -21048.33 ... best llik = -21031.92
    #> Model 4: llik = -21049.21 ... best llik = -21031.92
    #> Model 5: llik = -20963.64 ... best llik = -20963.64
    #> Conditional item response (column) probabilities,
    #>  by outcome variable, for each class (row) 
    #>  
    #> $dis1
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7792 0.2208
    #> class 2:  0.9015 0.0985
    #> class 3:  0.9800 0.0200
    #> class 4:  0.7122 0.2878
    #> class 5:  0.7754 0.2246
    #> 
    #> $dis2
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9546 0.0454
    #> class 2:  0.7802 0.2198
    #> class 3:  0.9493 0.0507
    #> class 4:  0.9155 0.0845
    #> class 5:  1.0000 0.0000
    #> 
    #> $dis3
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8351 0.1649
    #> class 2:  0.9792 0.0208
    #> class 3:  0.9457 0.0543
    #> class 4:  0.5499 0.4501
    #> class 5:  0.9626 0.0374
    #> 
    #> $dis4
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9131 0.0869
    #> class 2:  0.9382 0.0618
    #> class 3:  0.9641 0.0359
    #> class 4:  0.9122 0.0878
    #> class 5:  0.9539 0.0461
    #> 
    #> $dis5
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8686 0.1314
    #> class 2:  0.9910 0.0090
    #> class 3:  0.9948 0.0052
    #> class 4:  0.9245 0.0755
    #> class 5:  0.9195 0.0805
    #> 
    #> $dis6
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9932 0.0068
    #> class 2:  0.9838 0.0162
    #> class 3:  0.9972 0.0028
    #> class 4:  0.8676 0.1324
    #> class 5:  1.0000 0.0000
    #> 
    #> $dis7
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9266 0.0734
    #> class 2:  0.8950 0.1050
    #> class 3:  0.9685 0.0315
    #> class 4:  0.8401 0.1599
    #> class 5:  0.9805 0.0195
    #> 
    #> $dis8
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9949 0.0051
    #> class 2:  0.9871 0.0129
    #> class 3:  0.9846 0.0154
    #> class 4:  0.8497 0.1503
    #> class 5:  0.9783 0.0217
    #> 
    #> $dis9
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9652 0.0348
    #> class 2:  0.9561 0.0439
    #> class 3:  0.9775 0.0225
    #> class 4:  0.9443 0.0557
    #> class 5:  0.8271 0.1729
    #> 
    #> $dis10
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8081 0.1919
    #> class 2:  0.9948 0.0052
    #> class 3:  0.9412 0.0588
    #> class 4:  0.8365 0.1635
    #> class 5:  0.8853 0.1147
    #> 
    #> $dis11
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7261 0.2739
    #> class 2:  0.7232 0.2768
    #> class 3:  0.7809 0.2191
    #> class 4:  0.2706 0.7294
    #> class 5:  0.4281 0.5719
    #> 
    #> $dis12
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5260 0.4740
    #> class 2:  0.8037 0.1963
    #> class 3:  0.9684 0.0316
    #> class 4:  0.7586 0.2414
    #> class 5:  0.8446 0.1554
    #> 
    #> $dis13
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5904 0.4096
    #> class 2:  0.9468 0.0532
    #> class 3:  0.9639 0.0361
    #> class 4:  0.8001 0.1999
    #> class 5:  0.7348 0.2652
    #> 
    #> $dis14
    #>            Pr(1)  Pr(2)
    #> class 1:  0.1832 0.8168
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9840 0.0160
    #> class 4:  0.9349 0.0651
    #> class 5:  0.9086 0.0914
    #> 
    #> $dis15
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8372 0.1628
    #> class 2:  0.7570 0.2430
    #> class 3:  0.9498 0.0502
    #> class 4:  0.9009 0.0991
    #> class 5:  0.9309 0.0691
    #> 
    #> $dis16
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9598 0.0402
    #> class 2:  0.9570 0.0430
    #> class 3:  0.8938 0.1062
    #> class 4:  0.7338 0.2662
    #> class 5:  0.9385 0.0615
    #> 
    #> $dis17
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9406 0.0594
    #> class 2:  0.8335 0.1665
    #> class 3:  0.9578 0.0422
    #> class 4:  0.9008 0.0992
    #> class 5:  0.9692 0.0308
    #> 
    #> $dis18
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9519 0.0481
    #> class 2:  0.4940 0.5060
    #> class 3:  0.2962 0.7038
    #> class 4:  0.5830 0.4170
    #> class 5:  0.5739 0.4261
    #> 
    #> $dis19
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9635 0.0365
    #> class 2:  0.8467 0.1533
    #> class 3:  0.9834 0.0166
    #> class 4:  0.9555 0.0445
    #> class 5:  0.9817 0.0183
    #> 
    #> $dis20
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9233 0.0767
    #> class 2:  0.9782 0.0218
    #> class 3:  0.9935 0.0065
    #> class 4:  0.9635 0.0365
    #> class 5:  0.8015 0.1985
    #> 
    #> $dis21
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7058 0.2942
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9846 0.0154
    #> class 4:  0.2807 0.7193
    #> class 5:  0.9620 0.0380
    #> 
    #> $dis22
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6315 0.3685
    #> class 2:  0.3519 0.6481
    #> class 3:  0.0952 0.9048
    #> class 4:  0.4042 0.5958
    #> class 5:  0.2166 0.7834
    #> 
    #> $dis23
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9757 0.0243
    #> class 2:  0.9497 0.0503
    #> class 3:  0.9814 0.0186
    #> class 4:  0.8592 0.1408
    #> class 5:  0.9784 0.0216
    #> 
    #> $dis24
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8181 0.1819
    #> class 2:  0.9527 0.0473
    #> class 3:  0.8253 0.1747
    #> class 4:  0.4097 0.5903
    #> class 5:  0.8881 0.1119
    #> 
    #> $dis25
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9524 0.0476
    #> class 2:  0.9555 0.0445
    #> class 3:  0.9918 0.0082
    #> class 4:  0.9378 0.0622
    #> class 5:  0.9966 0.0034
    #> 
    #> $dis26
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9081 0.0919
    #> class 2:  0.8943 0.1057
    #> class 3:  0.9895 0.0105
    #> class 4:  0.9915 0.0085
    #> class 5:  1.0000 0.0000
    #> 
    #> $dis27
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9095 0.0905
    #> class 3:  0.7815 0.2185
    #> class 4:  0.8430 0.1570
    #> class 5:  0.9215 0.0785
    #> 
    #> $dis28
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9188 0.0812
    #> class 2:  0.7728 0.2272
    #> class 3:  0.9081 0.0919
    #> class 4:  0.8162 0.1838
    #> class 5:  0.8380 0.1620
    #> 
    #> $dis29
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8355 0.1645
    #> class 2:  0.8657 0.1343
    #> class 3:  0.9959 0.0041
    #> class 4:  0.8925 0.1075
    #> class 5:  0.8685 0.1315
    #> 
    #> $dis30
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8532 0.1468
    #> class 2:  0.9192 0.0808
    #> class 3:  0.9537 0.0463
    #> class 4:  0.8337 0.1663
    #> class 5:  0.9213 0.0787
    #> 
    #> $dis31
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9386 0.0614
    #> class 2:  0.9636 0.0364
    #> class 3:  0.9933 0.0067
    #> class 4:  0.8288 0.1712
    #> class 5:  0.9780 0.0220
    #> 
    #> $dis32
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9866 0.0134
    #> class 2:  0.9468 0.0532
    #> class 3:  0.9788 0.0212
    #> class 4:  0.9146 0.0854
    #> class 5:  0.8806 0.1194
    #> 
    #> $dis33
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9415 0.0585
    #> class 2:  0.9469 0.0531
    #> class 3:  0.9722 0.0278
    #> class 4:  0.9656 0.0344
    #> class 5:  0.9510 0.0490
    #> 
    #> $dis34
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9610 0.0390
    #> class 2:  0.9569 0.0431
    #> class 3:  0.9925 0.0075
    #> class 4:  0.9928 0.0072
    #> class 5:  0.9685 0.0315
    #> 
    #> $dis35
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8580 0.1420
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9819 0.0181
    #> class 4:  1.0000 0.0000
    #> class 5:  0.9775 0.0225
    #> 
    #> $dis36
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9895 0.0105
    #> class 2:  0.9738 0.0262
    #> class 3:  0.9402 0.0598
    #> class 4:  0.9243 0.0757
    #> class 5:  0.9371 0.0629
    #> 
    #> $dis37
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9903 0.0097
    #> class 2:  0.9370 0.0630
    #> class 3:  0.9781 0.0219
    #> class 4:  0.9807 0.0193
    #> class 5:  0.9894 0.0106
    #> 
    #> $dis38
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9324 0.0676
    #> class 2:  0.9140 0.0860
    #> class 3:  0.9048 0.0952
    #> class 4:  0.8797 0.1203
    #> class 5:  0.8323 0.1677
    #> 
    #> $dis39
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8014 0.1986
    #> class 2:  0.8032 0.1968
    #> class 3:  0.9059 0.0941
    #> class 4:  0.8414 0.1586
    #> class 5:  0.9076 0.0924
    #> 
    #> Estimated class population shares 
    #>  0.1035 0.1805 0.3823 0.1209 0.2128 
    #>  
    #> Predicted class memberships (by modal posterior prob.) 
    #>  0.1004 0.1578 0.4247 0.1164 0.2007 
    #>  
    #> ========================================================= 
    #> Fit for 5 latent classes: 
    #> ========================================================= 
    #> number of observations: 1933 
    #> number of estimated parameters: 199 
    #> residual degrees of freedom: 1734 
    #> maximum log-likelihood: -20963.64 
    #>  
    #> AIC(5): 42325.28
    #> BIC(5): 43433.08
    #> G^2(5): 15195.95 (Likelihood ratio/deviance statistic) 
    #> X^2(5): 354434959 (Chi-square goodness of fit) 
    #>  
    #> [1] "Completed LCA with 5 ..."
    #> Model 1: llik = -21033.56 ... best llik = -21033.56
    #> Model 2: llik = -20913.11 ... best llik = -20913.11
    #> Model 3: llik = -20923.49 ... best llik = -20913.11
    #> Model 4: llik = -20934.33 ... best llik = -20913.11
    #> Model 5: llik = -20952.91 ... best llik = -20913.11
    #> Conditional item response (column) probabilities,
    #>  by outcome variable, for each class (row) 
    #>  
    #> $dis1
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5690 0.4310
    #> class 2:  0.7798 0.2202
    #> class 3:  0.9027 0.0973
    #> class 4:  0.9824 0.0176
    #> class 5:  0.7596 0.2404
    #> class 6:  0.7935 0.2065
    #> 
    #> $dis2
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8573 0.1427
    #> class 2:  0.9556 0.0444
    #> class 3:  0.7707 0.2293
    #> class 4:  0.9485 0.0515
    #> class 5:  0.9443 0.0557
    #> class 6:  1.0000 0.0000
    #> 
    #> $dis3
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6467 0.3533
    #> class 2:  0.8363 0.1637
    #> class 3:  0.9783 0.0217
    #> class 4:  0.9447 0.0553
    #> class 5:  0.5458 0.4542
    #> class 6:  0.9667 0.0333
    #> 
    #> $dis4
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9134 0.0866
    #> class 3:  0.9395 0.0605
    #> class 4:  0.9653 0.0347
    #> class 5:  0.8856 0.1144
    #> class 6:  0.9499 0.0501
    #> 
    #> $dis5
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8021 0.1979
    #> class 2:  0.8724 0.1276
    #> class 3:  0.9893 0.0107
    #> class 4:  0.9952 0.0048
    #> class 5:  0.9578 0.0422
    #> class 6:  0.9318 0.0682
    #> 
    #> $dis6
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9934 0.0066
    #> class 3:  0.9822 0.0178
    #> class 4:  0.9972 0.0028
    #> class 5:  0.8303 0.1697
    #> class 6:  1.0000 0.0000
    #> 
    #> $dis7
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9653 0.0347
    #> class 2:  0.9267 0.0733
    #> class 3:  0.8940 0.1060
    #> class 4:  0.9684 0.0316
    #> class 5:  0.8077 0.1923
    #> class 6:  0.9776 0.0224
    #> 
    #> $dis8
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9949 0.0051
    #> class 3:  0.9880 0.0120
    #> class 4:  0.9846 0.0154
    #> class 5:  0.8045 0.1955
    #> class 6:  0.9777 0.0223
    #> 
    #> $dis9
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9298 0.0702
    #> class 2:  0.9575 0.0425
    #> class 3:  0.9606 0.0394
    #> class 4:  0.9805 0.0195
    #> class 5:  0.9463 0.0537
    #> class 6:  0.8321 0.1679
    #> 
    #> $dis10
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7824 0.2176
    #> class 2:  0.8144 0.1856
    #> class 3:  0.9957 0.0043
    #> class 4:  0.9412 0.0588
    #> class 5:  0.8392 0.1608
    #> class 6:  0.8986 0.1014
    #> 
    #> $dis11
    #>            Pr(1)  Pr(2)
    #> class 1:  0.1199 0.8801
    #> class 2:  0.7283 0.2717
    #> class 3:  0.7246 0.2754
    #> class 4:  0.7876 0.2124
    #> class 5:  0.3211 0.6789
    #> class 6:  0.4542 0.5458
    #> 
    #> $dis12
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6790 0.3210
    #> class 2:  0.5338 0.4662
    #> class 3:  0.8043 0.1957
    #> class 4:  0.9697 0.0303
    #> class 5:  0.7920 0.2080
    #> class 6:  0.8512 0.1488
    #> 
    #> $dis13
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8546 0.1454
    #> class 2:  0.5902 0.4098
    #> class 3:  0.9500 0.0500
    #> class 4:  0.9668 0.0332
    #> class 5:  0.7728 0.2272
    #> class 6:  0.7507 0.2493
    #> 
    #> $dis14
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9103 0.0897
    #> class 2:  0.1876 0.8124
    #> class 3:  1.0000 0.0000
    #> class 4:  0.9848 0.0152
    #> class 5:  0.9404 0.0596
    #> class 6:  0.9201 0.0799
    #> 
    #> $dis15
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.8319 0.1681
    #> class 3:  0.7548 0.2452
    #> class 4:  0.9502 0.0498
    #> class 5:  0.8745 0.1255
    #> class 6:  0.9287 0.0713
    #> 
    #> $dis16
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8267 0.1733
    #> class 2:  0.9602 0.0398
    #> class 3:  0.9573 0.0427
    #> class 4:  0.8926 0.1074
    #> class 5:  0.7111 0.2889
    #> class 6:  0.9396 0.0604
    #> 
    #> $dis17
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9410 0.0590
    #> class 3:  0.8333 0.1667
    #> class 4:  0.9589 0.0411
    #> class 5:  0.8684 0.1316
    #> class 6:  0.9637 0.0363
    #> 
    #> $dis18
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6078 0.3922
    #> class 2:  0.9407 0.0593
    #> class 3:  0.4925 0.5075
    #> class 4:  0.2901 0.7099
    #> class 5:  0.5845 0.4155
    #> class 6:  0.5601 0.4399
    #> 
    #> $dis19
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9635 0.0365
    #> class 3:  0.8471 0.1529
    #> class 4:  0.9842 0.0158
    #> class 5:  0.9382 0.0618
    #> class 6:  0.9780 0.0220
    #> 
    #> $dis20
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8106 0.1894
    #> class 2:  0.9208 0.0792
    #> class 3:  0.9794 0.0206
    #> class 4:  0.9959 0.0041
    #> class 5:  0.9917 0.0083
    #> class 6:  0.8213 0.1787
    #> 
    #> $dis21
    #>            Pr(1)  Pr(2)
    #> class 1:  0.1542 0.8458
    #> class 2:  0.7091 0.2909
    #> class 3:  1.0000 0.0000
    #> class 4:  0.9837 0.0163
    #> class 5:  0.3125 0.6875
    #> class 6:  1.0000 0.0000
    #> 
    #> $dis22
    #>            Pr(1)  Pr(2)
    #> class 1:  0.1335 0.8665
    #> class 2:  0.6352 0.3648
    #> class 3:  0.3516 0.6484
    #> class 4:  0.0941 0.9059
    #> class 5:  0.4818 0.5182
    #> class 6:  0.2119 0.7881
    #> 
    #> $dis23
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9522 0.0478
    #> class 2:  0.9753 0.0247
    #> class 3:  0.9496 0.0504
    #> class 4:  0.9822 0.0178
    #> class 5:  0.8362 0.1638
    #> class 6:  0.9760 0.0240
    #> 
    #> $dis24
    #>            Pr(1)  Pr(2)
    #> class 1:  0.6967 0.3033
    #> class 2:  0.8242 0.1758
    #> class 3:  0.9577 0.0423
    #> class 4:  0.8260 0.1740
    #> class 5:  0.3329 0.6671
    #> class 6:  0.8821 0.1179
    #> 
    #> $dis25
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9524 0.0476
    #> class 3:  0.9553 0.0447
    #> class 4:  0.9916 0.0084
    #> class 5:  0.9187 0.0813
    #> class 6:  0.9965 0.0035
    #> 
    #> $dis26
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9711 0.0289
    #> class 2:  0.9092 0.0908
    #> class 3:  0.8895 0.1105
    #> class 4:  0.9899 0.0101
    #> class 5:  1.0000 0.0000
    #> class 6:  1.0000 0.0000
    #> 
    #> $dis27
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8826 0.1174
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9072 0.0928
    #> class 4:  0.7782 0.2218
    #> class 5:  0.8356 0.1644
    #> class 6:  0.9175 0.0825
    #> 
    #> $dis28
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7521 0.2479
    #> class 2:  0.9238 0.0762
    #> class 3:  0.7701 0.2299
    #> class 4:  0.9106 0.0894
    #> class 5:  0.8393 0.1607
    #> class 6:  0.8379 0.1621
    #> 
    #> $dis29
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8405 0.1595
    #> class 2:  0.8345 0.1655
    #> class 3:  0.8659 0.1341
    #> class 4:  0.9989 0.0011
    #> class 5:  0.9082 0.0918
    #> class 6:  0.8741 0.1259
    #> 
    #> $dis30
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8642 0.1358
    #> class 2:  0.8575 0.1425
    #> class 3:  0.9188 0.0812
    #> class 4:  0.9549 0.0451
    #> class 5:  0.8253 0.1747
    #> class 6:  0.9225 0.0775
    #> 
    #> $dis31
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8860 0.1140
    #> class 2:  0.9386 0.0614
    #> class 3:  0.9631 0.0369
    #> class 4:  0.9936 0.0064
    #> class 5:  0.8196 0.1804
    #> class 6:  0.9794 0.0206
    #> 
    #> $dis32
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9870 0.0130
    #> class 3:  0.9498 0.0502
    #> class 4:  0.9813 0.0187
    #> class 5:  0.8830 0.1170
    #> class 6:  0.8798 0.1202
    #> 
    #> $dis33
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9415 0.0585
    #> class 3:  0.9466 0.0534
    #> class 4:  0.9733 0.0267
    #> class 5:  0.9574 0.0426
    #> class 6:  0.9482 0.0518
    #> 
    #> $dis34
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9607 0.0393
    #> class 3:  0.9581 0.0419
    #> class 4:  0.9917 0.0083
    #> class 5:  0.9904 0.0096
    #> class 6:  0.9694 0.0306
    #> 
    #> $dis35
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9624 0.0376
    #> class 2:  0.8597 0.1403
    #> class 3:  1.0000 0.0000
    #> class 4:  0.9801 0.0199
    #> class 5:  1.0000 0.0000
    #> class 6:  0.9868 0.0132
    #> 
    #> $dis36
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8564 0.1436
    #> class 2:  0.9882 0.0118
    #> class 3:  0.9726 0.0274
    #> class 4:  0.9395 0.0605
    #> class 5:  0.9476 0.0524
    #> class 6:  0.9421 0.0579
    #> 
    #> $dis37
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9421 0.0579
    #> class 2:  0.9883 0.0117
    #> class 3:  0.9333 0.0667
    #> class 4:  0.9767 0.0233
    #> class 5:  0.9884 0.0116
    #> class 6:  0.9967 0.0033
    #> 
    #> $dis38
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7328 0.2672
    #> class 2:  0.9339 0.0661
    #> class 3:  0.9129 0.0871
    #> class 4:  0.9073 0.0927
    #> class 5:  0.9246 0.0754
    #> class 6:  0.8377 0.1623
    #> 
    #> $dis39
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8425 0.1575
    #> class 2:  0.8040 0.1960
    #> class 3:  0.7996 0.2004
    #> class 4:  0.9057 0.0943
    #> class 5:  0.8432 0.1568
    #> class 6:  0.9093 0.0907
    #> 
    #> Estimated class population shares 
    #>  0.036 0.1055 0.1749 0.3663 0.0935 0.2238 
    #>  
    #> Predicted class memberships (by modal posterior prob.) 
    #>  0.0336 0.1024 0.1495 0.4128 0.0864 0.2152 
    #>  
    #> ========================================================= 
    #> Fit for 6 latent classes: 
    #> ========================================================= 
    #> number of observations: 1933 
    #> number of estimated parameters: 239 
    #> residual degrees of freedom: 1694 
    #> maximum log-likelihood: -20913.11 
    #>  
    #> AIC(6): 42304.21
    #> BIC(6): 43634.68
    #> G^2(6): 15094.88 (Likelihood ratio/deviance statistic) 
    #> X^2(6): 407774439 (Chi-square goodness of fit) 
    #>  
    #> [1] "Completed LCA with 6 ..."
    #> Model 1: llik = -20897.88 ... best llik = -20897.88
    #> Model 2: llik = -20979.91 ... best llik = -20897.88
    #> Model 3: llik = -20881.65 ... best llik = -20881.65
    #> Model 4: llik = -20888.06 ... best llik = -20881.65
    #> Model 5: llik = -20973.05 ... best llik = -20881.65
    #> Conditional item response (column) probabilities,
    #>  by outcome variable, for each class (row) 
    #>  
    #> $dis1
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7589 0.2411
    #> class 2:  0.9063 0.0937
    #> class 3:  0.9796 0.0204
    #> class 4:  0.7621 0.2379
    #> class 5:  0.6426 0.3574
    #> class 6:  0.6815 0.3185
    #> class 7:  0.7922 0.2078
    #> 
    #> $dis2
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9051 0.0949
    #> class 2:  0.7747 0.2253
    #> class 3:  0.9475 0.0525
    #> class 4:  0.9571 0.0429
    #> class 5:  0.9527 0.0473
    #> class 6:  0.9336 0.0664
    #> class 7:  1.0000 0.0000
    #> 
    #> $dis3
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5533 0.4467
    #> class 2:  0.9747 0.0253
    #> class 3:  0.9449 0.0551
    #> class 4:  0.8350 0.1650
    #> class 5:  0.7378 0.2622
    #> class 6:  0.5480 0.4520
    #> class 7:  0.9653 0.0347
    #> 
    #> $dis4
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9759 0.0241
    #> class 2:  0.9387 0.0613
    #> class 3:  0.9654 0.0346
    #> class 4:  0.9143 0.0857
    #> class 5:  0.9181 0.0819
    #> class 6:  0.8281 0.1719
    #> class 7:  0.9506 0.0494
    #> 
    #> $dis5
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8691 0.1309
    #> class 2:  0.9915 0.0085
    #> class 3:  0.9940 0.0060
    #> class 4:  0.8653 0.1347
    #> class 5:  1.0000 0.0000
    #> class 6:  1.0000 0.0000
    #> class 7:  0.9274 0.0726
    #> 
    #> $dis6
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8930 0.1070
    #> class 2:  0.9819 0.0181
    #> class 3:  0.9973 0.0027
    #> class 4:  0.9930 0.0070
    #> class 5:  1.0000 0.0000
    #> class 6:  0.8114 0.1886
    #> class 7:  1.0000 0.0000
    #> 
    #> $dis7
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8757 0.1243
    #> class 2:  0.8941 0.1059
    #> class 3:  0.9682 0.0318
    #> class 4:  0.9263 0.0737
    #> class 5:  1.0000 0.0000
    #> class 6:  0.7736 0.2264
    #> class 7:  0.9782 0.0218
    #> 
    #> $dis8
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8393 0.1607
    #> class 2:  0.9887 0.0113
    #> class 3:  0.9843 0.0157
    #> class 4:  0.9951 0.0049
    #> class 5:  1.0000 0.0000
    #> class 6:  0.8280 0.1720
    #> class 7:  0.9788 0.0212
    #> 
    #> $dis9
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9603 0.0397
    #> class 3:  0.9800 0.0200
    #> class 4:  0.9602 0.0398
    #> class 5:  0.7597 0.2403
    #> class 6:  0.8831 0.1169
    #> class 7:  0.8326 0.1674
    #> 
    #> $dis10
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8800 0.1200
    #> class 2:  0.9962 0.0038
    #> class 3:  0.9404 0.0596
    #> class 4:  0.8088 0.1912
    #> class 5:  0.6915 0.3085
    #> class 6:  0.7892 0.2108
    #> class 7:  0.8973 0.1027
    #> 
    #> $dis11
    #>            Pr(1)  Pr(2)
    #> class 1:  0.2835 0.7165
    #> class 2:  0.7248 0.2752
    #> class 3:  0.7847 0.2153
    #> class 4:  0.7151 0.2849
    #> class 5:  0.0000 1.0000
    #> class 6:  0.2759 0.7241
    #> class 7:  0.4529 0.5471
    #> 
    #> $dis12
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7327 0.2673
    #> class 2:  0.8045 0.1955
    #> class 3:  0.9696 0.0304
    #> class 4:  0.5386 0.4614
    #> class 5:  0.7552 0.2448
    #> class 6:  0.8224 0.1776
    #> class 7:  0.8504 0.1496
    #> 
    #> $dis13
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8296 0.1704
    #> class 2:  0.9487 0.0513
    #> class 3:  0.9669 0.0331
    #> class 4:  0.5960 0.4040
    #> class 5:  0.7226 0.2774
    #> class 6:  0.7614 0.2386
    #> class 7:  0.7507 0.2493
    #> 
    #> $dis14
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9623 0.0377
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9839 0.0161
    #> class 4:  0.2069 0.7931
    #> class 5:  1.0000 0.0000
    #> class 6:  0.9121 0.0879
    #> class 7:  0.9214 0.0786
    #> 
    #> $dis15
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8633 0.1367
    #> class 2:  0.7523 0.2477
    #> class 3:  0.9519 0.0481
    #> class 4:  0.8374 0.1626
    #> class 5:  1.0000 0.0000
    #> class 6:  0.9458 0.0542
    #> class 7:  0.9312 0.0688
    #> 
    #> $dis16
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8197 0.1803
    #> class 2:  0.9551 0.0449
    #> class 3:  0.8909 0.1091
    #> class 4:  0.9607 0.0393
    #> class 5:  0.5886 0.4114
    #> class 6:  0.6414 0.3586
    #> class 7:  0.9432 0.0568
    #> 
    #> $dis17
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9315 0.0685
    #> class 2:  0.8341 0.1659
    #> class 3:  0.9593 0.0407
    #> class 4:  0.9404 0.0596
    #> class 5:  1.0000 0.0000
    #> class 6:  0.8423 0.1577
    #> class 7:  0.9633 0.0367
    #> 
    #> $dis18
    #>            Pr(1)  Pr(2)
    #> class 1:  0.5739 0.4261
    #> class 2:  0.4935 0.5065
    #> class 3:  0.2918 0.7082
    #> class 4:  0.9330 0.0670
    #> class 5:  0.8169 0.1831
    #> class 6:  0.5479 0.4521
    #> class 7:  0.5565 0.4435
    #> 
    #> $dis19
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.8450 0.1550
    #> class 3:  0.9856 0.0144
    #> class 4:  0.9648 0.0352
    #> class 5:  1.0000 0.0000
    #> class 6:  0.8814 0.1186
    #> class 7:  0.9776 0.0224
    #> 
    #> $dis20
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9540 0.0460
    #> class 2:  0.9791 0.0209
    #> class 3:  0.9964 0.0036
    #> class 4:  0.9135 0.0865
    #> class 5:  0.7564 0.2436
    #> class 6:  0.9818 0.0182
    #> class 7:  0.8193 0.1807
    #> 
    #> $dis21
    #>            Pr(1)  Pr(2)
    #> class 1:  0.1606 0.8394
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9843 0.0157
    #> class 4:  0.6922 0.3078
    #> class 5:  0.1978 0.8022
    #> class 6:  0.4160 0.5840
    #> class 7:  1.0000 0.0000
    #> 
    #> $dis22
    #>            Pr(1)  Pr(2)
    #> class 1:  0.3870 0.6130
    #> class 2:  0.3475 0.6525
    #> class 3:  0.0945 0.9055
    #> class 4:  0.6194 0.3806
    #> class 5:  0.1725 0.8275
    #> class 6:  0.4588 0.5412
    #> class 7:  0.2100 0.7900
    #> 
    #> $dis23
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  0.9503 0.0497
    #> class 3:  0.9816 0.0184
    #> class 4:  0.9742 0.0258
    #> class 5:  0.8766 0.1234
    #> class 6:  0.6550 0.3450
    #> class 7:  0.9778 0.0222
    #> 
    #> $dis24
    #>            Pr(1)  Pr(2)
    #> class 1:  0.4466 0.5534
    #> class 2:  0.9481 0.0519
    #> class 3:  0.8267 0.1733
    #> class 4:  0.8153 0.1847
    #> class 5:  0.6768 0.3232
    #> class 6:  0.3406 0.6594
    #> class 7:  0.8844 0.1156
    #> 
    #> $dis25
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9297 0.0703
    #> class 2:  0.9554 0.0446
    #> class 3:  0.9917 0.0083
    #> class 4:  0.9533 0.0467
    #> class 5:  1.0000 0.0000
    #> class 6:  0.9408 0.0592
    #> class 7:  0.9966 0.0034
    #> 
    #> $dis26
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9835 0.0165
    #> class 2:  0.8919 0.1081
    #> class 3:  0.9900 0.0100
    #> class 4:  0.9133 0.0867
    #> class 5:  1.0000 0.0000
    #> class 6:  1.0000 0.0000
    #> class 7:  1.0000 0.0000
    #> 
    #> $dis27
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8244 0.1756
    #> class 2:  0.9084 0.0916
    #> class 3:  0.7771 0.2229
    #> class 4:  1.0000 0.0000
    #> class 5:  0.8617 0.1383
    #> class 6:  0.8664 0.1336
    #> class 7:  0.9182 0.0818
    #> 
    #> $dis28
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7747 0.2253
    #> class 2:  0.7664 0.2336
    #> class 3:  0.9103 0.0897
    #> class 4:  0.9177 0.0823
    #> class 5:  0.2712 0.7288
    #> class 6:  1.0000 0.0000
    #> class 7:  0.8433 0.1567
    #> 
    #> $dis29
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9154 0.0846
    #> class 2:  0.8677 0.1323
    #> class 3:  0.9989 0.0011
    #> class 4:  0.8393 0.1607
    #> class 5:  0.6536 0.3464
    #> class 6:  0.8868 0.1132
    #> class 7:  0.8754 0.1246
    #> 
    #> $dis30
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9699 0.0301
    #> class 2:  0.9212 0.0788
    #> class 3:  0.9551 0.0449
    #> class 4:  0.8529 0.1471
    #> class 5:  0.6716 0.3284
    #> class 6:  0.6686 0.3314
    #> class 7:  0.9236 0.0764
    #> 
    #> $dis31
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8142 0.1858
    #> class 2:  0.9641 0.0359
    #> class 3:  0.9934 0.0066
    #> class 4:  0.9416 0.0584
    #> class 5:  1.0000 0.0000
    #> class 6:  0.8111 0.1889
    #> class 7:  0.9793 0.0207
    #> 
    #> $dis32
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9470 0.0530
    #> class 2:  0.9498 0.0502
    #> class 3:  0.9809 0.0191
    #> class 4:  0.9860 0.0140
    #> class 5:  1.0000 0.0000
    #> class 6:  0.8354 0.1646
    #> class 7:  0.8805 0.1195
    #> 
    #> $dis33
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9559 0.0441
    #> class 2:  0.9458 0.0542
    #> class 3:  0.9736 0.0264
    #> class 4:  0.9431 0.0569
    #> class 5:  1.0000 0.0000
    #> class 6:  0.9770 0.0230
    #> class 7:  0.9490 0.0510
    #> 
    #> $dis34
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9859 0.0141
    #> class 2:  0.9586 0.0414
    #> class 3:  0.9911 0.0089
    #> class 4:  0.9628 0.0372
    #> class 5:  1.0000 0.0000
    #> class 6:  1.0000 0.0000
    #> class 7:  0.9704 0.0296
    #> 
    #> $dis35
    #>            Pr(1)  Pr(2)
    #> class 1:  1.0000 0.0000
    #> class 2:  1.0000 0.0000
    #> class 3:  0.9788 0.0212
    #> class 4:  0.8589 0.1411
    #> class 5:  0.9047 0.0953
    #> class 6:  1.0000 0.0000
    #> class 7:  0.9916 0.0084
    #> 
    #> $dis36
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8869 0.1131
    #> class 2:  0.9731 0.0269
    #> class 3:  0.9398 0.0602
    #> class 4:  0.9879 0.0121
    #> class 5:  0.7997 0.2003
    #> class 6:  1.0000 0.0000
    #> class 7:  0.9402 0.0598
    #> 
    #> $dis37
    #>            Pr(1)  Pr(2)
    #> class 1:  0.9918 0.0082
    #> class 2:  0.9367 0.0633
    #> class 3:  0.9760 0.0240
    #> class 4:  0.9903 0.0097
    #> class 5:  0.7810 0.2190
    #> class 6:  1.0000 0.0000
    #> class 7:  0.9944 0.0056
    #> 
    #> $dis38
    #>            Pr(1)  Pr(2)
    #> class 1:  0.8878 0.1122
    #> class 2:  0.9147 0.0853
    #> class 3:  0.9063 0.0937
    #> class 4:  0.9321 0.0679
    #> class 5:  0.6547 0.3453
    #> class 6:  0.9083 0.0917
    #> class 7:  0.8340 0.1660
    #> 
    #> $dis39
    #>            Pr(1)  Pr(2)
    #> class 1:  0.7781 0.2219
    #> class 2:  0.8013 0.1987
    #> class 3:  0.9057 0.0943
    #> class 4:  0.8057 0.1943
    #> class 5:  0.7051 0.2949
    #> class 6:  0.9801 0.0199
    #> class 7:  0.9077 0.0923
    #> 
    #> Estimated class population shares 
    #>  0.0669 0.1778 0.3675 0.1112 0.0109 0.0453 0.2203 
    #>  
    #> Predicted class memberships (by modal posterior prob.) 
    #>  0.0667 0.1547 0.4118 0.1086 0.0098 0.0393 0.209 
    #>  
    #> ========================================================= 
    #> Fit for 7 latent classes: 
    #> ========================================================= 
    #> number of observations: 1933 
    #> number of estimated parameters: 279 
    #> residual degrees of freedom: 1654 
    #> maximum log-likelihood: -20881.65 
    #>  
    #> AIC(7): 42321.3
    #> BIC(7): 43874.45
    #> G^2(7): 15031.97 (Likelihood ratio/deviance statistic) 
    #> X^2(7): 289145833 (Chi-square goodness of fit) 
    #>  
    #> [1] "Completed LCA with 7 ..."

Visualize and compare the metrics:

``` r
res$plot
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

Compare the classification accuracy on the train vs. test data:

``` r
ggacc <- ggaccuracy_LCA(res, test = X[test, ])
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

### Interpretation of the MM patterns

We now consider the result with 5 classes and try different method to
characterize the patterns in terms of over expressed diseases.

**Method 1:** O/E and Exclusivity:

``` r

OEx_sol5 <- ggOEx(res$obj[[4]], table = F)
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

**Method 2:** O/E and overall prevalence:

``` r

OE_sol5 <- ggOE(res$obj[[4]], table = F)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

**Method 3:**

``` r

prev_sol5 <- ggprev(res$obj[[4]])
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />
