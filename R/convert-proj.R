#' Convert projection.
#'
#' Convert a data.frame to a SpatialPointsDataFrame with desired CRS.
#' The data.frame must contains the columns X and Y for the x and y coordinates.
#'
#' The default is to convert WGS84 Longitude/Latitude to BC Albers.
#'
#' @param x The data.frame to convert.
#' @param data.CRS PROJ4 string defining current CRS of data.
#' @param new.CRS PROJ4 string of desired CRS.
#'
#' @return A tbl with X and Y transformed to desired CRS.
#' @export
#' @examples
#' convert_proj(data.frame(Site = 1, X = c(-131.504), Y = c(52.871)))
convert_proj <- function(x, data.CRS = "+init=epsg:4326", new.CRS = "+init=epsg:3005") {
  check_data2(x, values = list(X = 1, Y = 1))
  check_string(data.CRS)
  check_string(new.CRS)

  if (is.spdf(x))
    warning('x is already a SpatialPointsDataFrame. Check that the coordinates were not already converted to a different CRS.', call. = FALSE)

  x %<>% as.data.frame()

  sp::coordinates(x) <- c("X", "Y")
  proj4string(x) <- sp::CRS(data.CRS)
  x %<>% sp::spTransform(new.CRS) %<>% as.data.frame() %>% dplyr::as.tbl()
  x
}
