#' Symbolize raster data as a three band PNG
#'
#' @param tiff Input tiff file; optional see rast for alternative
#' @param png Output png file path.
#' @param col_palette Color palette. Matrix of 256 colors (rows) and three (rgb)
#' columns indicating colors.   
#' @param overwrite If `TRUE` overwrite pre-existing colors 
#' @param max_value The maximum possible value to represent in the color 
#' gradient
#' 
#' @param rast A `terra::SpatRaster` object with the data to write
#'
#' @return
#' @export
#'
#' @examples
symbolize_raster_data <- function(tiff = NULL, 
                                  png, 
                                  col_palette, 
                                  overwrite = TRUE, 
                                  max_value = NULL, 
                                  rast = NULL) {

  
  
  stopifnot(isTRUE(all.equal(dim(col_palette), c(256, 3))))
  
  if(is.null(tiff) && is.null(rast)) {
    stop("Either tiff or rast arguments must be used")
  }
  
  if (is.null(tiff)) {
    r <- rast
    stopifnot(inherits(r, "SpatRaster"))
  } else {
    r <- terra::rast(tiff)
  }
  
  if (is.null(max_value))
    max_value <- max(values(r), na.rm = TRUE)
  
  v <- values(r) 
  v2 <-  range_rescale(v, min_value = 0, max_value = max_value) 
  v2 <- v2 * 255 + 1
  vc <- col_palette[v2, ]
  vc[v == 0, ] <- NA  # Make zeros transparent
  
  red <- green <- blue <- r
  values(red) <- vc[, 1]
  values(blue) <- vc[, 2]
  values(green) <- vc[, 3]
  rgb <- c(red, blue, green)
  
  terra::RGB(rgb) <- 1:3
  
  terra::writeRaster(rgb, filename = png, filetype = "PNG", 
                     datatype = "INT1U", overwrite = overwrite)
  return(invisible())
}
