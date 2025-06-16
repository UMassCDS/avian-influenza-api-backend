library(plumber)

# Load globals and helpers
source("config/globals.R")
source("utils/helpers.R")

# Mount  endpoints
pr <- pr() %>%
  pr_mount("/hello", plumb("endpoints/hello.R")) %>%
  pr_mount("/predict", plumb("endpoints/predict.R")) %>%
  pr_mount("/mock", plumb("endpoints/mock_api.R"))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
