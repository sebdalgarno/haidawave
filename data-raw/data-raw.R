library(magrittr)
library(dplyr)
library(readr)
library(lubridate)
library(devtools)

rm(list = ls())

cumshewa_wind <- read_csv('data-raw/wind-cumshewa-1216.csv')
laskeek_fetch <- read_csv('data-raw/laskeekbay-fetch-5.csv')

cumshewa_wind$DateTime %<>% force_tz(tzone = "Etc/GMT+8")

laskeek_fetch %<>% select_(~-X1)
colnames(laskeek_fetch) <- c('Easting', 'Northing', 'bearing5', 'bearing10', 'bearing15', 'bearing20','bearing25','bearing30','bearing35','bearing40','bearing45',
                             'bearing50','bearing55','bearing60','bearing65','bearing70','bearing75','bearing80','bearing85','bearing90','bearing95',
                             'bearing100','bearing105','bearing110','bearing115','bearing120','bearing125','bearing130','bearing135','bearing140','bearing145',
                             'bearing150','bearing155','bearing160','bearing165','bearing170','bearing175','bearing180','bearing185','bearing190','bearing195',
                             'bearing200','bearing205','bearing210','bearing215','bearing220','bearing225','bearing230','bearing235','bearing240','bearing245',
                             'bearing250','bearing255','bearing260','bearing265','bearing270','bearing275','bearing280','bearing285','bearing290','bearing295',
                             'bearing300','bearing305','bearing310','bearing315','bearing320','bearing325','bearing330','bearing335','bearing340','bearing345',
                             'bearing350','bearing355', 'bearing360')

cumshewa_wind %<>% rename(Longitude = Long, Latitude = Lat)

use_data(cumshewa_wind, overwrite = TRUE)

use_data(laskeek_fetch, overwrite = TRUE)
