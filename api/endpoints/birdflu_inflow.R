#* @get /birdflu_inflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc = NULL, week = 10, taxa = "total", n = 20) {
  library(BirdFlowAPI)
  result <- BirdFlowAPI::flow(loc = loc, week = week, taxa = taxa, n = n, direction = "backward")
  return(result)
}
