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
if(!all(taxa$taxa %in% index$species_code)) {
   miss <- setdiff(taxa$taxa, index$species_code)
   stop("Expected BirdFlow models:", paste(miss, collapse = ", "), " are missing from the model collection." )
}

models <- new.env()
for (sp in taxa$taxa) {
   models[[sp]] <- load_model(model = sp)
}




