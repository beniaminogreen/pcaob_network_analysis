clean_name <- function(string) {
  gsub(" ", "_", tolower(string))
}
