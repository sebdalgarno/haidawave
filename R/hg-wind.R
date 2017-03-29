#' Haida Gwaii Wind
#'
#' Downloads the dataset from \url{https://raw.githubusercontent.com/sebdalgarno/haidawave-data/master/wind-hg-1216.csv}.
#'
#' The wind data set comprises hourly wind observations for all weather stations in Haida Gwaii with available data from 2012-2016.
#' These data were taken from <http://climate.weather.gc.ca/historical_data/search_historic_data_e.html>.
#'
#' @return A tbl with the columns Station, DateTime, Direction, Speed, Long and Lat.
#' @export
hg_wind <- function() {
  readr::read_csv("https://raw.githubusercontent.com/sebdalgarno/haidawave-data/master/wind-hg-1216.csv",
                       col_types = cols(
                         Station = col_character(),
                         DateTime = col_datetime(format = ""),
                         Direction = col_double(),
                         Speed = col_double(),
                         Long = col_double(),
                         Lat = col_double()))
}
