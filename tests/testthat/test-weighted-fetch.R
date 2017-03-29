context("weighted_fetch")

test_that("weighted_fetch", {

  x <- haidawave::laskeek_fetch
  x$Weight <- x$Bearing

  x <- weighted_fetch(x)

  expect_is(x, "tbl")
  expect_identical(colnames(x), c("Fetch"))
  expect_equal(x$Fetch, 2027692, tolerance = 0.000001)
})
