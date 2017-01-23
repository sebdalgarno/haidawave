#' Given wind data, subset to a certain period of years and/or months and calculate the proportion of time that wind blew in each direction.
#'
#' @param wind.data A SpatialPointsDataFrame containing wind data
#' @param DateTime A string of the name of the column containing DateTime data of class POSIxct.
#' @param station A string of the name of the column containing names of weather stations.
#' @param direction A string of the name of the column containing wind direction at a given time.
#' @param years A vector of years to subset data by.
#' @param months A vector of months to subset data by.
#' @param which.station A vector of strings indicating which stations to subset. Default ("All") includes all stations.
#'

#' @return Weighting factor for fetch bearings based on proportion of time that wind blew in that direction over defined timespan.
#' @export
wind_weights = function(wind.data, DateTime = "DateTime", station = "Station", direction = "Direction",
                        years = 2012:2016, months = 1:12, which.station = "All") {
  check_string(direction)
  check_string(station)
  check_string(DateTime)

  if (inherits(wind.data, "SpatialPointsDataFrame") == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if (inherits(wind.data$DateTime, "POSIXct") == FALSE)
    stop ('DateTime column must be POSIxct!')

  station.coords <- sp::remove.duplicates(wind.data)

  station.coords <- station.coords[,station]

  wind.data %<>% as.data.frame() %<>% na.omit()

  check_cols(wind.data, colnames = c(direction, station, DateTime))

  if (which.station == "All") {
    wind.data %<>% subset(lubridate::year(DateTime) %in% years &
                          lubridate::month(DateTime) %in% months)

    wind.data %<>% mutate(dum=1)

    wind.data %<>% ddply(c(station, direction), summarize, Freq = sum(dum))

    total <-  ddply(wind.data, station, summarize, total = sum(Freq))

    wind.data %<>% mutate(Weight = Freq/total$total)

    wind.data %<>% sp::merge(station.coords, by.x = station, by.y = station)

    coordinates(wind.data) <- colnames(station.coords@coords)

    proj4string(wind.data) <- station.coords@proj4string

    return(wind.data)
  }

  if (which.station != "All") {
    wind.data %<>% subset(station %in% which.station)

    coordinates(wind.data) <- colnames(station.coords@coords)

    proj4string(wind.data) <- station.coords@proj4string

    return(wind.data)
  }
}
