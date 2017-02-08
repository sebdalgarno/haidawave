#' Calculate mean fetch at sites.
#'
#' Set maximum fetch distance and assign mean fetch from nearest point.
#'
#' Input data must be SpatialPoints with identical CRS. The convert_proj function can be used to achieve that.
#' Note that it is not necessary to run the nearest_point function first.
#'
#' @param site.data A SpatialPointsDataFrame of sites requiring estimates of wave exposure.
#' @param fetch.data A SpatialPointsDataFrame with fetch distance data.
#' @param max.distance An integer indicating desired maximum fetch distance (in metres).

#' @return One additional column (MeanFetch) to site.data with mean fetch distance of nearest fetch point.
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

  tree <- SearchTrees::createTree(coordinates(fetch.data))

  index <- SearchTrees::knnLookup(tree, newdat=coordinates(site.data), k=1)

  fetch.near <- fetch.data[index[,1], ]

  fetch <- as.data.frame(fetch.near) %>%

    mutate(ID = 1:nrow(fetch.near)) %>%

    melt(id.vars=c("X", "Y", 'ID'), variable.name = "Bearing", value.name = "Distance") %>%

    mutate(Bearing = as.character(Bearing),
           Bearing = gsub("bearing", "", Bearing),
           Bearing = as.numeric(Bearing)) %>%

    mutate(Distance = replace(Distance, Distance > 200000, 200000)) %>%

    plyr::ddply('ID', summarize, meanfetch = round(mean(Distance), 0))

  site.data$MeanFetch <- fetch$meanfetch

  return(site.data)
}
