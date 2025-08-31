# Avian Influenza API Backend
Source code for API backend for the avian influenza project.

## Structure
- Modular endpoints under `api/endpoints/`
- Utility functions in `api/utils/`
- Configs in `api/config/`
- Entry Point: `api/entrypoint.R`

## Run with Docker
```bash
docker build -t plumber-api .
docker run -d -p 8000:8000 plumber-api
```

Visit: http://localhost:8000/hello

## Saving Results: Local vs Cloud (S3)

- By default, results are saved locally in the API's working directory (e.g., `localtmp/`).
- To save results to AWS S3 (cloud), set the `save_local` parameter to `FALSE` in your API request or function call.
- When `save_local = FALSE`, files are temporarily created on disk and then uploaded to the S3 bucket configured via environment variables or the `set_s3_config()` function.
- After upload, temporary files are deleted from the local disk.
- S3 paths and URLs are constructed based on flow type, taxa, week, and location.

### Cross-Platform Notes
- On Linux, temporary files may be stored in `/dev/shm` (RAM disk) if available.
- On macOS/Windows, temporary files are stored in the system temp directory.
- S3 upload works on all platforms as long as AWS credentials are set.

### Example Usage
- Local save (default):
  ```r
  flow(..., save_local = TRUE)
  ```
- Cloud save (S3):
  ```r
  flow(..., save_local = FALSE)
  ```

### S3 Configuration
- Set AWS credentials and bucket via environment variables or:
  ```r
  set_s3_config(access_key = "...", secret_key = "...", region = "...", bucket = "...")
  ```

### API Endpoints
- You can control saving behavior via the `save_local` parameter in your API requests.

---