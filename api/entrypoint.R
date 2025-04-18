library(plumber)

# Load globals and helpers
source("api/config/globals.R")
source("api/utils/helpers.R")

# Main router
pr <- plumber::plumb("api/endpoints/hello.R")

# Mount additional endpoints
pr$mount("/status", plumber::plumb("api/endpoints/another_endpoint.R"))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
