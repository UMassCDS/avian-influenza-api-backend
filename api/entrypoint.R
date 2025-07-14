library(plumber)
library(BirdFlowR)
library(jsonlite)


# Load globals and helpers
source("api/config/globals.R")
source("api/utils/helpers.R")
source("api/utils/symbolize_raster_data.R")

# Mount  endpoints
pr <- pr() %>%
  pr_mount("/hello", plumb("endpoints/hello.R")) %>%
  pr_mount("/predict", plumb("endpoints/predict.R")) %>%
  pr_mount("/mock", plumb("endpoints/mock_api.R")) %>%
  pr$mount("/flow", plumb("endpoints/flow_wrap_dev.R"))
   

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
