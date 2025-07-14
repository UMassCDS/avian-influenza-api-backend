
#* @get /outflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc = NULL, week = 10, taxa = "total", n = 20) {
   # See flow for documentation of arguments
   flow(loc = loc, week = week, taxa = taxa, n = n, direction = "forward")
}