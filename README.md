
<!-- README.md is generated from README.Rmd. Please edit that file -->

# HBVr <img src='man/figures/logo.svg' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/atsyplenkov/HBVr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/atsyplenkov/HBVr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of HBVr is to ease the accessebility of HBV Global Parameter
maps created by Beck et al. ([2020](http://www.gloh2o.org/hbv/)).
Therefore this one-function package allows to download any of the
cross-validation folds for your particular area of interest (AOI).

## Installation

You can install the development version of HBVr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("atsyplenkov/HBVr")
```

## Disclaimer

While `HBVr` does not redistribute the data or provide it in any way, we
encourage users to cite original papers when using this package:

> Beck HE, Pan M, Lin P, Seibert J, van Dijk AIJM, Wood EF. 2020. Global
> Fully Distributed Parameter Regionalization Based on Observed
> Streamflow From 4,229 Headwater Catchments. Journal of Geophysical
> Research: Atmospheres 125 : e2019JD031485. DOI: 10.1029/2019JD03148

## Example

You can download mean zonal statistics

``` r
library(HBVr)

# Locate the shapefile
f <- system.file("ex/lux.shp", package="terra")
# Read it as SpatVector
v <- vect(f)

zonal_stat <- 
  hbv_get_parameters(
    aoi = v,
    folds = 1,
    mean = TRUE
  )
#> Downloading rasters...
#> Cropping rasters...

zonal_stat
#> $fold_1
#>               mean
#> beta    3.28827362
#> FC    397.27255745
#> K0      0.45688133
#> K1      0.33620186
#> K2      0.15122986
#> LP      0.67929192
#> PERC    6.54499855
#> UZL    73.98409042
#> TT     -3.25675583
#> CFMAX   4.50942764
#> CFR     0.08118668
#> CWH     0.18391457
```

or retrieve a `SpatRaster` objects:

``` r

rasters <- 
    hbv_get_parameters(
    aoi = v,
    folds = 1,
    mean = FALSE
  )
#> Downloading rasters...
#> Cropping rasters...
#> Projecting rasters...

plot(rasters[[1]])
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
