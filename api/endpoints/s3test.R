#' @post /s3test
function() {
  library(aws.s3)
  Sys.setenv("AWS_DEFAULT_REGION" = "us-east-2")
  options("aws.signature.debug" = TRUE)
  
  test_file <- "test_s3.txt"
  writeLines("hello world", test_file)
  
  result <- tryCatch({
    put_object(file = test_file, object = test_file, bucket = "avianinfluenza")
  }, error = function(e) {
    return(list(success = FALSE, error = e$message))
  })
  
  file.remove(test_file)
  
  if (isTRUE(result)) {
    list(success = TRUE, message = "Upload succeeded")
  } else {
    result
  }
}