# Global configuration

#------------------------------------------------------------------------------#
#  Load species
#------------------------------------------------------------------------------#

# Using JSON so that the taxa file is identical to that used by front end:
#  avianfluapp/src/assets/taxa.json
species <- jsonlite::read_json("api/config/taxa.json") |> 
   do.call(rbind, args = _) |> 
   as.data.frame()
names(species) <- c("species", "label")
species$species <- as.character(species$species)
species$label <- as.character(species$label)
species <- species[!species$species == "total", ]


#-------------------------------------------------------------------------------
# Load Population and Join to species
#-------------------------------------------------------------------------------

# File from  
# https://github.com/birdflow-science/BirdFlowWork/tree/main/population/data/final
pop <- read.csv("api/config/population.csv") |>
   dplyr::filter(species_code %in% species$species) |>
   dplyr::select(species = species_code, population = americas_pop)

species <- dplyr::left_join(species, pop, by = dplyr::join_by("species" == "species"))


#-------------------------------------------------------------------------------
# Load BirdFlow models
#-------------------------------------------------------------------------------
birdflow_options(collection_url = "https://birdflow-science.s3.amazonaws.com/avian_flu/")
index <- load_collection_index()
if(!all(species$species %in% index$species_code)) {
   miss <- setdiff(species$species, index$species_code)
   stop("Expected BirdFlow models:", paste(miss, collapse = ", "), " are missing from the model collection." )
}

# This is slow so skipping if it's already done - useful when developing to 
# avoid having to wait to reload. 
if(!exists("models") || !is.environment(models) || !all(species$species %in% names(models))) {
   models <- new.env()
   for (sp in species$species) {
      models[[sp]] <- load_model(model = sp)
   }
}

# Define extent of exported data (ai_app_extent)
corners = data.frame(x = c(-170, -170, -50, -50), y = c(10, 80, 10, 80))
csf <- sf::st_as_sf(corners,coords = c("x", "y"))
sf::st_crs(csf) <- "epsg:4326"

ai_app_crs <- sf::st_crs("EPSG:3857")
web_corners <- sf::st_transform(csf, ai_app_crs)
ai_app_extent <- terra::ext(web_corners)
rm(corners, csf, web_corners)


# Define local cache for temporary output images
# Will then be copied to AWS
local_cache <- tempdir()
if(!file.exists(local_cache))
   dir.create(local_cache)

## Create flow colors file -- might change later
# ebirdst::ebirdst_palettes(n = 256, type = "weekly") |> 
#   col2rgb() |> t() |> saveRDS(file = "api/config/flow_cols.Rds")

# Load flow colors
flow_colors <- readRDS("api/config/flow_cols.Rds")
