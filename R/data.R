#' Cumshewa Wind
#'
#' A tbl of the hourly wind direction and speed at Cumshewa Head 2012 to 2016.
#'
#'
#' Hourly wind measurements from \url{http://http://climate.weather.gc.ca/historical_data/search_historic_data_e.html}.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Station}{The station name (chr).}
#'   \item{DateTime}{The date time (time).}
#'   \item{Direction}{The wind direction in degrees/10 (num).}
#'   \item{Speed}{The wind speed in km/hour (dbl).}
#'   \item{Longitude}{The longitude of weather station (dbl).}
#'   \item{Latitude}{The latitude of weather station (dbl).}
#' }
"cumshewa_wind"
