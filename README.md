
# `clavaan`

## Overview

The `clavaan` package is specifically designed for analyzing censored
data within the structural equation modeling framework. It is capable of
handling right, left, or doubly-censored data. By estimating the
censored mean and variance-covariance from the censored data, the
package enables model fitting using the well-established `lavaan`
package. This integration allows researchers to accurately analyze
censored data and draw reliable conclusions from their structural
equation models.

## Install

Install the latest release from CRAN:

``` r
devtools::install_github("testaddress999/clavaan")
```

<!-- The documentation is available at [here](https://sooyongl.github.io/clavaan/). -->

``` r
library(clavaan)
library(lavaan)
#> This is lavaan 0.6-17
#> lavaan is FREE software! Please report any bugs.
suppressPackageStartupMessages(library(tidyverse))
```

## Generate Latent growth curve model data

To generate data based on the latent growth model with a mean intercept
of 3 and a mean slope of 0.5 using the `lavaan` package, you can follow
the below code:

``` r
unc.data <- lavaan::simulateData('
                     # Time indicators            
                     I =~ 1*y1 + 1*y2 + 1*y3 + 1*y4 + 1*y5
                     S =~ 0*y1 + 1*y2 + 2*y3 + 3*y4 + 4*y5

                     # GROWTH MEANS
                     I ~ 3*1
                     S ~ 0.5*1
                     
                     # GROWTH Var-Covariance
                     I ~~ 1*I + 0.2*S
                     S ~~ 0.5*S
                     ', 
                     model.type = 'growth',
                     sample.nobs = 500)
```

## Censore data

To censor the generated data, you can use the `cenPoint()` function from
the `clavaan` package, which allows you to set the proportion of
censoring at each end. In this case, the data will be censored at 40%
with 20% at each point. The code would look like this:

``` r
censored_prop <- c(left = 0.2, right = 0.8)

cen_points <- clavaan:::cenPoint(x = unc.data,
                       lower_quant = censored_prop[1],
                       upper_quant = censored_prop[2])


cen.data <- clavaan:::cenData(unc.data, cen_points) %>%
  data.frame() %>%
  set_names(names(unc.data))
```

This will result in a censored dataset with 20% censoring at the lower
end and 20% censoring at the upper end, totaling 40% censoring overall.

## Compare typical MLE and GBIT

To analyze the data using both MLE and GBIT, you can utilize the
`growth()` function from the `lavaan` package for MLE, and the
`cgrowth()` function from the `clavaan` package for GBIT. Employing
these two methods will allow you to compare their performance and better
understand the impact of censoring on your data.

``` r
model =
'I =~ 1*y1 + 1*y2 + 1*y3 + 1*y4 + 1*y5
 S =~ 0*y1 + 1*y2 + 2*y3 + 3*y4 + 4*y5

 I ~ 1
 S ~ 1

 I ~~ I + S
 S ~~ S'
```

### clavaan

<!-- <div class = "row"> -->
<!-- <div class = "col-md-6"> -->

``` r
cgrowth(model, data = cen.data, 
        bounds = cen_points)%>%
  summary()
#> Censored points must be named. For example, list(y1 = c(1, 5), y2 = c(1,5))
#> lavaan 0.6.17 ended normally after 18 iterations
#> 
#>   Estimator                                        GLS
#>   Optimization method                           NLMINB
#>   Number of model parameters                        10
#> 
#>   Number of observations                           500
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                29.566
#>   Degrees of freedom                                10
#>   P-value (Chi-square)                           0.001
#> 
#> Parameter Estimates:
#> 
#>   Standard errors                             Standard
#>   Information                                 Expected
#>   Information saturated (h1) model          Structured
#> 
#> Latent Variables:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   I =~                                                
#>     y1                1.000                           
#>     y2                1.000                           
#>     y3                1.000                           
#>     y4                1.000                           
#>     y5                1.000                           
#>   S =~                                                
#>     y1                0.000                           
#>     y2                1.000                           
#>     y3                2.000                           
#>     y4                3.000                           
#>     y5                4.000                           
#> 
#> Covariances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   I ~~                                                
#>     S                 0.210    0.053    3.991    0.000
#> 
#> Intercepts:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 2.940    0.061   48.320    0.000
#>     S                 0.518    0.037   14.055    0.000
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 1.156    0.123    9.366    0.000
#>     S                 0.548    0.044   12.565    0.000
#>    .y1                1.167    0.117    9.966    0.000
#>    .y2                1.046    0.083   12.579    0.000
#>    .y3                1.069    0.084   12.765    0.000
#>    .y4                0.802    0.092    8.762    0.000
#>    .y5                1.205    0.160    7.541    0.000
```

<!-- </div> -->

### lavaan with censored data

<!-- <div class = "col-md-6"> -->

``` r
growth(model,data = cen.data) %>%
  summary()
#> lavaan 0.6.17 ended normally after 31 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        10
#> 
#>   Number of observations                           500
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                71.573
#>   Degrees of freedom                                10
#>   P-value (Chi-square)                           0.000
#> 
#> Parameter Estimates:
#> 
#>   Standard errors                             Standard
#>   Information                                 Expected
#>   Information saturated (h1) model          Structured
#> 
#> Latent Variables:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   I =~                                                
#>     y1                1.000                           
#>     y2                1.000                           
#>     y3                1.000                           
#>     y4                1.000                           
#>     y5                1.000                           
#>   S =~                                                
#>     y1                0.000                           
#>     y2                1.000                           
#>     y3                2.000                           
#>     y4                3.000                           
#>     y5                4.000                           
#> 
#> Covariances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   I ~~                                                
#>     S                 0.021    0.023    0.918    0.359
#> 
#> Intercepts:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 3.270    0.051   63.978    0.000
#>     S                 0.311    0.018   17.260    0.000
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 0.875    0.086   10.125    0.000
#>     S                 0.114    0.011   10.067    0.000
#>    .y1                0.790    0.076   10.346    0.000
#>    .y2                0.758    0.059   12.817    0.000
#>    .y3                0.683    0.050   13.551    0.000
#>    .y4                0.503    0.045   11.278    0.000
#>    .y5                0.257    0.056    4.626    0.000
```

<!-- </div> -->
<!-- </div> -->

### lavaan with original data

``` r
growth(model,data = unc.data) %>%
  summary()
#> lavaan 0.6.17 ended normally after 32 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        10
#> 
#>   Number of observations                           500
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                13.086
#>   Degrees of freedom                                10
#>   P-value (Chi-square)                           0.219
#> 
#> Parameter Estimates:
#> 
#>   Standard errors                             Standard
#>   Information                                 Expected
#>   Information saturated (h1) model          Structured
#> 
#> Latent Variables:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   I =~                                                
#>     y1                1.000                           
#>     y2                1.000                           
#>     y3                1.000                           
#>     y4                1.000                           
#>     y5                1.000                           
#>   S =~                                                
#>     y1                0.000                           
#>     y2                1.000                           
#>     y3                2.000                           
#>     y4                3.000                           
#>     y5                4.000                           
#> 
#> Covariances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   I ~~                                                
#>     S                 0.222    0.049    4.538    0.000
#> 
#> Intercepts:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 2.994    0.060   49.759    0.000
#>     S                 0.508    0.035   14.586    0.000
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 1.167    0.121    9.610    0.000
#>     S                 0.502    0.039   12.912    0.000
#>    .y1                1.095    0.110    9.994    0.000
#>    .y2                1.037    0.082   12.668    0.000
#>    .y3                1.049    0.080   13.077    0.000
#>    .y4                0.846    0.087    9.675    0.000
#>    .y5                1.030    0.141    7.310    0.000
```

``` r
sessionInfo()
#> R version 4.3.2 (2023-10-31 ucrt)
#> Platform: x86_64-w64-mingw32/x64 (64-bit)
#> Running under: Windows 11 x64 (build 22631)
#> 
#> Matrix products: default
#> 
#> 
#> locale:
#> [1] LC_COLLATE=Korean_Korea.utf8  LC_CTYPE=Korean_Korea.utf8   
#> [3] LC_MONETARY=Korean_Korea.utf8 LC_NUMERIC=C                 
#> [5] LC_TIME=Korean_Korea.utf8    
#> 
#> time zone: America/Chicago
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] lubridate_1.9.3 forcats_1.0.0   stringr_1.5.1   dplyr_1.1.4    
#>  [5] purrr_1.0.2     readr_2.1.5     tidyr_1.3.1     tibble_3.2.1   
#>  [9] ggplot2_3.5.0   tidyverse_2.0.0 lavaan_0.6-17   clavaan_0.1.0  
#> 
#> loaded via a namespace (and not attached):
#>  [1] utf8_1.2.4        generics_0.1.3    stringi_1.8.4     hms_1.1.3        
#>  [5] digest_0.6.34     magrittr_2.0.3    evaluate_0.23     grid_4.3.2       
#>  [9] timechange_0.3.0  mvtnorm_1.2-4     fastmap_1.1.1     fansi_1.0.6      
#> [13] scales_1.3.0      pbivnorm_0.6.0    mnormt_2.1.1      cli_3.6.2        
#> [17] rlang_1.1.3       munsell_0.5.0     withr_3.0.0       yaml_2.3.8       
#> [21] tools_4.3.2       parallel_4.3.2    tzdb_0.4.0        colorspace_2.1-0 
#> [25] vctrs_0.6.5       R6_2.5.1          stats4_4.3.2      lifecycle_1.0.4  
#> [29] MASS_7.3-60       pkgconfig_2.0.3   pillar_1.9.0      gtable_0.3.4     
#> [33] glue_1.7.0        xfun_0.43         tidyselect_1.2.1  rstudioapi_0.15.0
#> [37] knitr_1.46        htmltools_0.5.7   rmarkdown_2.26    compiler_4.3.2   
#> [41] quadprog_1.5-8
```
