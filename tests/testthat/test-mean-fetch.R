context("mean_fetch")

test_that("mean_fetch", {

  x <- mean_fetch(haidawave::laskeek_fetch)

  expect_is(x, "tbl")
  expect_identical(colnames(x), c("Fetch"))
  expect_equal(x$Fetch, 18876.65, tolerance = 0.0000001)
})
