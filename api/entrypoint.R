library(plumber)
library(BirdFlowR)
library(jsonlite)
library(terra)
library(aws.s3)
library(BirdFlowAPI)

library(plumber)
pr <- pr()

# Add CORS filter
pr <- pr_filter(pr, "cors", function(req, res) {
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
pr <- pr_mount(pr, "/hello", plumb("endpoints/hello.R"))
pr <- pr_mount(pr, "/mock", plumb("endpoints/mock_api.R"))
pr <- pr_mount(pr, "/birdflu/inflow", plumb("endpoints/birdflu_inflow.R"))
pr <- pr_mount(pr, "/birdflu/outflow", plumb("endpoints/birdflu_outflow.R"))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)
