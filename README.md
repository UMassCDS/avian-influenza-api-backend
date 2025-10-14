# Avian Influenza API Backend
Source code for API backend for the avian influenza project.

## Structure
- Modular endpoints under `api/endpoints/`
- Utility functions in `api/utils/`
- Configs in `api/config/`
- Entrypoint: `api/entrypoint.R`

## Run with Docker
```bash
docker build --platform linux/amd64 -t plumber-api .
docker run -d -p 8000:8000 plumber-api
```

Visit: http://localhost:8000/hello