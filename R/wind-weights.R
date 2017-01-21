#' Wind weights
#'
#' @param wind.data A SpatialPointsDataFrame containing wind data
#' @param DateTime A string of the name of the column containing DateTime data of class PROIxct.
#' @param years A vector of years to subset data by.
#' @param months A vector of months to subset data by.
#' @param Station A string of the name of the column containing Station data.
#' @param which.station A vector of strings indicating which stations to subset. Default ("All") includes all stations.
#' @param Direction A string of the name of the column containing Direction data.

#' @return One additional column to site.data ('sumfetch') with summed fetch results.
#' @export
wind_weights = function(wind.data, DateTime = "DateTime", Station = "Station", Direction = "Direction",
                        years = 2012:2016, months = 1:12, which.station = "All") {
  check_string(Direction)
  check_string(Station)
  check_string(DateTime)

  if (inherits(wind.data, "SpatialPointsDataFrame") == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if (inherits(wind.data$DateTime, "POSIXct") == FALSE)
    stop ('DateTime column must be POSIxct!')

  station.coords <- sp::remove.duplicates(wind.data)

  station.coords <- station.coords[,Station]

  wind.data %<>% as.data.frame() %<>% na.omit()

  check_cols(wind.data, colnames = c(Direction, Station, DateTime))

  if (which.station == "All") {
    wind.data %<>% subset(lubridate::year(DateTime) %in% years &
                          lubridate::month(DateTime) %in% months)

    wind.data %<>% as.data.frame() %<>% mutate(dum=1)

    wind.data %<>% ddply(.(Station, Direction), summarize, Freq=sum(dum))

    total <-  ddply(wind.data, .(Station), summarize, total=sum(freq))

    wind.data %<>% mutate(Weight = Freq/total$total)

    wind.data %<>% sp::merge(station.coords, by.x = "Station", by.y = "Station")

    return(wind.data)
  }

  if (which.station != "All") {
    wind.data %<>% subset(Station %in% which.station)

    return(wind.data)
  }
}
