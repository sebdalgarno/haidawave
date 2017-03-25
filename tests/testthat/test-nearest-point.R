context("nearest_point")

test_that("nearest_point", {

  x <- data.frame(X = c(10, 3), Y = c(0, 2))
  y <- data.frame(X = c(5, 2), Y = c(0, 1))

  z <- nearest_point(x, y)

  expect_is(z, "tbl")
  expect_identical(z$X, x$X)
  expect_identical(colnames(z), c("X", "Y", "X.y", "Y.y", "Distance"))
  expect_identical(z$Distance, c(5, sqrt(2)))
})
