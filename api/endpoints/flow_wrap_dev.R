require(plumber)

#* @param date The date to be echoed in the response
#* @get /flow
# Sample: http://0.0.0.0:8000/flow?date=text
function(date = "") {
  list(
    message_echo = paste(date, "is a date!")
  )
}
