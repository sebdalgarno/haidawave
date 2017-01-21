#' Summed Fetch
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame of sites with columns indicating fetch distance at different bearings.
#' @param fetch.cols A vector of column numbers.
#' @param max.distance An integer indicating desired maximum distance of fetch calculations.

#' @return One additional column to site.data ('sumfetch') with summed fetch results.
#' @export
sum_fetch = function(site.data, fetch.data, fetch.cols = 3:74, max.distance = 650000) {
  check_number(max.distance)

  if(inherits(site.data, "SpatialPointsDataFrame")|inherits(fetch.data, "SpatialPointsDataFrame"))
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if(identical(site.data@proj4string, fetch.data@proj4string)==FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  fetch.data@data[,fetch.cols][fetch.data@data[,fetch.cols]=="Inf"|fetch.data@data[,fetch.cols]>max.distance]=max.distance

  site.data %<>% mutate(sumfetch = rowSums(fetch.data[apply(rgeos::gDistance(fetch.data,site.data,byid=TRUE),1,which.min),fetch.cols]@data))
}
