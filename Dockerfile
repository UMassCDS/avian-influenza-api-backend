FROM rocker/r-ver:4.3.0

RUN apt-get update && apt-get install -y --no-install-recommends libssl-dev libxml2-dev curl git && rm -rf /var/lib/apt/lists/*
RUN R -e 'install.packages(c("plumber", "roxygen2"), repos="https://cloud.r-project.org")'

COPY api /app/api
COPY entrypoint.R /app/

WORKDIR /app
EXPOSE 8000
CMD ["R", "-f", "entrypoint.R", "--vanilla"]