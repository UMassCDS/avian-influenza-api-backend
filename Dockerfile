# Base image with R and geospatial libraries
FROM rocker/geospatial:latest

# Install system dependencies (including curl, ssl, xml, git for R packages, and gdal, proj, geos, udunits for geospatial)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    cargo \
    rustc \
    && rm -rf /var/lib/apt/lists/*

# Install R packages (plumber, aws.s3, remotes, Cairo, jsonlite)
# Ensure aws.ec2metadata is installed for instance profile credential retrieval on EC2
RUN R -e "install.packages(c('plumber', 'aws.s3', 'remotes', 'Cairo', 'jsonlite', 'aws.ec2metadata'), repos='https://cloud.r-project.org')"

# Install BirdFlowR and BirdFlowAPI from GitHub
RUN R -e "remotes::install_github('birdflow-science/BirdFlowR')"
RUN R -e "remotes::install_github('UMassCDS/BirdFlowAPI')"

# Set working directory inside the container
WORKDIR /app

# Copy the API directory
COPY api /app/api

# IMPORTANT: Set the AWS region as an environment variable in the Dockerfile.
# This ensures it's available to the R session when the container starts,
# as aws.s3 might not automatically infer it in all deployment scenarios.
# Replace "us-east-2" with your actual AWS region if different.
ENV AWS_REGION=us-east-2 
ENV AWS_DEFAULT_REGION=us-east-2 
# Set both for broader compatibility

# Expose the port on which the API will run
EXPOSE 8000

# Run the Plumber API, pointing to the entrypoint.R file within the api directory
# Add a pre-execution script or command to confirm environment variables if needed
CMD ["R", "-e", "library(aws.s3); Sys.setenv('AWS_REGION' = Sys.getenv('AWS_REGION')); Sys.setenv('AWS_DEFAULT_REGION' = Sys.getenv('AWS_DEFAULT_REGION')); pr <- plumber::plumb('api/entrypoint.R'); pr$run(host='0.0.0.0', port=8000)"]
