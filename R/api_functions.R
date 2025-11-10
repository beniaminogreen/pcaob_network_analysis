# Required packages

#' Get company profile from Financial Modeling Prep by CIK
#'
#' @param cik Character or numeric. The company's Central Index Key (e.g., "320193" for Apple).
#' @param api_key Your FMP API key (if required; can be NULL for free tier).
#' @param wait_time Time in seconds to wait between requests to avoid exceeding 200/minute (default = 0.31).
#' @return A data frame containing company profile information.
#' @examples
#' get_company_profile_by_cik("320193")
get_company_profile_by_cik <- function(cik, api_key = NULL, wait_time = 0.15) {
  # Rate limiting (max 200 requests/min → wait ≥ 0.3 seconds)
  Sys.sleep(wait_time)

  # Build API URL
  base_url <- "https://financialmodelingprep.com/stable/profile-cik"
  params <- list(cik = cik)

  if (!is.null(api_key)) {
    params$apikey <- api_key
  }

  # Perform request
  res <- GET(base_url, query = params)

  # Handle HTTP errors
  if (http_error(res)) {
    warning(sprintf("Request failed [%s]: %s", status_code(res), http_status(res)$message))
    return(NULL)
  }

  # Parse and return JSON
  data <- fromJSON(content(res, as = "text", encoding = "UTF-8"))

  # Handle case when no data is returned
  if (length(data) == 0) {
    return(NULL)
  }

  return(as.data.frame(data))
}
