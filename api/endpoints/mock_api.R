#* @get /inflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc = NULL, week = 10, taxa = "total", n = 20) {
  baseUrl <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/"
  abundanceName <- "abundance"
  taxa_list <- c("total", "mallard3", "canada_goose", "ambduc")
  taxaIdx <- match(taxa, taxa_list)
  if (is.na(taxaIdx)) taxaIdx <- 1

  abundanceImageURL <- function(taxa_index, week) {
    sprintf("%s%s/%s/%s_%s_%d.png", baseUrl, abundanceName, taxa_list[taxa_index], abundanceName, taxa_list[taxa_index], week)
  }
  abundanceLegendURL <- function(taxa_index) {
    sprintf("%s%s/%s/scale_%s_%s.json", baseUrl, abundanceName, taxa_list[taxa_index], abundanceName, taxa_list[taxa_index])
  }

  weekNum <- as.integer(week)
  nResults <- as.integer(n)
  locations <- if (!is.null(loc)) list(as.numeric(strsplit(loc, ",")[[1]])) else list(c(42.09822, -106.96289))

  result <- list()
  for (i in 0:(nResults-1)) {
    w <- weekNum - i
    if (w < 1) break
    result[[length(result)+1]] <- list(
      week = w,
      url = abundanceImageURL(taxaIdx, w),
      legend = abundanceLegendURL(taxaIdx)
    )
  }

  list(
    start = list(
      week = weekNum,
      taxa = taxa,
      location = locations
    ),
    status = "success",
    result = result
  )
}

#* @get /outflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc = NULL, week = 10, taxa = "total", n = 20) {
  baseUrl <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/"
  abundanceName <- "abundance"
  taxa_list <- c("total", "mallard3", "canada_goose", "ambduc")
  taxaIdx <- match(taxa, taxa_list)
  if (is.na(taxaIdx)) taxaIdx <- 1

  abundanceImageURL <- function(taxa_index, week) {
    sprintf("%s%s/%s/%s_%s_%d.png", baseUrl, abundanceName, taxa_list[taxa_index], abundanceName, taxa_list[taxa_index], week)
  }
  abundanceLegendURL <- function(taxa_index) {
    sprintf("%s%s/%s/scale_%s_%s.json", baseUrl, abundanceName, taxa_list[taxa_index], abundanceName, taxa_list[taxa_index])
  }

  weekNum <- as.integer(week)
  nResults <- as.integer(n)
  locations <- if (!is.null(loc)) list(as.numeric(strsplit(loc, ",")[[1]])) else list(c(42.09822, -106.96289))

  result <- list()
  for (i in 0:(nResults-1)) {
    w <- weekNum + i
    if (w > 52) break
    result[[length(result)+1]] <- list(
      week = w,
      url = abundanceImageURL(taxaIdx, w),
      legend = abundanceLegendURL(taxaIdx)
    )
  }

  list(
    start = list(
      week = weekNum,
      taxa = taxa,
      location = locations
    ),
    status = "success",
    result = result
  )
}