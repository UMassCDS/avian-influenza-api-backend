library(aws.s3)
library(aws.signature)

# Make sure to use instance metadata for credentials
use_instance_metadata()

# Set your region (change if needed)
Sys.setenv("AWS_DEFAULT_REGION" = "us-east-2")

# Enable debug logging for troubleshooting
options("aws.signature.debug" = TRUE)

# Create a test file
writeLines("hello world", "test_s3.txt")

# Try uploading to S3
result <- put_object(
  file = "test_s3.txt",
  object = "test_s3.txt",
  bucket = "avianinfluenza"
)

print(result) # Should print TRUE if successful

# Clean up local file
file.remove("test_s3.txt")