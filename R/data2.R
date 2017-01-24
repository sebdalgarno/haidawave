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
