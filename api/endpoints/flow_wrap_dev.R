require(plumber)

#* @param date The date to be echoed in the response
#* @param taxa Species to include
#* @param n
#* @get /flow
# Sample: http://0.0.0.0:8000/flow?date=text
flow <- function(date = "", taxa = "amewoo", lat, lon, n, direction = "forward") {
  
  birdflow_options(collection_url = "https://birdflow-science.s3.amazonaws.com/collection/")
  index <- load_collection_index()
  model <- NULL
  
  if (taxa %in% index$species_code) {
    modelname <- index |>
      dplyr::filter(species_code == taxa) |>
      dplyr::select(model)
    print(modelname$model)
    model <- load_model(modelname$model)
    }
  
  start <- as.Date(date)
  n <- as.numeric(n)
  
  
  
  xy <- BirdFlowR::latlon_to_xy(lat, lon, model)
  dist <- BirdFlowR::as_distr(xy, model)
  
  out_dist <- predict(model, distr = dist, start = start, n_steps = n)
  
  out <- list()
  
  for (i in 1:n) {
    plot_distr(out_dist[i], model)
    out[i] <- c(
      date = paste(start),
      lag = paste(n),
      taxa = paste(taxa)
    )
  }
  # upload those somehow and get the URLs
  
  out

}
