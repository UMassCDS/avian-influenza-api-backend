library(plumber)
library(BirdFlowR)
library(jsonlite)


# Load globals and helpers
source("config/globals.R")
source("utils/helpers.R")
source("utils/symbolize_raster_data.R")
source("utils/save_json_palette.R")
source("utils/range_rescale.R")
source("utils/flow.R")

# Mount  endpoints
pr <- pr() %>%
  pr_mount("/hello", plumb("endpoints/hello.R")) %>%
  pr_mount("/predict", plumb("endpoints/predict.R")) %>%
  pr_mount("/mock", plumb("endpoints/mock_api.R")) %>%
  pr$mount("/flow", plumb("endpoints/api.R"))
   

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
