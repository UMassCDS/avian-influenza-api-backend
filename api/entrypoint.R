library(plumber)
library(BirdFlowR)
library(jsonlite)
library(terra)
library(aws.s3)

# Load globals and helpers
source("config/globals.R")
source("utils/helpers.R")
source("utils/symbolize_raster_data.R")
source("utils/save_json_palette.R")
source("utils/range_rescale.R")
source("utils/flow.R")

# Create plumber router
pr <- pr()

# Add CORS filter
pr <- pr %>%
  pr_filter("cors", function(req, res) {
    res$setHeader("Access-Control-Allow-Origin", "*")
    res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    if (req$REQUEST_METHOD == "OPTIONS") {
      res$status <- 200
      return(list())
    } else {
      forward()
    }
  }) %>%
  pr_mount("/hello", plumb("endpoints/hello.R")) %>%
  pr_mount("/predict", plumb("endpoints/predict.R")) %>%
  pr_mount("/mock", plumb("endpoints/mock_api.R")) %>%
  pr_mount("/api", plumb("endpoints/api.R")) %>%
  pr_mount("/s3test", plumb("endpoints/s3test.R")) # <-- Add this line
   

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
