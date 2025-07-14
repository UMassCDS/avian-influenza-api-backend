if(FALSE) {
   # Manually set function arguments for dev and debugging
   # Running code here allows running function body code outside of the
   # function definition (line by line)
   
   ## Setup - duplicates loading done in entrypoint.R
   
   # Load required libraries
   library(BirdFlowR)
   library(paws)
   library(jsonlite)
   library(terra)

   # Load globals and helpers
   source("api/config/globals.R")
   source("api/utils/helpers.R")
   source("api/utils/symbolize_raster_data.R")
   source("api/utils/save_json_palette.R")
   source("api/utils/range_rescale.R")
   
   
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



#-------------------------------------------------------------------------------

#* @param week The starting week number
#* @param taxa Species to include
#* @param lat Latitude
#* @param lon Longitude
#* @param n Number of weeks to predict out.
#* @get /flow
# Sample: http://0.0.0.0:8000/flow?date=2022-02-02&taxa=buwtea&n=5&lat=30&lon=-85&direction=forward
flow <- function(taxa, loc, n, week = 0, date, direction = "forward") {

  # Convert location into lat,lon data frame   
  lat_lon  <- strsplit(loc, ";") |> 
     unlist() |>
     strsplit(split = ",") |>
     do.call(rbind, args = _) |> 
     as.data.frame() 
  for(i in seq_len(ncol(lat_lon)))
     lat_lon[ , i] <- as.numeric(lat_lon[, i])
  names(lat_lon) <- c("lat", "lon")
  
 
   
  status <- "success"
   
  err_msgs <- character(0)
  if(!taxa %in% (c(species$species, "total"))) 
     err_msgs <- c(err_msgs, "invalid taxa")

     
  if(!week %in% as.character(1:52)) 
     err_msgs <- c(err_msgs, "invalid week")
   week <- as.numeric(week)
   
  if(!n %in% as.character(1:52))
      err_msgs <- c(err_msgs, "invalid n")
  n <- as.numeric(n)
   
  if(!length(err_msgs) == 0){
     status <- "error"
     ### Exit here!!!!!
  } 
  
  if(!direction %in% c("forward", "backward")) 
     err_msgs <- c(err_msgs, "invalid direction - should be forward or backward")
  week <- as.numeric(week)
  
  if(direction == "forward") {
     flow_type <- "outflow" 
  } else {
     flow_type <- "inflow"
  }
  
  # Set unique ID and output directory for this API call
  unique_id <- Sys.time() |> 
     format(format = "%Y-%m-%d_%H-%M-%S")  |>
  paste0("_", round(runif(1, 0, 1000)))

  
  out_path <- file.path(local_cache, unique_id) # for this API call
  dir.create(out_path)  
  if(!file.exists(out_path))
     err_msgs <- c(err_msgs, "Could not create output directory")
  
  # Define list of target species
  # Will either be a single species or a vector of all
  target_species <- if(taxa == "total") {
     target_species <- species$species
  } else { 
     target_species <- taxa
  }
  
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
     err_msgs <- c(err_msgs, "Invalid starting location")
  }
  rasters <- rasters[!skipped]
  
  
  
 
  #####
  if (length(target_species > 1)) {
     # combine into one here
     
     # combined <-  [sum of rasters in "rasters" (list)]
     
  } else {
     
     combined <- rasters[[1]]
  }

  
  # write combined to geotiff here
  
  # Path:
  # "<out_path>/<flow_type>_<taxa>.tif
  # e.g.:  /inflow_total.tif
  
  
  ######
  
  
  
  
  
  ## EBP: stopped revisions here 2025-07-10
  # Need to :
  
  # Reproject and crop
  # write pngs
  #   - loop through weeks writing each one out with existing function
  # Path:
  # "<out_path>/<flow_type>_<taxa>_<week>.png
  # e.g.:  /inflow_total_1.tif
  
  
  # Write json symbology file
  # Copy to S3 bucket
  # Return json list

  
  web_raster <- combined |> 
     terra::project(ai_app_crs$input) |> 
     terra::crop(ai_app_extent)
  
  
  # Write out symbolized png files and synmbology file (json) 
  # Each week has a separate pair of files
  pred_weeks <- lookup_timestep_sequence(bf, start = week, n = n, direction = direction)
  
  # File names (no path)
  png_files <- paste0(flow_type, "_", taxa, "_", pred_weeks, ".png") 
  symbology_files <- paste0(flow_type, "_", taxa, "_", pred_weeks, ".json") 
  
  # Local paths
  png_paths <-   file.path(out_path, png_files)  # local path
  symbology_paths <- file.path(out_path, symbology_files) # local paths

  # Urls
  png_urls <- paste0(s3_flow_url, unique_id, "/",  png_files) 
  symbology_urls <- paste0(s3_base_url,unique_id, "/", symbology_files_files)
  
  # bucket paths
  png_bucket_paths <- paste0(s3_flow_base, unique_id, "/", png_files)
  symbology_bucket_paths <- paste0(s3_flow_base, unique_id, "/", symbology_files)
  
  for(i in seq_along(pred_weeks)){
     week <- pred_weeks[i]
     week_raster <- web_raster[[i]]
     max_val <- terra::minmax(week_raster)[2]
     symbolize_raster_data(png = png_paths[i], col_palette = flow_colors,
                           rast = week_raster, max_value = max_val)
     
     save_json_palette(symbology_paths[i], max = max_val, col_matrix = flow_colors)
  }
  

  # Copy Files to S3
  s3 <- paws::s3()
  local_paths  <- c(png_path, symbology_paths)
  bucket_paths <- c(png_bucket_paths, symbology_bucket_paths) # e.g.  "flow/2025-07-14_14-02-12_742/outflow_total_15.png"

  for(i in seq_along(local_paths)) { 
     s3$put_object(Bucket = s3_bucket_name,
                   Key = bucket_paths[i],
                   Body = readBin(local_paths[i], "raw", file.info(local_paths[i])$size))
  }
  

  # Assemble return information:
  result <- vector(mode = "list", length = n + 1)
  for (i in seq_along(pred_weeks)) {
     result[[i]] <- list(
        week = pred_weeks[i],
        url = png_urls[i],
        legend = symbology_urls[i]
     )
  }
  
  list(
     start = list(
        week = week,
        taxa = taxa,
        location = loc
     ),
     status = "success",
     result = result
  )
  
}
