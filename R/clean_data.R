clean_data <- function(raw_data_file) {
  data <- read_csv(raw_data_file) %>%
    rename_with(clean_name) %>%
    mutate(
      audit_report_date = parse_dates(audit_report_date),
      fiscal_period_end_date = parse_dates(fiscal_period_end_date),
      report_year = year(audit_report_date),
      fiscal_year = year(fiscal_period_end_date)
    ) %>%
    filter(
      audit_report_type == "Issuer, other than Employee Benefit Plan or Investment Company"
    )

  return(data)
}

clean_firm_data <- function(auditor_data) {
  firm_level_data <- auditor_data %>%
    group_by(firm_id) %>%
    summarize(
      n_audits = n(),
      firm_name = firm_name[1],
      clients = list(unique(issuer_cik)),
      n_clients = n_distinct(issuer_cik)
    )

  firm_level_data
}

clean_client_data <- function(auditor_data) {
  superceded_filings <- unique(auditor_data$amends_firm_form_id)

  client_level_data <- auditor_data %>%
    group_by(issuer_cik) %>%
    summarize(
      issuer_name = issuer_name[1],
      n = n(),
      n_superceded = sum(form_filing_id %in% superceded_filings),
      n_auditors = n_distinct(firm_id),
      auditors = list(unique(firm_id))
    ) %>%
    drop_na() %>%
    filter(n > 1)

  client_level_data
}

get_api_data <- function(client_data) {
  ciks <- unique(pull(client_data, issuer_cik))

  api_key <- Sys.getenv("FINPREP_API_KEY")


  if (nchar(api_key) == 0) {
    stop("could not find API KEY")
  }

  data <- map(ciks, get_company_profile_by_cik, api_key = api_key) %>%
    bind_rows()

  return(data)
}


clean_1a_data <- function(raw_1a_file) {
  data <- read_csv(raw_1a_file) %>%
    rename_with(clean_name) %>%
    filter(
      inspection_type != "Annually Inspected",
      country == "United States",
    )

  firm_audit_data <- data %>%
    group_by(registration_id, inspection_year) %>%
    summarize(
      finding_count = n(),
      n_audits = n_distinct(issuer_reference_key)
    ) %>%
    group_by(registration_id) %>%
    summarize(
      n_audits = sum(n_audits),
      mean_issues = sum(finding_count) / sum(n_audits),
    )

  mean_issues_ecdf <- ecdf(firm_audit_data$mean_issues)

  firm_audit_data <- firm_audit_data %>%
    mutate(
      audit_issues_score = mean_issues_ecdf(mean_issues)
    )

  firm_audit_data %>%
    rename(
      n_one_a_audits = n_audits,
      firm_id = registration_id,
    )
}


augment_client_data  <- function(client_data, api_data) {
  api_data <- api_data %>% 
    rename_with(clean_name)

  full_client_data <- full_join(client_data, api_data,
    by = c("issuer_cik" = "cik")
  ) 

  return(full_client_data)
}




get_market_cap_data <- function(api_data) {

  api_key <- Sys.getenv("FINPREP_API_KEY")

  symbols <- api_data %>% 
    pull(symbol) %>% 
    unique() 

  output <- tibble(
    symbol = symbols
    )  %>% 
    drop_na()

  output %>% 
    mutate(
      historical_market_cap = map(symbol, 
        get_market_caps_by_symbol, 
        api_key = api_key
      )
    )
}
