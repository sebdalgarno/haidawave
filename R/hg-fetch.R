fetch_fetch <- function(n) {
  readr::read_csv(paste0("https://raw.githubusercontent.com/sebdalgarno/haidawave-data/master/haidagwaii-fetch-", n, ".csv"),
                  col_types = cols(
                    Easting = col_double(),
                    Northing = col_double(),
                    bearing5 = col_double(),
                    bearing10 = col_double(),
                    bearing15 = col_double(),
                    bearing20 = col_double(),
                    bearing25 = col_double(),
                    bearing30 = col_double(),
                    bearing35 = col_double(),
                    bearing40 = col_double(),
                    bearing45 = col_double(),
                    bearing50 = col_double(),
                    bearing55 = col_double(),
                    bearing60 = col_double(),
                    bearing65 = col_double(),
                    bearing70 = col_double(),
                    bearing75 = col_double(),
                    bearing80 = col_double(),
                    bearing85 = col_double(),
                    bearing90 = col_double(),
                    bearing95 = col_double(),
                    bearing100 = col_double(),
                    bearing105 = col_double(),
                    bearing110 = col_double(),
                    bearing115 = col_double(),
                    bearing120 = col_double(),
                    bearing125 = col_double(),
                    bearing130 = col_double(),
                    bearing135 = col_double(),
                    bearing140 = col_double(),
                    bearing145 = col_double(),
                    bearing150 = col_double(),
                    bearing155 = col_double(),
                    bearing160 = col_double(),
                    bearing165 = col_double(),
                    bearing170 = col_double(),
                    bearing175 = col_double(),
                    bearing180 = col_double(),
                    bearing185 = col_double(),
                    bearing190 = col_double(),
                    bearing195 = col_double(),
                    bearing200 = col_double(),
                    bearing205 = col_double(),
                    bearing210 = col_double(),
                    bearing215 = col_double(),
                    bearing220 = col_double(),
                    bearing225 = col_double(),
                    bearing230 = col_double(),
                    bearing235 = col_double(),
                    bearing240 = col_double(),
                    bearing245 = col_double(),
                    bearing250 = col_double(),
                    bearing255 = col_double(),
                    bearing260 = col_double(),
                    bearing265 = col_double(),
                    bearing270 = col_double(),
                    bearing275 = col_double(),
                    bearing280 = col_double(),
                    bearing285 = col_double(),
                    bearing290 = col_double(),
                    bearing295 = col_double(),
                    bearing300 = col_double(),
                    bearing305 = col_double(),
                    bearing310 = col_double(),
                    bearing315 = col_double(),
                    bearing320 = col_double(),
                    bearing325 = col_double(),
                    bearing330 = col_double(),
                    bearing335 = col_double(),
                    bearing340 = col_double(),
                    bearing345 = col_double(),
                    bearing350 = col_double(),
                    bearing355 = col_double(),
                    bearing360 = col_double()
                  ))
}

#' Haida Gwaii Fetch
#'
#' Downloads and binds the eight fetch datasets from \url{https://raw.githubusercontent.com/sebdalgarno/haidawave-data/master/}.
#'
#' Points were generated within a GIS spaced 10m along 1:50,000 ShoreZone vector coastline data (Howes et al. 1994).
#' From each point, fetch distance (i.e. distance from point to nearest ShoreZone coastline) was calculated at 5 degree intervals using
#' the java-based software - 'Vector_fetch' - developed by Mika Murtojarvi (Murtojarvi et al. 2007).
#' Since ShoreZone vector coastline data were limited to BC, fetch distances are only accurate to 200,000 m.
#'
#' # ## References
# Howes, D., J. Harper, and E. Owens. 1994. Physical shore-zone mapping system for British Columbia. Resources Inventory Committee Publication 8:71.
#
# Murtojarvi, M., T. Suominen, H. Tolvanen, V. Leppanen, and O. S. Nevalainen. 2007. Quantifying distances from points to polygons: applications in determining fetch in coastal environments. Computers & Geosciences 33:843–852.
#'
#' @return A tbl with the columns Station, DateTime, Direction, Speed, Long and Lat.
#' @export
hg_fetch <- function() {
  fetch <- 1:8

  fetch %<>% plyr::ldply(fetch_fetch) %>%
    tidyr::gather_("Bearing", "Fetch", paste0("bearing", seq(5, 360, by = 5)))

  fetch$Bearing %<>% stringr::str_replace("bearing", "") %>%
    as.numeric()
  dplyr::as.tbl(fetch)
}
