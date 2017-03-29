#' Calculate weighted mean fetch.
#'
#' Calculates weighted mean fetch.
#'
#' @param x A data frame with the columns Fetch and Weight.
#' @param max_fetch A number indicating the maximum fetch distance to consider.
#' @return A data frame with a single row and column Fetch indicating the mean fetch.
#' @export
weighted_fetch <- function(x, max_fetch = 2 * 10^5) {
  check_data2(x, values = list(Fetch = c(0, 10^12), Weight = c(0, 10^12)))
  check_number(max_fetch, c(0, 10^12))

  fetch <- x$Fetch
  fetch[fetch > max_fetch] <- max_fetch
  weight <- x$Weight
  dplyr::data_frame(Fetch = mean(fetch * weight))
}
