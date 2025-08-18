
#* @get /birdflu_outflow
#* @param loc Location as a comma-separated string (e.g., "43,-72")
#* @param week Week number (default 10)
#* @param taxa Species name (default "total")
#* @param n Number of results (default 20)
#* @serializer json
function(loc = "43,-72", week = 10, taxa = "total", n = 20) {
  library(BirdFlowAPI)
  result <- flow(loc = loc, week = week, taxa = taxa, n = n, direction = "forward")
  return(result)
}
