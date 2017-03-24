#' Calculate wind weighting factors for each direction.
#'
#' Calculate weighting factors according to proportion of time that wind blew in a given direction.
#'
#'
#' For this function to work, input data must be SpatialPointsDataFrame. The convert_proj function can be used to achieve that. For use of output in other functions, CRS should be set to be identical to other inputs.
#'
#' @param x A SpatialPointsDataFrame containing wind data
#' @param DateTime A string of the name of the column containing DateTime data of class POSIxct.
#' @param station A string of the name of the column containing names of weather stations.
#' @param direction A string of the name of the column containing wind direction at a given time.
#' @param speed A string of the name of the column containing wind speed at a given time.
#' @param years A vector of years to subset data by.
#' @param months A vector of months to subset data by.
#' @param which.station A vector of strings indicating which stations to subset. Default ("All") includes all stations.
#'
#' @return Weighting factor for fetch bearings based on proportion of time that wind blew in that direction over defined timespan.
#' @export
wind_weights <- function(x)


  DateTime = "DateTime", station = "Station", direction = "Direction", speed = "Speed",
                        years = 2012:2016, months = 1:12, which.station = "All") {
  check_string(direction)
  check_string(speed)
  check_string(station)
  check_string(DateTime)

  if (is.spdf(wind.data) == FALSE)
    stop('data sets must be SpatialPointsDataFrame! Use convert_proj function first.')
  if (inherits(wind.data$DateTime, "POSIXct") == FALSE)
    stop('DateTime column must be POSIxct!')

  check_cols(wind.data@data, colnames = c(direction, speed, station, DateTime))

  colnames(wind.data@coords) <- c("Long", "Lat")

  wind <- as.data.frame(wind.data)

  print(head(wind))
  print(wind[c(direction, speed, station, DateTime)])
  print("colnames")
  print(colnames(wind[c(direction, speed, station, DateTime)]))
  colnames(wind[c(direction, speed, station, DateTime)]) <- c("direction", "speed", "station", "DateTime")
  print(head(wind))
  stop()

  wind %<>% na.omit()

  print(head(wind))
  print(class(wind$DateTime))

  wind %<>% dplyr::filter_(~lubridate::year(DateTime) %in% years &
                     lubridate::month(DateTime) %in% months)

  wind %<>% dplyr::mutate_(dum = ~1) %>%
    dplyr::rename_(spd = ~speed)

  wind %<>% dplyr::group_by_(~station, ~direction) %>%
    dplyr::summarize_(Freq = ~sum(dum), Speed = ~mean(spd), Long = ~dplyr::first(Long), Lat = ~dplyr::first(Lat)) %>%
    dplyr::ungroup()

  total <- dplyr::group_by_(wind, ~station) %>%
    dplyr::summarize_(total = ~sum(Freq)) %>%
    dplyr::ungroup()

  wind %<>% dplyr::mutate_(Weight = ~Freq/total$total * Speed)

  if (which.station == "All") {
    coordinates(wind) <- c("Long", "Lat")
    proj4string(wind) <- wind.data@proj4string
    return(wind)
  }

    colnames(wind)[colnames(wind) == station] <- 'stat'
    wind %<>% dplyr::filter_(~stat %in% which.station)
    colnames(wind)[colnames(wind) == 'stat'] <- station
    coordinates(wind) <- c("Long", "Lat")
    proj4string(wind) <- wind.data@proj4string

    wind
}
