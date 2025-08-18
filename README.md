# Avian Influenza API Backend
Source code for API backend for the avian influenza project.

## Structure
- Modular endpoints under `api/endpoints/`
- Utility functions in `api/utils/`
- Configs in `api/config/`
- Entry point: `api/entrypoint.R`

## Run with Docker
```bash
docker build -t plumber-api .
docker run -d -p 8000:8000 plumber-api
```

Visit: http://localhost:8000/hello

## Running the API Locally

1. Make sure you have R installed on your system.
2. Clone this repository and (optionally) the BirdFlowAPI repo to the same parent directory.
3. Run the setup script to install dependencies and packages:

```bash
./setup_local.sh
```

- This will install system dependencies, R packages, and BirdFlowAPI from local source if available, otherwise from GitHub.
- It will also start the API server on port 8000.

4. Access the API at:

```
http://localhost:8000
```

5. API documentation (Swagger UI) is available at:

```
http://localhost:8000/__docs__/
```

### Troubleshooting
- If you update BirdFlowAPI locally, rerun `devtools::document()` and `devtools::install()` in the BirdFlowAPI directory, then rerun `setup_local.sh`.
- For Docker or deployment, ensure you push changes to GitHub and update install commands as needed.