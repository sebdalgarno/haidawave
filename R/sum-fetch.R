#' Calculate summed Fetchs.
#'
#' Set maximum fetch distance and calculate summed fetch from nearest point.
#'
#' For this function to work, input data must be SpatialPointsDataFrame with identical CRS. The convert_proj function can be used to achieve that. Note that it is not necessary to run the nearest_point function prior to this one.
#' To reduce processing time, subset fetch.data to a region encompassing your site.data.
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame with columns containing unique ID, bearing, and fetch distance, along with coordinates.
#' @param fetch.ID A string of the name of the column containing a unique point ID.
#' @param fetch.distance A string of the name of the column containing fetch distance.
#' @param max.distance An integer indicating desired maximum dfetch distance.

#' @return Two additional columns to site.data: 'nearest.pt' contains unique ID of nearest fetch.data point; 'sumfetch' contains summed fetch results.
#' @export
sum_fetch = function(site.data, fetch.data, fetch.ID = "PointID", fetch.distance = "Distance", max.distance = 200000) {
  check_number(max.distance)
  check_string(fetch.ID)
  check_string(fetch.distance)

  check_cols(fetch.data@data, colnames = c(fetch.ID, fetch.distance))

  if(is.spdf(site.data) == FALSE|is.spdf(fetch.data)  == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if(same.crs(site.data, fetch.data) == FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  colnames(fetch.data@data)[colnames(fetch.data@data) == fetch.distance] <- 'd'

  fetch.data@data[,'d'][fetch.data@data[,'d']>max.distance] = max.distance

  colnames(fetch.data@coords) <- c("Long", "Lat")

  fetch <- as.data.frame(fetch.data)

  fetch %<>% plyr::ddply('PointID', summarize, sumfetch = sum(d), Long = min(Long), Lat = min(Lat))

  coordinates(fetch) <- c("Long", "Lat")
  proj4string(fetch) <- fetch.data@proj4string

  tree <- SearchTrees::createTree(coordinates(fetch))

  index <- SearchTrees::knnLookup(tree, newdat=coordinates(site.data), k=1)

  site.data@data %<>% dplyr::mutate(sumfetch = fetch@data[index[,1], 'sumfetch'])

  return(site.data)

}
