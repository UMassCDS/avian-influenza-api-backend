
#* @get /inflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc="43,-72", week = 10, taxa = "total", n = 20) {
   # See flow for documentation of arguments
   flow(loc = loc, week = week, taxa = taxa, n = n, direction = "backward")
}


#* @get /outflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc, week = 10, taxa = "total", n = 20) {
   # See flow for documentation of arguments
   flow(loc = loc, week = week, taxa = taxa, n = n, direction = "forward")
}