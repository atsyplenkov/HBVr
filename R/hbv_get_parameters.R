#' Download Global HBV Parameter Maps
#'
#' @description This function download Global HBV Parameter Maps (v0.8)
#' created by \emph{Beck et al.} (2020) and crop it to the shapefile
#' boundaries.
#'
#' @param aoi SpatVector. A polygon layer with area of interest.
#' @param folds Numeric. A numeric vector from 1 to 10 indicating the
#' folds numbers to process.
#' @param mean Logical. If TRUE, return mean zonal statistics,
#' calculated using \code{global} method from \code{terra} package
#' @param warp Logical. If TRUE, reproject the HBV rasters to
#'  \code{aoi} projection
#'
#' @return List
#'
#' @references Beck HE, Pan M, Lin P, Seibert J, van Dijk AIJM, Wood EF. 2020. Global Fully Distributed Parameter Regionalization Based on Observed Streamflow From 4,229 Headwater Catchments. Journal of Geophysical Research: Atmospheres 125 : e2019JD031485. DOI: 10.1029/2019JD031485
#'
#' @examples
#'
#' # Load shapefile
#' f <- system.file("ex/lux.shp", package="terra")
#' v <- vect(f)
#'
#' # Get zonal statisitcs
#' fold1_mean <- hbv_get_parameters(v, folds = 1, mean = TRUE, warp = FALSE)
#' fold1_mean
#'
#' # Get rasters
#' fold1_raster <- hbv_get_parameters(v, folds = 1, mean = FALSE, warp = FALSE)
#' plot(fold1_raster[[1]])
#'
#' @export
#'
#' @import terra

hbv_get_parameters <-
  function(aoi,
           folds = 1:10,
           mean = FALSE,
           warp = TRUE){

    # Some check
    stopifnot(
      "Input aoi shape must be polygons" =
        terra::geomtype(aoi) == "polygons"
    )

    stopifnot(
      "Input vector must be numeric" =
        is.numeric(folds)
    )

    stopifnot(
      "Input vector should be in a range from 1 to 10" =
        all(folds %in% c(1:10))
    )

    # List of fold urls
    urls <-
      c("/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_0.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_1.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_2.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_3.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_4.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_5.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_6.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_7.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_8.tiff",
        "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps/correct_fold_9.tiff")

    # Select url for processing
    selected_urls <- urls[folds]
    fold_names <-
      paste0("fold_", c(1:10))[folds]

    # Get shapefiles CRS
    aoi_crs <- terra::crs(aoi, proj = TRUE)
    # Set HBV Parameter maps CRS
    fold_crs <- "+proj=longlat +datum=WGS84 +no_defs"
    # Project shapefile
    aoi_proj <- terra::project(aoi, fold_crs)

    # LOAD COG
    cat("Downloading rasters...\n")
    cogs <-
      selected_urls |>
      pb_fun(function(i) terra::rast(i))

    cat("Cropping rasters...\n")
    cogs_crop <-
      pb_fun(cogs, function(i) terra::crop(i, aoi_proj, mask = TRUE))

    # Set names
    names(cogs_crop) <- fold_names

    # Should we  return raster or mean statistics?
    if (mean) {

        lapply(cogs_crop, function(i) terra::global(i, "mean", na.rm = T))

    } else {

      # Should we project final raster?
      if (warp) {

        cat("Projecting rasters...\n")
        fold_proj <-
          pb_fun(cogs_crop, function(i) terra::project(i, aoi_crs))

        return(fold_proj)

      } else {

        return(cogs_crop)

      }
    }

  }
