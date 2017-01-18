#' Convert Proj
#'
#' @param data The data.frame to convert.
#' @param data.x A string of the name of the column containing the longitude.
#' @param data.y xx
#' @param data.CRS xx
#' @param new.CRS xx
#'
#' @return A SpatialPointsDataFrame with
#' @export
convert_proj <- function(data, data.x = "Long", data.y = "Lat", data.CRS = "+init=epsg:4326", new.CRS = "+init=epsg:3005") {
  check_string(data.x)
  check_string(data.y)
  check_string(data.CRS)
  check_string(new.CRS)

  if (inherits(data, "SpatialPointsDataFrame"))
    warning('data is already a SpatialPointsDataFrame. Check that the coordinates were not already converted to a different CRS.')

  data %<>% as.data.frame()

  check_cols(data, colnames = c(data.x, data.y))

  sp::coordinates(data) <- c(data.x, data.y)
  proj4string(data) <- sp::CRS(data.CRS)
  sp::spTransform(data, new.CRS)
}
