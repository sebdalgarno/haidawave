library(magrittr)
library(dplyr)
library(readr)
library(lubridate)
library(devtools)

rm(list = ls())

cumshewa_wind <- read_csv('data-raw/wind-cumshewa-1216.csv')
laskeek_fetch <- read_csv('data-raw/laskeekbay-fetch-5.csv')

cumshewa_wind$DateTime %<>% force_tz(tzone = "Etc/GMT+8")

laskeek_fetch %<>% dplyr::select(PointID = PointID,
                          Long = Long,
                          Lat = Lat,
                          Bearing = Bearing,
                          Distance = Distance)

use_data(cumshewa_wind, overwrite = TRUE)

use_data(laskeek_fetch, overwrite = TRUE)
