
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
devtools::install_github("sooyongl/clavaan")
```

<!-- The documentation is available at [here](https://sooyongl.github.io/clavaan/). -->

``` r
library(clavaan)
library(lavaan)
#> Warning: 패키지 'lavaan'는 R 버전 4.2.2에서 작성되었습니다
#> This is lavaan 0.6-14
#> lavaan is FREE software! Please report any bugs.
suppressPackageStartupMessages(library(tidyverse))
#> Warning: 패키지 'ggplot2'는 R 버전 4.2.2에서 작성되었습니다
#> Warning: 패키지 'tibble'는 R 버전 4.2.3에서 작성되었습니다
#> Warning: 패키지 'dplyr'는 R 버전 4.2.3에서 작성되었습니다
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
#> lavaan 0.6.14 ended normally after 17 iterations
#> 
#>   Estimator                                        GLS
#>   Optimization method                           NLMINB
#>   Number of model parameters                        10
#> 
#>   Number of observations                           500
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                22.166
#>   Degrees of freedom                                10
#>   P-value (Chi-square)                           0.014
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
#>     S                 0.203    0.050    4.017    0.000
#> 
#> Intercepts:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 2.946    0.058   50.795    0.000
#>     S                 0.543    0.037   14.611    0.000
#>    .y1                0.000                           
#>    .y2                0.000                           
#>    .y3                0.000                           
#>    .y4                0.000                           
#>    .y5                0.000                           
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 0.984    0.112    8.786    0.000
#>     S                 0.564    0.044   12.766    0.000
#>    .y1                1.152    0.111   10.422    0.000
#>    .y2                1.065    0.085   12.596    0.000
#>    .y3                0.817    0.069   11.759    0.000
#>    .y4                0.931    0.095    9.810    0.000
#>    .y5                1.417    0.166    8.524    0.000
```

<!-- </div> -->

### lavaan with censored data

<!-- <div class = "col-md-6"> -->

``` r
growth(model,data = cen.data) %>%
  summary()
#> lavaan 0.6.14 ended normally after 30 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        10
#> 
#>   Number of observations                           500
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                80.488
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
#>     S                 0.040    0.022    1.791    0.073
#> 
#> Intercepts:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 3.277    0.049   66.552    0.000
#>     S                 0.319    0.018   17.658    0.000
#>    .y1                0.000                           
#>    .y2                0.000                           
#>    .y3                0.000                           
#>    .y4                0.000                           
#>    .y5                0.000                           
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 0.766    0.081    9.453    0.000
#>     S                 0.103    0.011    9.310    0.000
#>    .y1                0.804    0.076   10.615    0.000
#>    .y2                0.780    0.060   13.063    0.000
#>    .y3                0.610    0.046   13.159    0.000
#>    .y4                0.456    0.043   10.571    0.000
#>    .y5                0.416    0.061    6.834    0.000
```

<!-- </div> -->
<!-- </div> -->

### lavaan with original data

``` r
growth(model,data = unc.data) %>%
  summary()
#> lavaan 0.6.14 ended normally after 36 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        10
#> 
#>   Number of observations                           500
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                13.155
#>   Degrees of freedom                                10
#>   P-value (Chi-square)                           0.215
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
#>     S                 0.255    0.050    5.142    0.000
#> 
#> Intercepts:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 2.949    0.060   49.465    0.000
#>     S                 0.533    0.035   15.043    0.000
#>    .y1                0.000                           
#>    .y2                0.000                           
#>    .y3                0.000                           
#>    .y4                0.000                           
#>    .y5                0.000                           
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     I                 1.131    0.120    9.444    0.000
#>     S                 0.514    0.040   12.761    0.000
#>    .y1                1.078    0.108    9.978    0.000
#>    .y2                1.077    0.084   12.841    0.000
#>    .y3                0.921    0.074   12.449    0.000
#>    .y4                1.017    0.099   10.294    0.000
#>    .y5                1.233    0.156    7.925    0.000
```

``` r
sessionInfo()
#> R version 4.2.1 (2022-06-23 ucrt)
#> Platform: x86_64-w64-mingw32/x64 (64-bit)
#> Running under: Windows 10 x64 (build 19045)
#> 
#> Matrix products: default
#> 
#> locale:
#> [1] LC_COLLATE=Korean_Korea.utf8  LC_CTYPE=Korean_Korea.utf8   
#> [3] LC_MONETARY=Korean_Korea.utf8 LC_NUMERIC=C                 
#> [5] LC_TIME=Korean_Korea.utf8    
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] forcats_0.5.2   stringr_1.4.1   dplyr_1.1.3     purrr_0.3.5    
#>  [5] readr_2.1.3     tidyr_1.2.1     tibble_3.2.1    ggplot2_3.4.0  
#>  [9] tidyverse_1.3.2 lavaan_0.6-14   clavaan_0.1.0  
#> 
#> loaded via a namespace (and not attached):
#>  [1] lubridate_1.8.0     mvtnorm_1.1-3       assertthat_0.2.1   
#>  [4] digest_0.6.30       utf8_1.2.2          R6_2.5.1           
#>  [7] cellranger_1.1.0    backports_1.4.1     reprex_2.0.2       
#> [10] stats4_4.2.1        evaluate_0.17       httr_1.4.4         
#> [13] pillar_1.9.0        rlang_1.1.0         googlesheets4_1.0.1
#> [16] readxl_1.4.1        rstudioapi_0.14     pbivnorm_0.6.0     
#> [19] rmarkdown_2.17      googledrive_2.0.0   munsell_0.5.0      
#> [22] broom_1.0.1         compiler_4.2.1      modelr_0.1.9       
#> [25] xfun_0.34           pkgconfig_2.0.3     mnormt_2.1.1       
#> [28] htmltools_0.5.3     tidyselect_1.2.0    quadprog_1.5-8     
#> [31] fansi_1.0.3         crayon_1.5.2        tzdb_0.3.0         
#> [34] dbplyr_2.2.1        withr_2.5.0         MASS_7.3-57        
#> [37] grid_4.2.1          jsonlite_1.8.3      gtable_0.3.1       
#> [40] lifecycle_1.0.3     DBI_1.1.3           magrittr_2.0.3     
#> [43] scales_1.2.1        cli_3.4.1           stringi_1.7.8      
#> [46] fs_1.5.2            xml2_1.3.3          ellipsis_0.3.2     
#> [49] generics_0.1.3      vctrs_0.6.2         tools_4.2.1        
#> [52] glue_1.6.2          hms_1.1.2           parallel_4.2.1     
#> [55] fastmap_1.1.0       yaml_2.3.6          colorspace_2.0-3   
#> [58] gargle_1.2.1        rvest_1.0.3         knitr_1.40         
#> [61] haven_2.5.1
```
