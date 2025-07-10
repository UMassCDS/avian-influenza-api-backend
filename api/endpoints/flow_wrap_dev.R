if(FALSE) {
   # Set example values for debugging
   taxa <- "mallar3"
   week = 15
   date <- "2022-01-01"
   lat <- 42
   lon <- -70
   direction <- "forward"
}



#-------------------------------------------------------------------------------

#* @param week The starting week number
#* @param taxa Species to include
#* @param lat Latitude
#* @param lon Longitude
#* @param n Number of weeks to predict out.
#* @get /flow
# Sample: http://0.0.0.0:8000/flow?date=2022-02-02&taxa=buwtea&n=5&lat=30&lon=-85&direction=forward
flow <- function(taxa, lat, lon, n, week = 0, date, direction = "forward") {
  
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
  target_species <- ifelse(taxa == "total", species$species, taxa)
  
  skipped <- rep(FALSE, length(target_species))
  
  rasters <- vector(mode = "list", length(target_species))
  
  
  for(i in seq_along(target_species)) {
     sp <- target_species[i]
     
     # Local copy of BirdFlow model  
     bf <- models[[sp]]
     
     # Initial distribution
     xy <- latlon_to_xy(lat, lon, bf = bf) 
     start_distr <- as_distr(xy, bf)

     if(!is_distr_valid(bf, start_distr, timestep = week)){
        skipped[i] <- TRUE
        next
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
 
  
  if(all(skipped)) {
     err_msgs <- c(err_msgs, "Invalid starting location")
  }
  
  rasters <- rasters[!skipped]
  
  ## EBP: stopped revisions here 2025-07-10
  # Need to :
  # aggregate list of rasters into one raster
  # write tif 
  # write pngs
  # Remaining code has not been revised yet
  
  
  
  
  
  for (i in seq_len(ncol(abundance))) {
    sp <- index[i,2]
    ac_model <- md[[sp]]
    
    tif_file <- paste(tif_out, sp, n, ".tif", sep = "")
    png_files <- c()
    for (i in seq_len(1:n)) {
      filename <- paste(png_out, sp, i, "of", n, ".png", sep = "")
      append(png_files, filename)
    }
    # files[i] <- paste(tif_out, "/", taxa, i , ".tif", sep = "")
    i_print <- i
    if (direction == "inflow") {
      i_print <- -i
    }
    
    
   # r <- rasterize_distr(out_dist[,i], model, format = "SpatRaster")
    r <- terra::rast(abundance[[i]]$dist, extent = ac_model$geom$ext, 
                     crs = ac_model$geom$crs)
    
    terra::writeRaster(r, tif_file, overwrite = TRUE)
    
    r_webmerc <- terra::project(r, terra::crs("EPSG: 3857"))
    
    r_crop <- terra::crop(r_webmerc, ai_app_extent)
    r_crop[is.na(r_crop)] <- 0
   
    maxval <- max(maxval, max(terra::values(r_crop), na.rm = TRUE)) |>
      ceiling() |>
      signif(digits = 2)
      # not sure what package this function is from
      #signif_ceiling(digits = 2)
   
    cutoff <- max_val / 255
    r_crop[r_crop < cutoff] <- 0
    
    for (j in seq_len(1:n)) {
      symbolize_raster_data(rast = r_crop[[j]], png = png_files[j],
                            col_palette = abundance_cols, max_value = maxval)
    }
    
     
    url <- "umass.edu"
    
    label <- format(day_current, "%b %d")
    out[i] <- paste("lag: ", i_print, ", date: ", 
                    day_current, ", label: ", label, 
                    ", url: ", url, sep = "")
  }
  # upload those somehow and get the URLs
  
  out

}
