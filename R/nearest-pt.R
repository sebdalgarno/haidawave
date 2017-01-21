#' Nearest Point
#'
#' @param data1 A SpatialPointsDataFrame.
#' @param data2 A SpatialPointsDataFrame.
#' @param data2.ID A string of the name of the column identifying points in data2. If IDs are not unique, function will remove duplicates.
#'
#' @return Two additional columns to data1: 'nearest.ID' and 'distance'.
#' @export
nearest_pt = function(data1, data2, data2.ID = "pointID") {
  check_string(ID)

  if(inherits(data1, "SpatialPointsDataFrame")|inherits(data2, "SpatialPointsDataFrame"))
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if(identical(data1@proj4string,data2@proj4string)==FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  check_cols(data2, colnames = data2.ID)

  data2 %<>% sp::remove.duplicates()

  data1 %<>% mutate(nearest.ID = data2[apply(rgeos::gDistance(data2, data1, byid = TRUE), 1, which.min), data2.ID]@data,
                      distance = round(apply(rgeos::gDistance(data2, data1, byid=TRUE), 1, min), 1))
}


