


#' Save JSON file with palette information
#' @param file The name of the json file to write the palette to
#' @param max The maximum value represented by the color scale.
#' @param min The minimum value represented by the color scale.
#' @param n The number of  values used to represent the color scale.
#' @param col_matrix A matrix with RGB values for each color displayed.  Should have
#' dimension of 256 x 3 and values 0 to 255. 
#' See abundance_cols and movement_cols defined in 00_set_ai_parameters.R 
#' for suitable objects.
#' @param stretch_first if not NULL set to the percentage of the color scale
#' bar that the first value should be stretched over. This is useful when, 
#' as in the ebirds abundance scale the color for zero is different then 
#' the remaining colors. When set the remaining colors get compressed slightly.
#' @return File is written, nothing is returned.
#' @export
#'
#' @examples
save_json_palette <- function(file, max, min = 0, n = 10, col_matrix, stretch_first = 2){
  
  # Note the ebird palette zero is not in the same gradient as the rest of the
  # palette.
  # When exporting I assigned a separate color to each of 256 different values
  # along the gradient meaning that only zero and very close to it get the zero
  # color. 
  # Here I first create the same 256 colors I used to export and then
  # subset to n, while keeping the first 2 colors but evenly spacing the 
  # remaining. This constrains the first (discontinous) color to an 
  # appropriately small part of the bar
  
  # May need to update with sqrt transformation ?!?!
  
  
  if(!grepl("\\.json$", file))
    stop("file should end in \".json\"")
  
  
  cols <- apply(col_matrix, 1,  function(x) rgb(x[1], x[2], x[3], maxColorValue = 255))
  # Full 256
  # cols <- ebirdst::ebirdst_palettes(n = 256, type = "weekly") 
  pal <- data.frame(color = cols, 
                    position = seq(from = 0, to = 100, length.out = length(cols)),
                    value = seq(from = min, to = max, length.out = length(cols)))

  # Subset taking first 2 values and evenly spacing remainder
  sv <- c(1, seq(from =  2, to = length(cols), length.out = n -1)) |> round()
  sub <- pal[sv, ]
  
  # Double first value and compress remaining positions to exaggerate first
  if(!is.null(stretch_first)){
    sub <- sub[c(1, seq_len(nrow(sub))), ]
    sub$position[2] <- stretch_first
    sv <- 3:nrow(sub)
    sub$position[sv] <- (sub$position[sv] + stretch_first) / (1 + stretch_first/100) 
  }
  
  
  # Round 
  sub$position <- round(sub$position, digits = 1)
  sub$value <- signif(sub$value, 3)
  
  # Clear row names (so they aren't in JSON)
  rownames(sub) <- NULL
  
  # Write to json 
  
  t <- jsonlite::toJSON(sub, pretty = TRUE) 
  writeLines(t, file)
  
    
}
