parse_file <- function(location, min_date = NULL) {
  contents <- fromJSON(location)

  cik <- contents$cik 
  forms <- contents$filings$recent$form
  dates <- ymd(contents$filings$recent$filingDate)
  sizes <- contents$filings$recent$size

  if (!is.null(min_date)) {
    forms <- forms[dates > min_date]
    sizes <- sizes[dates > min_date]
    if (length(forms)==0) {
      tibble(
        cik = cik
      )
    }
  }

  yearly_restatements <-  sum("10-K/A" == forms)
  correspondence <-  sum("CORRESP" == forms)
  large_correspondence <-  sum("CORRESP" == forms[sizes > 10^4])
  late_10K <-  sum("NT 10-K" == forms)
  late_10Q <-  sum("NT 10-Q" == forms)

  tibble(
    cik = cik, 
    n_yearly_restatements = yearly_restatements, 
    n_correspondence = correspondence, 
    n_large_correspondence = large_correspondence,
    n_late_10K = late_10K, 
    n_late_10Q = late_10Q, 
    n_last_date = max(dates)
  )
}



get_sec_data <- function(files, min_date = NULL) {
  df <- future_map(files, safely(parse_file), min_date = min_date) %>% 
    keep(~ is.null(.x$error)) %>%     # 
    map("result") %>%
    bind_rows()

  return(df)
}

