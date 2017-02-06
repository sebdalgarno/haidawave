#' Calculate mean fetch at sites.
#'
#' Set maximum fetch distance and assign mean fetch from nearest point.
#'
#' For this function to work, input data must be SpatialPointsDataFrame with identical CRS. The convert_proj function can be used to achieve that.
#' Note that it is not necessary to run the nearest_point function prior to this one.
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame with columns containing unique ID, bearing, and fetch distance, along with coordinates.
#' @param max.distance An integer indicating desired maximum fetch distance (in metres).

#' @return Two additional columns to site.data: 'nearest.pt' contains unique ID of nearest fetch.data point; 'sumfetch' contains summed fetch results.
#' @export
mean_fetch = function(site.data, fetch.data, max.distance = 200000) {
  check_number(max.distance)

  if(is.spdf(site.data) == FALSE|is.spdf(fetch.data)  == FALSE)
    stop('Data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if(same.crs(site.data, fetch.data) == FALSE)
    stop('Data sets must have same CRS! Use convert_proj function first.')
  if(max.distance > 200000)
    warning('Fetch distances are only accurate to a maximum of 200,000 m.')

  colnames(fetch.data@coords) <- c("X", "Y")

  # melt
  fetch <- as.data.frame(fetch.data) %>%

    mutate(PointID = 1:nrow(fetch.data)) %>%

    melt(id.vars=c("X", "Y", "PointID"), variable.name = "Bearing", value.name = "Distance") %>%

    mutate(Bearing = as.character(Bearing),
           Bearing = gsub("X", "", Bearing),
           Bearing = as.numeric(Bearing)) %>%

    mutate(Distance = replace(Distance, Distance > max.distance, max.distance))

  fetch %<>% plyr::ddply('PointID', summarize, meanfetch = mean(Distance), X = dplyr::first(X), Y = dplyr::first(Y))

  coordinates(fetch) <- c("X", "Y")
  proj4string(fetch) <- fetch.data@proj4string

  tree <- SearchTrees::createTree(coordinates(fetch))

  index <- SearchTrees::knnLookup(tree, newdat=coordinates(site.data), k=1)

  site.data$meanfetch <- fetch@data[index[,1], 'meanfetch']

  return(site.data)

}
