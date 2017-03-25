#' Calculate wind weighting for each provided direction.
#'
#' Calculates weighting based on wind direction and speed.
#' It takes a data frame and returns a tbl with the columns Direction,
#' Frequency (number of intervals spent blowing in that direction),
#' Speed (the average speed when blowing in that direction) and
#' Weight ()
#'
#' @param x A data frame with the columns Direction and Speed.
#' @return A tbl with the columns Direction, Frequency, Speed and Weight.
#' @examples
#' wind_weights(haidawave::cumshewa_wind)
#' @export
wind_weights <- function(x) {
  check_data2(x, values = list(Direction = c(0, 360), Speed = c(0, 1000)))

  x %<>% dplyr::group_by_(~Direction) %>%
    dplyr::summarize_(Frequency = ~n(), Speed = ~mean(Speed), Weight = ~sum(Speed)) %>%
    dplyr::ungroup()

  x$Weight %<>% magrittr::divide_by(., sum(.))
  x %<>% dplyr::arrange_(~Direction)

  x
}
