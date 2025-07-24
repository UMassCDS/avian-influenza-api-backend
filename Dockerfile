FROM rocker/geospatial:latest


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

# Install necessary dependencies for Plumber and AWS S3
RUN R -e "install.packages(c('plumber', 'aws.s3', 'remotes', 'Cairo', 'jsonlite', 'paws'), repos='https://cloud.r-project.org')"

RUN R -e "remotes::install_github('birdflow-science/BirdFlowR')"

# Set working directory inside the container
WORKDIR /app

# Copy the API directory
COPY api /app/api

# Expose the port on which the API will run
EXPOSE 8000

# Run the Plumber API, pointing to the entrypoint.R file within the api directory
CMD ["R", "-e", "pr <- plumber::plumb('api/entrypoint.R'); pr$run(host='0.0.0.0', port=8000)"]
