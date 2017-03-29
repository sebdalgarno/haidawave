#' Calculate fetch.
#'
#' Calculates mean fetch.
#'
#' @param x A data frame with the column Fetch.
#' @param max_fetch A number indicating the maximum fetch distance to consider.
#' @return A data frame with a single row and column Fetch indicating the mean fetch.
#' @examples
#' mean_fetch(haidawave::laskeek_fetch)
#' @export
mean_fetch <- function(x, max_fetch = 2 * 10^5) {
  check_data2(x, values = list(Fetch = c(0, 10^12)))
  check_number(max_fetch, c(0, 10^12))

  x$Fetch[x$Fetch > max_fetch] <- max_fetch
  dplyr::data_frame(Fetch = mean(x$Fetch))
}
