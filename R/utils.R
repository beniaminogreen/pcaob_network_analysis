clean_name <- function(string) {
  gsub(" ", "_", tolower(string))
}
parse_dates <- function(x) {
  as.Date(strptime(x, "%m/%d/%Y %I:%M:%S %p"))
}
