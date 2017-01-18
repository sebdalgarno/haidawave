context("convert_proj")

test_that("convert_proj", {

  data <- data.frame(Long = -131, Lat = 53)

  expect_is(convert_proj(data), "SpatialPoints")
})
