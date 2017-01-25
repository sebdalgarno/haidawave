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
#'   \item{Direction}{The wind direction in degrees (num).}
#'   \item{Speed}{The wind speed in km/hour (dbl).}
#'   \item{Longitude}{The longitude of weather station, WGS84 (dbl).}
#'   \item{Latitude}{The latitude of weather station, WGS84 (dbl).}
#' }
"cumshewa_wind"

#' Laskeek Bay fetch
#'
#' A tbl of fetch distances calculated at 5 degree intervals for points spaced 10m along the caostline of islands with Laskeek Bay, BC.
#'
#'
#' Fetch distances were calculated using ShoreZone 1:50,000 vector coastline data and the 'Vector_fetch' software, developed by Mika Murtojarvi.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{PointID}{Unique ID for all points (int).}
#'   \item{Long}{The longitude of point, in BC Albers (num).}
#'   \item{Lat}{The latitude of point, in BC Albers (num).}
#'   \item{Bearing}{The bearing in degress (int).}
#'   \item{Distance}{The distance in m (num).}
#' }
"laskeek_fetch"
