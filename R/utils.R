# check SpatialPointsDataFrame
is.spdf <- function(x) {
  is.inherits(x, "SpatialPointsDataFrame")
}

