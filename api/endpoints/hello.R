library(plumber)

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* @apiTitle Simple API

#* Echo provided text
#* @param text The text to be echoed in the response
#* @get /echo
# Sample: http://0.0.0.0:8000/echo?text=hi4
function(text = "") {
  list(
    message_echo = paste("The text is:", text)
  )
}
