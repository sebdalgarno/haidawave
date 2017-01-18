
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/sebdalgarno/HGfetch.svg?branch=master)](https://travis-ci.org/sebdalgarno/HGfetch)

HGfetch
=======

Introduction
------------

xx

Utilisation
-----------

``` r
library(HGfetch)
#> Loading required package: sp

data <- data.frame(Long = -131, Lat = 53)
convert_proj(data)
#> SpatialPoints:
#>          Long      Lat
#> [1,] 665406.9 899846.7
#> Coordinate Reference System (CRS) arguments: +init=epsg:3005
#> +proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000
#> +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0
```

Installation
------------

To install from GitHub

    # install.packages("devtools")
    devtools::install_github("sebdalgarno/HGfetch")

Contribution
------------

Please report any [issues](https://github.com/sebdalgarno/HGfetch/issues).

[Pull requests](https://github.com/sebdalgarno/HGfetch/pulls) are always welcome.
