#' Convert projection.
#'
#' Convert a data.frame to a SpatialPointsDataFrame with desired CRS.
#' The data.frame must contains the columns X and Y for the x and y coordinates.
#'
#' The default is to convert WGS84 Longitude/Latitude to BC Albers.
#'
#' @param data The data.frame to convert.
#' @param data.CRS PROJ4 string defining current CRS of data.
#' @param new.CRS PROJ4 string of desired CRS.
#'
#' @return A SpatialPointsDataFrame with X and Y transformed to desired CRS.
#' @export
#' @examples
#' convert_proj(data.frame(X = -131.504, Y = 52.871))
convert_proj <- function(data, data.CRS = "+init=epsg:4326", new.CRS = "+init=epsg:3005") {
  check_data2(data, values = c(X = c(1, NA), Y = c(1, NA)))
  check_string(data.CRS)
  check_string(new.CRS)

  if (is.spdf(data) == TRUE)
    warning('data is already a SpatialPointsDataFrame. Check that the coordinates were not already converted to a different CRS.')

  data %<>% as.data.frame()

  sp::coordinates(data) <- c("Long", "Lat")
  proj4string(data) <- sp::CRS(data.CRS)
  sp::spTransform(data, new.CRS)
}
