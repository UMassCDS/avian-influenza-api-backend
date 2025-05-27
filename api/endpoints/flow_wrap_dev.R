require(plumber)

#* @param date The date to be echoed in the response
#* @param taxa Species to include
#* @param loc
#* @param n
#* @get /flow
# Sample: http://0.0.0.0:8000/flow?date=text
function(date = "", taxa = "amewoo", lat, lon, n, direction = "forward") {
  start <- as.Date(date)
  n <- as.numeric(n)
  
  model <- BirdFlowModels::amewoo
  
  xy <- BirdFlowR::latlon_to_xy(lat, lon, model)
  dist <- BirdFlowR::as_distr(xy, model)
  
  out_dist <- predict(model, distr = dist, start = start, n_steps = n)
  
  for (i in 1:n) {
    plot_distr(out_dist[i], model)
  }
  # upload those somehow and get the URLs
  
  list(
    date = paste(start),
    lag = paste(n),
    taxa = paste(taxa)
  )
}
