library(plumber)
library(BirdFlowR)
library(jsonlite)
library(paws)
library(terra)

# Load globals and helpers
source("config/globals.R")
source("utils/helpers.R")
source("utils/symbolize_raster_data.R")
source("utils/save_json_palette.R")
source("utils/range_rescale.R")
source("utils/flow.R")

# Enable CORS for all routes
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  forward()
}

# Mount  endpoints
pr <- pr() %>%
  pr_filter(cors) %>%
  pr_mount("/hello", plumb("endpoints/hello.R")) %>%
  pr_mount("/predict", plumb("endpoints/predict.R")) %>%
  pr_mount("/mock", plumb("endpoints/mock_api.R")) %>%
  pr_mount("/api", plumb("endpoints/api.R"))
   

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
