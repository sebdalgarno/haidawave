#' Joins y to x and y based on their X and Y coordinates.
#'
#' Joins x to y based on minimising the euclidean distance between their X and Y coordinates.
#' As a result each row in x is assigned the closest row in y.
#'
#' Note the convert_proj function can be used to ensure the X and Y coordinates are in the same projection.
#'
#' @param x A data frame with the columns X and Y.
#' @param y A data frame with the columns X and Y.
#' @inheritParams dplyr::join
#' @return The joined data frame with the additional column Distance indicating the distance between the X and Y coordinates.
#' @export
nearest_point <- function(x, y, suffix = c(".x", ".y")) {
  check_data2(x, values = list(X = 1, Y = 1))
  check_data2(y, values = list(X = 1, Y = 1))

  x$..ID <- 1:nrow(x)

  x %<>% merge(y, by = NULL, suffixes = suffix) %>%
    dplyr::mutate_(Distance = ~sqrt((X.x - X.y)^2 + (Y.x - Y.y)^2)) %>%
    plyr::ddply("..ID", function(x) dplyr::slice_(x, ~which.min(Distance))) %>%
    dplyr::rename_(X = ~X.x, Y = ~Y.x) %>%
    dplyr::select_(~-..ID)
  dplyr::as.tbl(x)
}
