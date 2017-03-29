context("convert_proj")

test_that("convert_proj", {

  x <- convert_proj(data.frame(Site = 1, X = c(-131.504), Y = c(52.871)))

  expect_is(x, "tbl")
  expect_identical(colnames(x), c("Site", "X", "Y"))
  expect_equal(x$X, 630627.1, tolerance = 0.000001)
})
