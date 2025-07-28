library(jsonlite)

#* @get /inflow
#* @param loc
#* @param week
#* @param taxa
#* @param n
function(loc = NULL, week = 10, taxa = "total", n = 20) {
  baseUrl <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/"
  abundanceName <- "abundance"
  taxa_list <- c(
    "total",
    "mallar3",
    "ambduc",
    "norpin",
    "norsho",
    "gnwtea",
    "buwtea",
    "amewig",
    "gadwal",
    "wooduc"
  )
  taxaIdx <- match(taxa, taxa_list)
  if (is.na(taxaIdx)) taxaIdx <- 1

  abundanceImageURL <- function(taxa_index, week) {
    sprintf("%s%s/%s/abundance_%s_%d.png", baseUrl, abundanceName, taxa_list[taxa_index], taxa_list[taxa_index], week)
  }
  abundanceLegendURL <- function(taxa_index) {
    sprintf("%s%s/%s/scale_abundance_%s.json", baseUrl, abundanceName, taxa_list[taxa_index], taxa_list[taxa_index])
  }

  weekNum <- as.integer(week)
  nResults <- as.integer(n)
  locations <- if (!is.null(loc)) {
    lapply(strsplit(loc, ";")[[1]], function(pair) as.numeric(strsplit(pair, ",")[[1]]))
  } else {
    list(c(42.09822, -106.96289))
  }

  result <- list()
  # Include the current week and previous weeks
  for (i in 0:(nResults-1)) {
    w <- weekNum - i
    if (w < 1) break
    result[[length(result)+1]] <- list(
      week = unbox(w),
      url = unbox(abundanceImageURL(taxaIdx, w)),
      legend = unbox(abundanceLegendURL(taxaIdx))
    )
  }

  list(
    start = list(
      week = unbox(weekNum),
      taxa = unbox(taxa),
      location = locations
    ),
    status = unbox("success"),
    result = result,
    geotiff = unbox(sprintf("%s%s/%s/flow_projection.tif", baseUrl, abundanceName, taxa_list[taxaIdx]))
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
  taxa_list <- c(
    "total",
    "mallard3",
    "ambduc",
    "norpin",
    "norsho",
    "gnwtea",
    "buwtea",
    "amewig",
    "gadwal",
    "wooduc"
  )
  taxaIdx <- match(taxa, taxa_list)
  if (is.na(taxaIdx)) taxaIdx <- 1

  abundanceImageURL <- function(taxa_index, week) {
    sprintf("%s%s/%s/abundance_%s_%d.png", baseUrl, abundanceName, taxa_list[taxa_index], taxa_list[taxa_index], week)
  }
  abundanceLegendURL <- function(taxa_index) {
    sprintf("%s%s/%s/scale_abundance_%s.json", baseUrl, abundanceName, taxa_list[taxa_index], taxa_list[taxa_index])
  }

  weekNum <- as.integer(week)
  nResults <- as.integer(n)
  locations <- if (!is.null(loc)) {
    lapply(strsplit(loc, ";")[[1]], function(pair) as.numeric(strsplit(pair, ",")[[1]]))
  } else {
    list(c(42.09822, -106.96289))
  }

  result <- list()
  # Include the current week and next weeks
  for (i in 0:(nResults-1)) {
    w <- weekNum + i
    if (w > 52) break
    result[[length(result)+1]] <- list(
      week = unbox(w),
      url = unbox(abundanceImageURL(taxaIdx, w)),
      legend = unbox(abundanceLegendURL(taxaIdx))
    )
  }

  list(
    start = list(
      week = unbox(weekNum),
      taxa = unbox(taxa),
      location = locations
    ),
    status = unbox("success"),
    result = result,
    geotiff = unbox(sprintf("%s%s/%s/flow_projection.tif", baseUrl, abundanceName, taxa_list[taxaIdx]))
  )
}