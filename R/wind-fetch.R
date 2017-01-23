#' #' Given data with fetch calculated at bearings for a set of points, find nearest point to a set of sites, weight each fetch line by proportion of time that wind blew in that direction from the nearest weather station, calculate summed fetch given a maximum fetch distance.
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

#' @return One additional column to site.data ('windfetch') with wind-weighted summed fetch results.
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

  if (inherits(site.data, "SpatialPointsDataFrame") == FALSE|inherits(fetch.data, "SpatialPointsDataFrame") == FALSE|inherits(weights.data, "SpatialPointsDataFrame") == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if (identical(site.data@proj4string,fetch.data@proj4string)==FALSE|identical(fetch.data@proj4string,weights.data@proj4string)==FALSE)
    stop('data sets must have same CRS! Use convert function first.')

  check_cols(weights.data@data, colnames = c(weights.direction, weights, weights.station))
  check_cols(fetch.data@data, colnames = c(fetch.bearing, fetch.distance))

  colnames(fetch.data@data)[colnames(fetch.data@data) == fetch.distance] <- 'dis'
  colnames(weights.data@data)[colnames(weights.data@data) == weights.direction] <- 'dir'
  colnames(weights.data@data)[colnames(weights.data@data) == weights] <- 'weights'

  fetch.data@data[,'dis'][fetch.data@data[,'dis']>max.distance]=max.distance

  tree.wind <- createTree(coordinates(weights.data))

  index.wind <- knnLookup(tree.wind, newdat=coordinates(fetch.data), k=1)

  fetch.data@data %<>% mutate(Station = weights.data@data[index.wind[,1], weights.station])

  weights.data@data %<>% mutate(Direction = round(dir, -1))

  colnames(fetch.data@coords) <- c("Long", "Lat")

  fetch <- as.data.frame(fetch.data)

  fetch %<>% merge(weights.data@data, by.x = c('Station', fetch.bearing), by.y = c(weights.station, weights.direction))

  fetch %<>% mutate(weight.dist = dis*weights)

  fetch %<>% ddply(fetch.ID, summarize, windfetch = round(sum(weight.dist), 0), Long = min(Long), Lat = min(Lat))

  coordinates(fetch) <- c("Long", "Lat")
  proj4string(fetch) <- fetch.data@proj4string

  tree.fetch <- createTree(coordinates(fetch))

  index.fetch <- knnLookup(tree.fetch, newdat=coordinates(site.data), k=1)

  site.data@data %<>% mutate(windfetch = fetch@data[index.fetch[,1], 'windfetch'])

  }


