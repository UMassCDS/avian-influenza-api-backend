#' Rescale data to range between 0 and 1
#' 
#' Setting `max_value` to the overall maximum of a larger pool of data allows 
#' consistent re scaling across multiple data sets.
#'
#' @param x A vector of values to be rescaled
#' @param min_value,max_value (optional) if supplied these represent the 
#' minimum and maximum possible values across a larger pool of data than 
#' just `x` if not supplied they are calcualted from `x`
#'
#' @return x rescaled.
#' @export
#'
#' @examples
range_rescale <- function(x, min_value = NULL, max_value = NULL) {
  
  if (is.null(min_value))
    min_value <- min(x, na.rm = TRUE)
  if (is.null(max_value))
     max_value <- max(x, na.rm = TRUE)
  return((x - min_value)/(max_value - min_value))
}