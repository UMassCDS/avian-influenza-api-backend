# Use the official R image as a base
FROM rocker/geospatial:latest

# Install system dependencies required for R package installation
RUN apt-get update && apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev

# Copy and install the avianutils package from the repo
COPY ../avianutils /avianutils
RUN R CMD INSTALL /avianutils

# Install additional dependencies for your API
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org')"

# Clean up Docker System
RUN docker system prune -af && sudo apt-get clean

# Set working directory inside the container
WORKDIR /app

# Copy the API code
COPY api /app/api

# Expose the port on which the API will run
EXPOSE 8000

# Run the Plumber API, pointing to the entrypoint.R file within the api directory
CMD ["R", "-e", "library(avianutils); pr <- plumber::plumb('api/entrypoint.R'); pr$run(host='0.0.0.0', port=8000)"]