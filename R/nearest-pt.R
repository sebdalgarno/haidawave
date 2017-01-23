#' For each point in a data set, find the nearest point from a second data set.
#'
#' @param data1 A SpatialPointsDataFrame.
#' @param data2 A SpatialPointsDataFrame.
#' @param data2.ID A string of the name of the column in data2 with ID. If IDs are not unique, function will remove duplicates.
#'
#' @return One additional column added to data1: 'nearest.ID'.
#' @export
nearest_point = function(data1, data2, data2.ID = "PointID") {
  check_string(data2.ID)
  check_unique(data2.ID)

  if(inherits(data1, "SpatialPointsDataFrame") == FALSE|inherits(data2, "SpatialPointsDataFrame") == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if(identical(data1@proj4string,data2@proj4string) == FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  check_cols(data2@data, colnames = data2.ID)

  tree <- createTree(coordinates(data2))

  index <- knnLookup(tree, newdat=coordinates(data1), k=1)

  data1@data %<>% mutate(nearest.ID = data2@data[index[,1], data2.ID])
}


