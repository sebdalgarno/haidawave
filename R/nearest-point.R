#' Find nearest point.
#'
#' Find the nearest point and ID from one SpatialPointsDataFrame to another.
#'
#' Note that the convert_proj function can be used first to convert data to SpatialPointsDataFrame and ensure identical CRS.
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

  if (utils::is.spdf(data1) == FALSE | is.spdf(data2) == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if (utils::same.crs(data1, data2) == FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  check_cols(data2@data, colnames = data2.ID)

  tree <- SearchTrees::createTree(coordinates(data2))

  index <- SearchTrees::knnLookup(tree, newdat=coordinates(data1), k=1)

  data1@data %<>% dplyr::mutate(nearest.ID = data2@data[index[,1], data2.ID])

  return(data1)
}


