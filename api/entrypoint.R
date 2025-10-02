library(plumber)
library(devtools)

# Load BirdFlowAPI package from GitHub
devtools::install_github("UMassCDS/BirdFlowAPI", ref = "feature/export-s3-functions")

# Set-up BirdFlowAPI package
library(BirdFlowAPI)
load_models()
BirdFlowAPI:::set_s3_config()

# File paths for all endpoints in BirdFlowAPI
files <- c("api.R", "hello.R", "mock_api.R", "predict.R", "status.R")
files <- file.path(system.file("plumber/flow/endpoints", package = "BirdFlowAPI"), files)
paths <- c("api", "hello", "mock", "predict", "status")

# Create plumber router
pr <- plumber::pr()

# Add all endpoints
for(i in seq_along(files)) {
  pr <- pr |> pr_mount(paste0("/", paths[i]), plumb(files[i]))
}

# Add CORS filter
pr <- pr |>
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
