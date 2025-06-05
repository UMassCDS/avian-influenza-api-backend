# Use the Rocker Geospatial image as a base
FROM rocker/geospatial:4.1.0

# Set working directory inside the container
WORKDIR /app

# Copy the API directory
COPY api /app/api

# Expose the port on which the API will run
EXPOSE 8000

# Run the Plumber API, pointing to the entrypoint.R file within the api directory
CMD ["R", "-e", "pr <- plumber::plumb('api/entrypoint.R'); pr$run(host='0.0.0.0', port=8000)"]