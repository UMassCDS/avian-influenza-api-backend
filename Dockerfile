# Use the official R image from Docker Hub
FROM rocker/r-ver:4.1.0

# Install Plumber and other dependencies
RUN R -e "install.packages('plumber')"

# Set working directory in the container
WORKDIR /app

# Copy the entire project to the container
COPY . /app

# Expose the port your Plumber API will run on
EXPOSE 8000

# Run the Plumber API
CMD ["R", "-e", "pr <- plumber::plumb('api/entrypoint.R'); pr$run(host='0.0.0.0', port=8000)"]
