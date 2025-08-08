library(aws.s3)

Sys.setenv("AWS_DEFAULT_REGION" = "us-east-2")
options("aws.signature.debug" = TRUE)

writeLines("hello world", "test_s3.txt")

result <- put_object(
  file = "test_s3.txt",
  object = "test_s3.txt",
  bucket = "avianinfluenza"
)

print(result) # Should print TRUE if successful

file.remove("test_s3.txt")