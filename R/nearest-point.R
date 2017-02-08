#' Find nearest point.
#'
#' Find the nearest point and ID from one SpatialPointsDataFrame to another.
#'
#' Note that the convert_proj function can be used first to convert data to SpatialPointsDataFrame and ensure identical CRS.
#'
#' @param data1 A SpatialPointsDataFrame.
#' @param data2 A SpatialPointsDataFrame.
#'
#' @return One additional column added to data1 indicating distance to nearest point (in units of projection): 'NearestDistance'.
#' @export
nearest_point = function(data1, data2) {

  if (is.spdf(data1) == FALSE | is.spdf(data2) == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if (same.crs(data1, data2) == FALSE)
    stop('data sets must have same CRS! Use convert_proj function first.')

  if(anyDuplicated(data2@coords[1]) > 0)
    # extract only points with unique coordinates
    point.unique <- remove.duplicates(data2)

  if(anyDuplicated(data2@coords[1]) == 0)
    point.unique <- data2

    data1$NearestDistance <- round(apply(rgeos::gDistance(point.unique, data1, byid=TRUE), 1, min), 1)

    return(data1)
  }



