greet <- function(name) {
  paste("Hello", name)
}

#' Load an RDS model from a public S3 URL directly into memory
load_model_from_url <- function(model_url) {
  readRDS(url(model_url))
}