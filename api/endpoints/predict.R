library(BirdFlowR)
birdflow_options(collection_url = "https://birdflow-science.s3.amazonaws.com/avian_flu/")

#* Test and generate a plot from a BirdFlow model
#* @param model_name The model code (e.g., "ambduc")
#* @post /test_model
function(model_name = "ambduc") {
  bf <- load_model(model_name)
  rts <- route(bf, 5, season = "prebreeding")

  dir.create("/tmp/plots", showWarnings = FALSE, recursive = TRUE)
  plot_path <- paste0("/tmp/plots/", model_name, "_plot.png")

  # Ensure plot is fully rendered inside plumber context
  png(plot_path)
  print(plot(rts))  # 👈 Critical to force plotting
  dev.off()

  Sys.sleep(0.2)  # Slight pause for filesystem sync

  file_exists <- file.exists(plot_path)
  file_size <- if (file_exists) file.info(plot_path)$size else NA

  list(
    model = model_name,
    plot_file = plot_path,
    file_exists = file_exists,
    file_size = file_size
  )
}
