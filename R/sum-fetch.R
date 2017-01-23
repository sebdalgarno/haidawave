#' Given data with fetch calculated at bearings for a set of points, find nearest point to a set of sites and calculate summed fetch given a maximum fetch distance.
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame with columns containing unique ID, bearing, and fetch distance, along with coordinates. Column with distance must be named "Distance".
#' @param fetch.ID A string of the name of the column containing a unique point ID.
#' @param fetch.distance A string of the name of the column containing fetch distance.
#' @param max.distance An integer indicating desired maximum distance of fetch calculations.

#' @return Two additional columns to site.data: 'nearest.pt' contains unique ID of nearest fetch.data point; 'sumfetch' contains summed fetch results, .
#' @export
sum_fetch = function(site.data, fetch.data, fetch.ID = "PointID", fetch.distance = "Distance", max.distance = 200000) {
  check_number(max.distance)
  check_string(fetch.ID)
  check_string(fetch.distance)

  check_cols(fetch.data@data, colnames = c(fetch.ID, fetch.distance))

  if(inherits(site.data, "SpatialPointsDataFrame") == FALSE|inherits(fetch.data, "SpatialPointsDataFrame") == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if(identical(site.data@proj4string, fetch.data@proj4string)==FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  colnames(fetch.data@data)[colnames(fetch.data@data) == fetch.distance] <- 'd'

  fetch.data@data[,'d'][fetch.data@data[,'d']>max.distance] = max.distance

  colnames(fetch.data@coords) <- c("Long", "Lat")

  fetch <- as.data.frame(fetch.data)

  fetch %<>% ddply('PointID', summarize, sumfetch = sum(d), Long = min(Long), Lat = min(Lat))

  coordinates(fetch) <- c("Long", "Lat")
  proj4string(fetch) <- sp.fetch@proj4string

  tree <- createTree(coordinates(fetch))

  index <- knnLookup(tree, newdat=coordinates(sp.shzn), k=1)

  site.data@data %<>% mutate(sumfetch = fetch@data[index[,1], 'sumfetch'])

}
