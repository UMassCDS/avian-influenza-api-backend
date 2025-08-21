#* @get /birdflu_outflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc = NULL, week = 10, taxa = "total", n = 20) {
  library(BirdFlowAPI)
  result <- BirdFlowAPI::flow(loc = loc, week = week, taxa = taxa, n = n, direction = "forward")
  return(result)
}
