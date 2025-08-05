#!/bin/bash

# --- System dependencies ---
echo "Installing system dependencies..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt-get update
  sudo apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    cargo \
    rustc
fi

# --- Install R (if not installed) ---
if ! command -v R &> /dev/null; then
  echo "R not found. Please install R manually for your OS."
  exit 1
fi

# --- Install R packages ---
echo "Installing R packages..."
Rscript -e "install.packages(c('plumber', 'aws.s3', 'remotes', 'Cairo', 'jsonlite'), repos='https://cloud.r-project.org')"
Rscript -e "remotes::install_github('birdflow-science/BirdFlowR')"

# --- Docker setup ---
if ! command -v docker &> /dev/null; then
  echo "Docker not found. Please install Docker Desktop for your OS."
  exit 1
fi

echo "Building Docker image..."
docker build -t avian-flu-api .

echo "Running Docker container (local mode)..."
mkdir -p ./localtmp
docker run -p 8000:8000 -v $(pwd)/localtmp:/dev/shm avian-flu-api &

# --- Make git ignore future changes to save_local.flag ---
git update-index --assume-unchanged api/config/save_local.flag
echo "Git will now ignore local changes to api/config/save_local.flag."

# --- Set save_local.flag to TRUE for local mode ---
echo "TRUE" > api/config/save_local.flag
echo "Set api/config/save_local.flag to TRUE for local testing."


# --- Instructions for local testing ---
echo ""
echo "To test locally without S3 uploads:"
echo "1. The file api/config/save_local.flag is set to TRUE."
echo "2. Output files will be saved in /dev/shm (or ./localtmp if using Docker)."
echo ""
echo "To run the API locally without Docker:"
echo "Rscript -e \"pr <- plumber::plumb('api/entrypoint.R'); pr$run(port=8000)\""
echo ""
echo "Access the API at http://localhost:8000"
echo ""

# --- Open R environment and run API ---
echo "Opening R and running API locally..."
R --no-save <<EOF
library(plumber)
pr <- plumb('api/entrypoint.R')
pr$run(port=8000)
EOF