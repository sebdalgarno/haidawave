#' Calculate wind-altered summed fetch.
#'
#' Set maximum fetch distance, find fetch lines from nearest point, weight fetch lines according to conditions at nearest weather station, calculate wind-altered summed fetch.
#'
#' For this function to work, input data must be SpatialPointsDataFrame with identical CRS. The convert_proj function can be used to achieve that.
#' Weighting factors (weights.data) should be generated first using the wind_weights function. Note that it is not necessary to run the nearest_point function prior to this one.
#' To reduce processing time, subset fetch.data to a region encompassing your site.data.
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame of sites with a column indicating fetch bearing and a column indicating fetch distance.
#' @param fetch.bearing A string of the name of the column containing fetch bearing.
#' @param fetch.distance A string of the name of the column containing fetch distance.
#' @param fetch.ID A string of the name of the column containing unique ID.
#' @param weights.data A SpatialPointsDataFrame including columns indicating station name, direction and weighting factor.
#' @param weights.station A string of the name of the column containing names of weather stations.
#' @param weights.direction A string of the name of the column containing wind direction.
#' @param weights A string of the name of the column containing wind weighting factors for each direction.
#' @param max.distance An integer indicating desired maximum distance of fetch calculations.

#' @return One additional column to site.data ('windfetch') with wind-altered summed fetch results.
#' @export
wind_fetch=function(site.data, fetch.data, fetch.bearing = "Bearing", fetch.distance = "Distance", fetch.ID = "PointID", weights.data,
                   weights.station = "Station", weights.direction = "Direction", weights = "Weight",  max.distance = 200000) {
  check_string(fetch.bearing)
  check_string(fetch.distance)
  check_string(fetch.ID)
  check_string(weights.direction)
  check_string(weights.station)
  check_string(weights)
  check_number(max.distance)

  if (is.spdf(site.data) == FALSE | is.spdf(fetch.data) == FALSE | is.spdf(weights.data) == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if (same.crs(site.data, fetch.data) == FALSE | same.crs(fetch.data, weights.data) == FALSE)
    stop('data sets must have same CRS! Use convert function first.')

  check_cols(weights.data@data, colnames = c(weights.direction, weights, weights.station))
  check_cols(fetch.data@data, colnames = c(fetch.bearing, fetch.distance))

  colnames(fetch.data@data)[colnames(fetch.data@data) == fetch.distance] <- 'dis'
  colnames(weights.data@data)[colnames(weights.data@data) == weights.direction] <- 'dir'
  colnames(weights.data@data)[colnames(weights.data@data) == weights] <- 'weights'

  fetch.data@data[,'dis'][fetch.data@data[,'dis']>max.distance]=max.distance

  tree.wind <- SearchTrees::createTree(coordinates(weights.data))

  index.wind <- SearchTrees::knnLookup(tree.wind, newdat=coordinates(fetch.data), k=1)

  fetch.data@data %<>% dplyr::mutate(Station = weights.data@data[index.wind[,1], weights.station])

  weights.data@data %<>% dplyr::mutate(Direction = round(dir, -1))

  colnames(fetch.data@coords) <- c("Long", "Lat")

  fetch <- as.data.frame(fetch.data)

  fetch %<>% base::merge(weights.data@data, by.x = c('Station', fetch.bearing), by.y = c(weights.station, weights.direction))

  fetch %<>% dplyr::mutate(weight.dist = dis*weights)

  fetch %<>% plyr::ddply(fetch.ID, summarize, windfetch = round(mean(weight.dist), 0), Long = dplyr::first(Long), Lat = dplyr::first(Lat))

  coordinates(fetch) <- c("Long", "Lat")
  proj4string(fetch) <- fetch.data@proj4string

  tree.fetch <- SearchTrees::createTree(coordinates(fetch))

  index.fetch <- SearchTrees::knnLookup(tree.fetch, newdat=coordinates(site.data), k=1)

  site.data@data %<>% dplyr::mutate(windfetch = fetch@data[index.fetch[,1], 'windfetch'])

  return(site.data)

  }


