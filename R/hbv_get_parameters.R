#' Download Global HBV Parameter Maps
#'
#' @description This function download Global HBV Parameter Maps
#' created by \emph{Beck et al.} (\href{https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019JD031485}{2020})
#' and crop it to the shapefile boundaries. See
#' \href{http://www.gloh2o.org/hbv/}{GloH2O website} for details.
#'
#' @param AOI SpatVector. A polygon layer with area of interest.
#' @param folds Numeric. A numeric vector from 1 to 10 indicating the
#' folds numbers to process.
#' @param mean Logical. If TRUE, return mean zonal statistics,
#' calculated using \code{\link[terra]{global}} method from \pkg{terra} package
#' @param warp Logical. If TRUE, reproject the HBV rasters to
#'  \code{AOI} projection
#' @param version Character. Can be used to determine the dataset version. Must be
#' one of "v0.8" (original release from February 5, 2020) or "v0.9" (revised version
#' from May 5, 2020). See details.
#'
#' @details Version history (according to \href{http://www.gloh2o.org/hbv/}{GloH2O website}):
#'
#' \describe{
#'   \item{V0.9 (May 5, 2022)}{To avoid local minima, the authors reduced the number
#'   of predictors to three and increased the number of generations to 2000. A selection
#'   was made based on which predictors individually provided the best training score:
#'   snowfall fraction of precipitation (\code{FSNOW}), mean topographic slope (\code{SLOPE}),
#'   and soil clay content (\code{CLAY}). Increasing the number of generations to 2000
#'   allowed the algorithm to find the true optimum, while lowering the spatial
#'   resolution from 0.05° to 0.1° reduced computational requirements.}
#'   \item{V0.8 (February 5, 2020)}{Original release corresponding to \emph{Beck et al.}
#'   (\href{https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019JD031485}{2020}).}
#' }

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
  function(AOI,
           folds = 1:10,
           mean = FALSE,
           warp = TRUE,
           version = "v0.9"){

    # Convert to SpatVect object
    if (any(class(AOI) %in% c("sf", "sfc", "sfg"))) {
      aoi <- terra::vect(AOI)
    } else {
      aoi <- AOI
    }

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

    # Check the dataset version
    if (version == "v0.9") {

      urls <-
        c("/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_0.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_1.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_2.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_3.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_4.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_5.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_6.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_7.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_8.tiff",
          "/vsicurl/https://github.com/atsyplenkov/HBVr/releases/download/parameter-maps-v09/fold_9.tiff")

    } else if (version == "v0.8") {

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

    } else {

      stop("Dataset version should either 'v0.8' or 'v0.9'. See help ?hbv_get_parameters")

    }

    # Select url for processing
    selected_urls <- urls[folds]
    fold_names <-
      paste0("fold_", c(0:9))[folds]

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

    # Fix for version v0.8 dataset
    if (version == "v0.8") {

      list_to_upper <-
        function(x){

          names(x) <-
            toupper(names(x))

          x
        }

      cogs_crop <- lapply(cogs_crop, list_to_upper)

    }

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
