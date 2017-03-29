#' Cumshewa Wind
#'
#' A tbl of the hourly wind direction and speed at Cumshewa Head 2012 to 2016.
#'
#' Hourly wind measurements from \url{http://http://climate.weather.gc.ca/historical_data/search_historic_data_e.html}.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Station}{The station name (chr).}
#'   \item{DateTime}{The date and time in Pacific Standard Time (UTC - 8) (dttm).}
#'   \item{Direction}{The direction the wind is blowing from in degrees (dbl).}
#'   \item{Speed}{The wind speed in km/hour (dbl).}
#'   \item{Long}{The station's longitude in EPSG:4326 (dbl).}
#'   \item{Lat}{The station's latitude in EPSG:4326 (dbl).}
#' }
"cumshewa_wind"

#' Laskeek Bay fetch
#'
#' A tbl of fetch distances at 5 degree intervals for points spaced 10m along the coastline of islands within Laskeek Bay, BC.
#'
#' Fetch distances were calculated using ShoreZone 1:50,000 vector coastline data and the 'Vector_fetch' software, developed by Mika Murtojarvi.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Easting}{The Easting in EPSG:3005 (dbl).}
#'   \item{Northing}{The Northing in EPSG:3005 (dbl).}
#'   \item{Bearing}{The bearing in degrees (dbl).}
#'   \item{Fetch}{The fetch in m (dbl).}
#' }
"laskeek_fetch"
