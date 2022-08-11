library(terra)

# Load shapefile
f <- system.file("ex/lux.shp", package="terra")
v <- vect(f)

fold1_raster <- hbv_get_parameters(v, folds = 1, mean = F, warp = F)
fold1_mean <- hbv_get_parameters(v, folds = 1, mean = T, warp = F)

test_that("List is returned", {
  expect_true(is.list(fold1_mean))
})

test_that("SpatRaster is returned", {
  expect_true(class(fold1_raster[[1]]) == "SpatRaster")
})

test_that("Fold number is out of range",{

  expect_error(
    hbv_get_parameters(v,
                       folds = 11,
                       mean = T,
                       warp = F)
  )

})
