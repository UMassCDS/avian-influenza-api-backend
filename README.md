# Avian Influenza API Backend
Source code for API backend for the avian influenza project.

## Structure
- Modular endpoints under `api/endpoints/`
- Utility functions in `api/utils/`
- Configs in `api/config/`
- Entrypoint: `api/entrypoint.R`

## Run Locally with Docker

### 1. Build the Docker image
On most systems (Intel/AMD):
```bash
docker build -t plumber-api .
```

On Apple Silicon (M1/M2) or if you see platform errors:
```bash
docker build --platform linux/amd64 -t plumber-api .
```

### 2. Run the Docker container
```bash
docker run --rm -p 8000:8000 plumber-api
```

### 3. Test the API
Visit: http://localhost:8000/hello
or use curl:
```bash
curl http://localhost:8000/hello
```

#### Notes
- The API will be available at http://localhost:8000
- If you need to clear the local cache, delete everything in `api/localtmp/` before building, or add logic to clear it at runtime.
- For AWS deployment, ensure your environment variables for AWS credentials and region are set appropriately.