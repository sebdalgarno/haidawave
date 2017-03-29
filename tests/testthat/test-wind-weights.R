context("wind_weight")

test_that("convert_proj", {

  x <- wind_weights(haidawave::cumshewa_wind)

  expect_is(x, "tbl")
  expect_identical(colnames(x), c("Direction", "Frequency", "Speed", "Weight"))
  expect_identical(nrow(x), 36L)
  expect_identical(sum(x$Weight), 1)
})
