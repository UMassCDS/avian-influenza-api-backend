library(plumber)

# Load globals and helpers
source("config/globals.R")
source("utils/helpers.R")

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
  pr_mount("/mock", plumb("endpoints/mock_api.R"))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
