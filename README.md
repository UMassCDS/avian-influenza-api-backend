# Avian Influenza API Backend
This API provides programmatic access to avian influenza bird migration modeling and prediction. It exposes endpoints for querying bird movement flows, retrieving geospatial data and visualizations, and interacting with AWS S3 for data storage. The API is designed for scientific, ecological, and public health applications where understanding and visualizing bird migration patterns is important for avian influenza research and response.

## Structure
- Modular endpoints under `api/endpoints/`
- Utility functions in `api/utils/`
- Configs in `api/config/`
- Entrypoint: `api/entrypoint.R`

## BirdFlowAPI Package Usage and Configuration

This project uses the [BirdFlowAPI](https://github.com/UMassCDS/BirdFlowAPI) R package to provide all core API endpoints and S3 integration.

### How BirdFlowAPI is used
- The API loads the BirdFlowAPI package from GitHub at startup.
- All endpoints are mounted directly from the BirdFlowAPI package (not from local files).
- The API calls `BirdFlowAPI::load_models()` to load required models.
- S3 configuration is set using `BirdFlowAPI:::set_s3_config()`.

Example from `api/entrypoint.R`:
```r
library(BirdFlowAPI)
BirdFlowAPI::load_models()
BirdFlowAPI:::set_s3_config(bucket = "avianinfluenza", region = "us-east-2")
```

### S3 Configuration
- The S3 bucket and region are set at API startup using `set_s3_config()`.
- All S3 uploads, downloads, and URL generation are handled by the BirdFlowAPI package using this config.
- To change the S3 bucket or region, update the arguments to `set_s3_config()` in `api/entrypoint.R`.

### Endpoints
The following endpoints are provided by the BirdFlowAPI package and are mounted automatically:
- `/api`
- `/hello`
- `/mock`
- `/predict`
- `/status`

All endpoint logic and S3 handling is managed by the BirdFlowAPI package.

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

## Deployment and CI/CD Pipeline

This project uses GitHub Actions for automated CI/CD. The deployment pipeline is defined in `.github/workflows/ci-cd-pipeline.yml` and works as follows:

### Build and Push
- On every push or pull request to the `main` branch, GitHub Actions builds the Docker image for the API.
- The image is tagged as `umasscds/avian-flu-infra:latest` and pushed to Docker Hub.

### Deploy to EC2
- On a successful push to `main`, the pipeline connects to the EC2 instance via SSH (using a private key stored in GitHub Secrets).
- It pulls the latest Docker image from Docker Hub onto the EC2 instance.
- The old running container (if any) is stopped and removed.
- The new container is started with the latest image, exposing port 8000.
- Nginx is reloaded to refresh the reverse proxy (if used).

**Key files and configuration:**
- Workflow: `.github/workflows/ci-cd-pipeline.yml`
- Docker image: `umasscds/avian-flu-infra:latest` (on Docker Hub)
- EC2 host, user, and SSH key are managed via GitHub Secrets.

**To trigger a deployment:**
- Push or merge to the `main` branch.
- The pipeline will automatically build, push, and deploy the latest code to the EC2 instance.

## Downloading or Creating a PEM Key from AWS

You can only download a `.pem` key file (EC2 key pair) from AWS at the time you create the key pair. AWS does not allow you to download it again for security reasons.

**To create and download a new .pem file:**
1. Go to the AWS EC2 Console → Key Pairs.
2. Click “Create key pair”.
3. Enter a name, select “pem” format, and click “Create”.
4. The `.pem` file will be downloaded automatically to your computer.

**If you lost your old .pem file:**
- You cannot recover it. You must create a new key pair and update your EC2 instance to use the new key (by adding the new public key to `~/.ssh/authorized_keys`).

Let your team know if you rotate keys, and keep your `.pem` file secure.

## Viewing Logs from the EC2 Instance

### If running in Docker
1. SSH into your EC2 instance:
	```bash
	ssh -i /path/to/<file>>.pem ec2-user@<your-ec2-public-dns>
	```
2. See logs
	```bash
	docker logs -f avian-flu-api
	```

## Confluence Docs:
- [Birdflow API EC2 Deployment Pipeline](https://umass-cds-ai.atlassian.net/wiki/spaces/HOME/pages/958529540/Birdflow+API+EC2+Deployment+Pipeline)
- [BirdFlow Automated Data Pipeline Architecture](https://umass-cds-ai.atlassian.net/wiki/spaces/HOME/pages/1018200065/BirdFlow+Automated+Data+Pipeline+Architecture)
- [BirdFlow API Cert Renewal](https://umass-cds-ai.atlassian.net/wiki/spaces/HOME/pages/1027538945/BirdFlow+API+Cert+Renewal)