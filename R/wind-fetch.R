#' Calculate wind-altered summed fetch.
#'
#' Set maximum fetch distance, find fetch lines from nearest point, weight fetch lines according to conditions at nearest weather station, calculate wind-altered summed fetch.
#'
#' Input data must be SpatialPoints with identical CRS. The convert_proj function can be used to achieve that.
#' If weighting factors (weights.data) are generated using the wind_weights function, the user will not have to change the default argument names (weights.station, weights.direction, weights).
#' Note that it is not necessary to run the nearest_point function first.
#'
#' @param site.data A SpatialPoints object containing sites that require estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame of sites with a column indicating fetch bearing and a column indicating fetch distance.
#' @param weights.data A SpatialPointsDataFrame including columns indicating station name, direction and weighting factor.
#' @param weights.station A string of the name of the column containing names of weather stations.
#' @param weights.direction A string of the name of the column containing wind direction.
#' @param weights A string of the name of the column containing wind weighting factors for each direction.
#' @param max.distance An integer indicating desired maximum distance of fetch calculations (in metres).

#' @return One additional column to site.data ('WindFetch') with wind-altered summed fetch results.
#' @export
wind_fetch=function(site.data, fetch.data, weights.data, weights.station = "Station",
                    weights.direction = "Direction", weights = "Weight", max.distance = 200000) {

  check_string(weights.direction)
  check_string(weights.station)
  check_string(weights)
  check_number(max.distance)

  if (is.spdf(site.data) == FALSE | is.spdf(fetch.data) == FALSE | is.spdf(weights.data) == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if (same.crs(site.data, fetch.data) == FALSE | same.crs(fetch.data, weights.data) == FALSE)
    stop('data sets must have same CRS! Use convert function first.')
  if(max.distance > 200000)
    warning('Fetch distances are only accurate to a maximum of 200,000 m.')

  check_cols(weights.data@data, colnames = c(weights.direction, weights, weights.station))

  colnames(fetch.data@coords) <- c("X", "Y")
  colnames(weights.data@data)[colnames(weights.data@data) == weights] <- 'weights'

  # find nearest fetch point
  tree <- SearchTrees::createTree(coordinates(fetch.data))

  index <- SearchTrees::knnLookup(tree, newdat=coordinates(site.data), k=1)

  fetch.near <- fetch.data[index[,1], ]

  fetch <- as.data.frame(fetch.near) %>%

    mutate_(ID = ~1:nrow(fetch.near)) %>%

    melt(id.vars=c("X", "Y", 'ID'), variable.name = "Bearing", value.name = "Distance") %>%

    mutate_(Bearing = ~as.character(Bearing),
            Bearing = ~gsub("bearing", "", Bearing),
            Bearing = ~as.numeric(Bearing)) %>%

    mutate_(Distance = ~replace(Distance, Distance > max.distance, max.distance))

  coordinates(fetch) <- c('X', 'Y')
  proj4string(fetch) <- fetch.data@proj4string

  # find nearest weather station
  tree.wind <- SearchTrees::createTree(coordinates(weights.data))

  index.wind <- SearchTrees::knnLookup(tree.wind, newdat=coordinates(fetch), k=1)

  fetch@data %<>% dplyr::mutate_(Station = ~weights.data@data[index.wind[,1], weights.station])

  fetch %<>% as.data.frame() %>%

    base::merge(weights.data@data, by.x = c('Station', 'Bearing'), by.y = c(weights.station, weights.direction)) %>%

    # calculate weighted distance
    dplyr::mutate_(weight.dist = ~Distance*weights)  %>%

    dplyr::group_by_(~ID) %>% dplyr::summarize_(windfetch = ~round(mean(weight.dist), 0)) %>%
    dplyr::ungroup()

  site.data$WindFetch <- fetch$windfetch

  return(site.data)

}
