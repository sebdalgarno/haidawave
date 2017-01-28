

# check SpatialPointsDataFrame
is.spdf <- function(x) {
  inherits(x, "SpatialPoints")
}


# check identical CRS
same.crs <- function(x,y) {
  identical(x@proj4string, y@proj4string)
}

