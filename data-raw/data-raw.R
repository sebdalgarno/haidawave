library(magrittr)
library(dplyr)
library(readr)
library(devtools)

rm(list = ls())

cumshewa_wind <- read_csv('data-raw/wind-cumshewa-1216.csv')
laskeek_fetch <- read_csv('data-raw/laskeekbay-fetch-5.csv')

laskeek_fetch %<>% dplyr::select(PointID = PointID,
                          Long = Long,
                          Lat = Lat,
                          Bearing = Bearing,
                          Distance = Distance)

use_data(cumshewa_wind, overwrite = TRUE)

use_data(laskeek_fetch, overwrite = TRUE)
