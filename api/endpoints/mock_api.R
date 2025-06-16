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
    sprintf("%s%s/%s/%s_%s_%d.png", baseUrl, abundanceName, taxa_list[taxa_index], abundanceName, taxa_list[taxa_index], week)
  }
  abundanceLegendURL <- function(taxa_index, week) {
    sprintf("%s%s/%s/week_%d.json", baseUrl, abundanceName, taxa_list[taxa_index], week)
  }

  weekNum <- as.integer(week)
  nResults <- as.integer(n)
  locations <- if (!is.null(loc)) {
    lapply(strsplit(loc, ";")[[1]], function(pair) as.numeric(strsplit(pair, ",")[[1]]))
  } else {
    list(c(42.09822, -106.96289))
  }

  result <- list()
  for (i in 1:nResults) {
    w <- weekNum - i
    if (w < 1) break
    result[[length(result)+1]] <- list(
      week = unbox(w),
      url = unbox(abundanceImageURL(taxaIdx, w)),
      legend = unbox(abundanceLegendURL(taxaIdx, w))
    )
  }

  list(
    start = list(
      week = unbox(weekNum),
      taxa = unbox(taxa),
      location = locations
    ),
    status = unbox("success"),
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
    sprintf("%s%s/%s/%s_%s_%d.png", baseUrl, abundanceName, taxa_list[taxa_index], abundanceName, taxa_list[taxa_index], week)
  }
  abundanceLegendURL <- function(taxa_index, week) {
    sprintf("%s%s/%s/week_%d.json", baseUrl, abundanceName, taxa_list[taxa_index], week)
  }

  weekNum <- as.integer(week)
  nResults <- as.integer(n)
  locations <- if (!is.null(loc)) {
    lapply(strsplit(loc, ";")[[1]], function(pair) as.numeric(strsplit(pair, ",")[[1]]))
  } else {
    list(c(42.09822, -106.96289))
  }

  result <- list()
  for (i in 1:nResults) {
    w <- weekNum + i
    if (w > 52) break
    result[[length(result)+1]] <- list(
      week = unbox(w),
      url = unbox(abundanceImageURL(taxaIdx, w)),
      legend = unbox(abundanceLegendURL(taxaIdx, w))
    )
  }

  list(
    start = list(
      week = unbox(weekNum),
      taxa = unbox(taxa),
      location = locations
    ),
    status = unbox("success"),
    result = result
  )
}