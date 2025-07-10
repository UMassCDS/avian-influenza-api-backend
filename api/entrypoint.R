library(plumber)
library(BirdFlowR)
library(jsonlite)

# Load globals and helpers
source("config/globals.R")
source("utils/helpers.R")
source("utils/symbolize_raster_data.R")

# Main router
pr <- plumber::plumb("endpoints/hello.R")

# Mount additional endpoints
pr$mount("/flow", plumber::plumb("endpoints/flow_wrap_dev.R"))

pr$mount("/status", plumber::plumb("endpoints/another_endpoint.R"))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
