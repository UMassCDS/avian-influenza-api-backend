
require(plumber)

#-------------------------------------------------------------------------------
# Environment loads (run once on router setup)
#-------------------------------------------------------------------------------
md <- new.env()
index <- load_collection_index()
for (i in 1:nrow(index)) {
  species <- index[i,2]
  modelname <- index[i,1]
  md[[species]] <- load_model(modelname)
}
pop <- read.csv("api/data/population.csv") |>
  dplyr::filter(species_code %in% index$species_code) |>
  dplyr::select(species = species_code, population = americas_pop)
index <- dplyr::left_join(index, pop, by = c("species_code" = "species"))
md[["index"]] <- index
#-------------------------------------------------------------------------------

#* @param week The starting week number
#* @param taxa Species to include
#* @param n
#* @get /flow
# Sample: http://0.0.0.0:8000/flow?date=text
flow <- function(taxa, lat, lon, n, week, date, direction = "forward") {
  birdflow_options(collection_url = "https://birdflow-science.s3.amazonaws.com/collection/")
  model <- md[[taxa]]
  status <- "success"
  index <- md[["index"]]
  n <- as.numeric(n)
  
  png_out <- "/api/data/png/"
  tif_out <- "/api/data/tif/"
  
  dir.create(png_out)
  dir.create(tif_out)
  
  start <- as.Date("1-1-2022")
  if (!is.na(date)) {
   start <- as.Date(date) 
  } else if (!is.na(week)) {
    start <- start + difftime(as.numeric(week), "weeks")
  }
  
  corners = data.frame(x = c(-170, -170, -50, -50), y = c(10, 80, 10, 80))
  csf <- sf::st_as_sf(corners,coords = c("x", "y"))
  sf::st_crs(csf) <- "epsg:4326"
  web_corners <- sf::st_transform(csf, sf::st_crs("EPSG:3857"))
  ai_app_extent <- terra::ext(web_corners)
  rm(corners, csf, web_corners)
  
  abundance_cols <- ebirdst::ebirdst_palettes(n = 256, type = "weekly") |> 
    col2rgb() |> t()
  
  
  
  dist_len <- nrow(model$distr)
  abundance <- array(0, 
                      dim = c(nrow(model$distr), n, nrow(index)),
                      dimnames = list(row = NULL,
                                      week = seq_len(n),
                                      species = index$species
                                      ))

  for (i in seq_len(nrow(index))) {
    sp <- index$species[i]
    sp_abund <- array(0, dim = dim(prop_abund)[1:2],
                     dimnames = dimnames(prop_abund)[1:2])
    active_model <- index[i,1]
    
    xy_model <- BirdFlowR::latlon_to_xy(lat, lon, active_model)
    dist_model <- BirdFlowR::as_distr(xy_model, active_model)
    
    props_pred <- predict(active_model, dist_model, start, n)
    adj_pred <- props_pred * index[i,10]
    sp_abund <- adj_pred
    abundance[, , i] <- sp_abund
    
  }

  
  
  files <- c()
  maxval <- -Inf
  
  for (i in seq_len(1:nrow(index))) {
    sp <- index[i,2]
    ac_model <- index[i,1]
    
    tif_file <- paste(tif_out, sp, n, ".tif", sep = "")
    png_files <- c()
    for (i in seq_len(1:n)) {
      filename <- paste(png_out, sp, i, "of", n, ".png", sep = "")
      append(png_files, filename)
    }
    # files[i] <- paste(tif_out, "/", taxa, i , ".tif", sep = "")
    # i_print <- i
    # if (direction == "inflow") {
    #   i_print <- -i
    # }
    
    day_offset <- as.difftime(i_print, units = "weeks")
    day_current <- start + day_offset
    
   # r <- rasterize_distr(out_dist[,i], model, format = "SpatRaster")
    r <- terra::rast(abundance[, , i], extent = ac_model$geom$ext, 
                     crs = ac_model$geom$crs)
    terra::writeRaster(r, tif_file, overwrite = TRUE)
    
    r_webmerc <- terra::project(r, terra::crs("EPSG: 3857"))
    
    r_crop <- terra::crop(r_webmerc, ai_app_extent)
    r_crop[is.na(r_crop)] <- 0
   
    maxval <- max(maxval, max(terra::values(r_crop), na.rm = TRUE)) |>
      signif_ceiling(digits = 2)
   
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
