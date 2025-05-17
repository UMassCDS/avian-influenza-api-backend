library(plumber)
library(avianutils)

# Load globals and helpers
source("config/globals.R")

# Main router
pr <- plumber::plumb("endpoints/hello.R")

# Mount additional endpoints
pr$mount("/status", plumber::plumb("endpoints/another_endpoint.R"))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
