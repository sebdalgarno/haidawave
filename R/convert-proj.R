#' Convert data.frame to SpatialPointsDataFrame and convert to a new CRS if necessary.
#'
#' @param data The data.frame to convert.
#' @param data.x A string of the name of the column containing the longitude.
#' @param data.y A string of the name of the column containing the latitude.
#' @param data.CRS PROJ4 string defining current CRS of data.x and data.y.
#' @param new.CRS PROJ4 string of desired CRS.
#'
#' @return A SpatialPointsDataFrame with data.x and data.y transformed to desired CRS.
#' @export
convert_proj <- function(data, data.x = "Long", data.y = "Lat", data.CRS = "+init=epsg:4326", new.CRS = "+init=epsg:3005") {
  check_string(data.x)
  check_string(data.y)
  check_string(data.CRS)
  check_string(new.CRS)

  if (inherits(data, "SpatialPointsDataFrame") == TRUE)
    warning('data is already a SpatialPointsDataFrame. Check that the coordinates were not already converted to a different CRS.')

  data %<>% as.data.frame()

  check_cols(data, colnames = c(data.x, data.y))

  sp::coordinates(data) <- c(data.x, data.y)
  proj4string(data) <- sp::CRS(data.CRS)
  sp::spTransform(data, new.CRS)
}
