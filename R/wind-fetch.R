#' Wind fetch
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame of sites with columns indicating fetch distance at different bearings.
#' @param fetch.cols A vector of column numbers.
#' @param max.distance An integer indicating desired maximum distance of fetch calculations.

#' @return One additional column to site.data ('sumfetch') with summed fetch results.
#' @export
