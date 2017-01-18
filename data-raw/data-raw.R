library(magrittr)
library(dplyr)
library(readr)
library(devtools)

rm(list = ls())

cumshewa_wind <- read_csv('data-raw/wind-cumshewa-1216.csv')
laskeek_fetch <- read_csv('data-raw/laskeekbay-fetch-5.csv')

# need to set timezone
cumshewa_wind %<>% mutate(DateTime = ISOdate(year, month, day, hour = 0),
                          DateTime = DateTime + time)

cumshewa_wind %<>% select(Station = wind.station,
                          DateTime,
                          Direction = windir,
                          Speed = winspd,
                          Long = lon,
                          Lat = lat
                          )

use_data(cumshewa_wind, overwrite = TRUE)
