library(plumber)
library(devtools)

# Load BirdFlowAPI package from GitHub
devtools::install_github("UMassCDS/BirdFlowAPI", ref = "feature/export-s3-functions")

# Set-up BirdFlowAPI package
library(BirdFlowAPI)
load_models()
BirdFlowAPI:::set_s3_config()

api_file <- system.file("plumber/flow/endpoints/api.R", package = "BirdFlowAPI")
pr <- plumber::plumb(api_file)

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
  })

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
