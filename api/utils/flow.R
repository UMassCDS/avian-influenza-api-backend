if(FALSE) {
   # Manually set function arguments for dev and debugging
   # Running code here allows running function body code outside of the
   # function definition (line by line)
   
   
   ## Setup - duplicates loading done in entrypoint.R
   # Change the working directory to "api" before sourcing so relative paths in 
   # the other files are correct
   
   
   # Load required libraries
   library(BirdFlowR)
   library(paws)
   library(jsonlite)
   library(terra)
   library(digest)

   # Load globals and helpers
   original_wd <- getwd()
   if(!grepl("api$", getwd()))
      setwd("api")
   source("config/globals.R")
   source("utils/helpers.R")
   source("utils/symbolize_raster_data.R")
   source("utils/save_json_palette.R")
   source("utils/range_rescale.R")
   setwd(original_wd)

   # Set example arguments values as R objects 
   taxa <- "mallar3"
   taxa <- "total"  # all taxa
   week = 15
   date <- "2022-01-01"
   lat <- 42
   lon <- -70
   loc <- 
   direction <- "forward"
   n <- 10 # prob 20 when deployed
   loc <- "1,2;3,4;12.12,-13.13" # test multi-point
   loc <- paste0(lat, ",", lon)
}



#' Implement inflow and outfow
#' 
#' This function is the heart of the inflow and outflow api and does all 
#' the work. It is wrapped by both of those endpoints
#'
#' @param taxa a taxa.  Should be either "total" (sum across all species) or 
#' one of the species listed in config/taxa.json 
#' @param loc One or more locations as a scalar character each location should
#' be latitude and longitude separated by a comma, multiple locations are separated by 
#' a semicolon  e.g. "42,-72"   or "42,-72;43.4,-72.7"
#' @param n The number of weeks to project forward (note output will include
#' the initial week so will have n + 1 images)
#' @param week The week number to start at.
#' @param direction Which direction to project in "backward" for inflow or 
#' "forward" for outflow"
#' @returns A list with components:
#' 
#' `start` a list with:  
#'    `week`  as input
#'    `taxa`, as input
#'    `loc`,  as input
#'    `type` - "inflow" or "outflow"
#' `status` either: "success", "error", "outside mask"
#' `result` a list of information about the images each item includes
#'    `week`
#'    `url`  
#'    `legend` 
flow <- function( loc, week, taxa, n, direction = "forward") {

   format_error <- function(message, status = "error") {
     list( start = list(
        week = week,
        taxa = taxa,
        loc = loc
     ),
     status = status, 
     message = message)
      
   }
   
   log_progress <- function(msg) {
     cat(sprintf("[%s] %s\n", Sys.time(), msg), file = "/tmp/flow_debug.log", append = TRUE)
   }
   
  log_progress("Starting flow function")
  # Convert location into lat,lon data frame   
  lat_lon  <- strsplit(loc, ";") |> 
     unlist() |>
     strsplit(split = ",") |>
     do.call(rbind, args = _) |> 
     as.data.frame() 
  for(i in seq_len(ncol(lat_lon)))
     lat_lon[ , i] <- as.numeric(lat_lon[, i])
  names(lat_lon) <- c("lat", "lon")
  
 
  if(!taxa %in% (c(species$species, "total"))) {
     return(format_error("invalid taxa"))
  }

     
  if(!week %in% as.character(1:52)) 
     return(format_error("invalid week"))
  week <- as.numeric(week)
  
  if(!n %in% as.character(1:52))
     return(format_error("invalid n"))
  n <- as.numeric(n)
   
  if(!direction %in% c("forward", "backward")) 
    return(format_error("invalid direction - should be forward or backward"))
 
  
  if(direction == "forward") {
     flow_type <- "outflow" 
  } else {
     flow_type <- "inflow"
  }
  
  # Set unique ID and output directory for this API call (RAM disk)
  raw_lat <- paste(lat_lon$lat, collapse = "_")
  raw_lon <- paste(lat_lon$lon, collapse = "_")
  param_string <- paste(
    raw_lat,
    raw_lon,
    week, taxa, direction, flow_type, n,
    sep = "_"
  )
  unique_id <- digest(param_string, algo = "md5")
  out_path <- file.path("/dev/shm", unique_id)
  dir.create(out_path, recursive = TRUE)
  if(!file.exists(out_path))
     return(format_error("Could not create output directory in RAM (/dev/shm)"))
  
  # Define list of target species
  # Will either be a single species or a vector of all
  target_species <- if(taxa == "total") {
     target_species <- species$species
  } else { 
     target_species <- taxa
  }
  
  # Create prediction rasters for all target species 
  skipped <- rep(FALSE, length(target_species))
  rasters <- vector(mode = "list", length(target_species))
  for(i in seq_along(target_species)) {
     sp <- target_species[i]
     
     # Local copy of BirdFlow model  
     bf <- models[[sp]]
     
     # Initial distribution
     xy <- latlon_to_xy(lat_lon$lat, lat_lon[, 2],  bf = bf) 
     
     
     # Check for valid starting location(s) 
     # skip species without
     valid <- is_location_valid(bf, timestep = week, x = xy$x, y = xy$y)
     if(!all(valid)){
        skipped[i] <- TRUE
        next
     }
     
     start_distr <- as_distr(xy, bf, )
     if(nrow(lat_lon) > 1) {
        # If multiple xy  start distribution will contain multiple 
        # one-hot distributions in a matrix
         start_distr <- apply(start_distr, 1, sum)
         start_distr <- start_distr / sum(start_distr)
     }

     log_progress(paste("Starting prediction for species:", sp, "week:", week))
     pred <- predict(bf, 
                     start_distr, 
                     start = week, 
                     n = n, 
                     direction = direction)
     
     # Proportion of population in starting location
     location_i <- xy_to_i(xy, bf = bf)
     initial_population_distr <- get_distr(bf, which = week)
     start_proportion <- initial_population_distr[location_i] / 1
     
     # Convert to Birds / sq km
     abundance <- pred * species$population[species$species == sp] / 
        prod(res(bf)/1000) * start_proportion
    
     r <- rasterize_distr(abundance, bf = bf, format = "terra")
     
     rasters[[i]] <- r
  }
  
  # Drop any models that were skipped (due to invalid starting location & date)
  if(all(skipped)) {
     return(format_error("Invalid starting location",  "outside mask"))
  }
  rasters <- rasters[!skipped]
  used_species <- target_species[!skipped]
  
  # If multiple species combine by summing 
  combined <- rasters[[1]]
  if (length(rasters) > 1) {
     for(i in 2:length(rasters)) {
        combined <- combined + rasters[[i]]
     }
  }

  log_progress("Before writing TIFF")
  tiff_file <- paste0(flow_type, "_", unique_id, ".tif")
  tiff_path <- file.path(out_path, tiff_file)
  tiff_bucket_path <- paste0(s3_flow_path, tiff_file)
  terra::writeRaster(combined, tiff_path, overwrite = TRUE, filetype = 'GTiff')
  log_progress("After writing TIFF")
  
  # Upload TIFF to S3 and delete local file
  s3 <- paws::s3()
  s3$put_object(Bucket = s3_bucket_name,
                Key = tiff_bucket_path,
                Body = readBin(tiff_path, "raw", file.info(tiff_path)$size))
  file.remove(tiff_path)
  
  # Convert to web mercator and crop
  web_raster <- combined |> 
     terra::project(ai_app_crs$input) |> 
     terra::crop(ai_app_extent)
  
  #----------------------------------------------------------------------------#
  # Write out symbolized png files and symbology file (json) 
  # Each week has a separate pair of files
  #----------------------------------------------------------------------------#
  
  # Set paths
  pred_weeks <- lookup_timestep_sequence(bf, start = week, n = n, direction = direction)
  png_files <- paste0(flow_type, "_", unique_id, "_", pred_weeks, ".png") 
  symbology_files <- paste0(flow_type, "_", unique_id, "_", pred_weeks, ".json") 
  png_paths <- file.path(out_path, png_files)
  symbology_paths <- file.path(out_path, symbology_files)
  png_urls <- paste0(s3_flow_url, unique_id, "/",  png_files) 
  symbology_urls <- paste0(s3_flow_url, unique_id, "/", symbology_files)
  png_bucket_paths <- paste0(s3_flow_path, unique_id, "/", png_files)
  symbology_bucket_paths <- paste0(s3_flow_path, unique_id, "/", symbology_files)

  # Write, upload, and delete PNG/JSON files one by one
  for(i in seq_along(pred_weeks)){
     week <- pred_weeks[i]
     week_raster <- web_raster[[i]]
     max_val <- terra::minmax(week_raster)[2]
     symbolize_raster_data(png = png_paths[i], col_palette = flow_colors,
                           rast = week_raster, max_value = max_val)
     save_json_palette(symbology_paths[i], max = max_val, col_matrix = flow_colors)

     # Upload PNG and JSON to S3 and delete local files
     s3$put_object(Bucket = s3_bucket_name,
                   Key = png_bucket_paths[i],
                   Body = readBin(png_paths[i], "raw", file.info(png_paths[i])$size))
     file.remove(png_paths[i])

     s3$put_object(Bucket = s3_bucket_name,
                   Key = symbology_bucket_paths[i],
                   Body = readBin(symbology_paths[i], "raw", file.info(symbology_paths[i])$size))
     file.remove(symbology_paths[i])
  }

  # S3 cache check
  all_exist <- TRUE
  tryCatch({
    s3$head_object(Bucket = s3_bucket_name, Key = tiff_bucket_path)
  }, error = function(e) { all_exist <<- FALSE })
  for (k in c(png_bucket_paths, symbology_bucket_paths)) {
    tryCatch({
      s3$head_object(Bucket = s3_bucket_name, Key = k)
    }, error = function(e) { all_exist <<- FALSE })
  }
  if (all_exist) {
    result <- vector("list", length = n + 1)
    for (i in seq_along(pred_weeks)) {
      result[[i]] <- list(
        week = pred_weeks[i],
        url = png_urls[i],
        legend = symbology_urls[i],
        type = flow_type
      )
    }
    log_progress("Returned cached result from S3")
    return(
      list(
        start = list(
          week = week,
          taxa = taxa,
          loc = loc
        ),
        status = "success",
        result = result
      )
    )
  }

  # Clean up RAM disk directory
  unlink(out_path, recursive = TRUE)

  # Assemble return list:
  result <- vector(mode = "list", length = n + 1)
  for (i in seq_along(pred_weeks)) {
     result[[i]] <- list(
        week = pred_weeks[i],
        url = png_urls[i],
        legend = symbology_urls[i],
        type = flow_type
     )
  }
  log_progress("Flow function complete")

  # Memory cleanup
  rm(rasters, combined, web_raster, week_raster)
  gc()

  return(
     list(
     start = list(
        week = week,
        taxa = taxa,
        loc = loc
     ),
     status = "success",
     result = result)
  )
  
}
