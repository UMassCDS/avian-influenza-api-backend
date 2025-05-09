# Use the official R image as a base
FROM rocker/r-ver:4.1.0

# Install necessary dependencies for Plumber
RUN R -e "install.packages('plumber')"

# Set working directory inside the container
WORKDIR /app

# Copy the API directory
COPY api /app/api

# Expose the port on which the API will run
EXPOSE 8000

# Run the Plumber API, pointing to the entrypoint.R file within the api directory
CMD ["R", "-e", "pr <- plumber::plumb('api/entrypoint.R'); pr$run(host='0.0.0.0', port=8000)"]