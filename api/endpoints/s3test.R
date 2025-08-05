#' @post /s3test
function() {
  library(aws.s3)
  library(aws.signature)
  use_instance_metadata()
  Sys.setenv("AWS_DEFAULT_REGION" = "us-east-2")
  options("aws.signature.debug" = TRUE)
  
  test_file <- tempfile(fileext = ".txt")
  writeLines("hello from plumber endpoint", test_file)
  
  result <- tryCatch({
    put_object(
      file = test_file,
      object = "plumber_s3test.txt",
      bucket = "avianinfluenza"
    )
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