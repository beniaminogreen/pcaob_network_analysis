suspicious_auditor_screener <- function(
    sanctioned_firms_file,
    full_client_data,
    firm_data) {

  # Get the Firm ID's of firms sanctioned by PACOB
  sanctioned_firm_ids <- read_csv(sanctioned_firms_file) %>%
    pull(firm_id)

  # Identify clients who have worked with sanctioned firms
  client_data <- full_client_data %>%
    mutate(
      any_sanctioned_auditor = map_lgl(auditors, ~ any(sanctioned_firm_ids %in% .x)),
      num_sanctioned_auditor = map_dbl(auditors, ~ sum(sanctioned_firm_ids %in% .x))
    )

  # Idenfity clients of sanctioned_firms
  clients_of_sanctioned_firm <- client_data %>%
    filter(any_sanctioned_auditor) %>%
    pull(issuer_cik)

  # Then figure out for each firm, what share of clients have worked with sanctioned auditors
  firm_data <- firm_data %>%
    mutate(
      share_sanctioned = map_dbl(clients, ~ mean(.x %in% clients_of_sanctioned_firm)),
    ) %>%
    mutate(
      share_sanctioned = ifelse(firm_id %in% sanctioned_firm_ids, 1, share_sanctioned)
    )

  # Now highlight auditors who work with more than 5 clients and have more than 
  # 20% of clients who came from sanctioned firms
  screened_auditors <- firm_data %>%
    filter(
      share_sanctioned > .2, n_clients > 5 
    ) %>% 
    pull(firm_id)

  full_client_data <- client_data %>%
    filter(
      exchange %in% c("NYSE", "NASDAQ"),
      isactivelytrading,
    ) %>%
    mutate(
      years_since_ipo = interval(ipodate, today()) %/% years(1)
    )

  screened_stocks <- full_client_data %>%
    mutate(
      contaminated_auditor = map_lgl(auditors, ~ any(screened_auditors %in% .x))
    ) %>% 
    filter(
       contaminated_auditor | num_sanctioned_auditor > 1
    ) %>%
    arrange(desc(marketcap)) %>%
    select(symbol, issuer_name, marketcap, industry, sector, any_sanctioned_auditor, num_sanctioned_auditor, ipodate) %>%
    filter((marketcap > 3 * 10^8) & (marketcap < 7.5*10^9)) %>%
    filter(!grepl("greif", issuer_name, ignore.case = TRUE)) # this is a retirement fund

  write_csv(screened_stocks, "screened.csv")

  return("screened.csv")
}

obscure_auditor_filter <- function(full_client_data, firm_data) {
  client_data <- full_client_data

  firms_of_big_clients <- client_data  %>% 
    filter(marketcap > 5*10^8) %>% 
    pull(auditors) %>% 
    unlist()

  n_clients <- table(firms_of_big_clients)
  firms_with_one_big_client <- names(n_clients[n_clients == 1])

  df <- client_data %>% 
    filter(
      map_lgl(auditors, ~any(.x %in% firms_with_one_big_client)), 
      country == "US"
    ) %>%  
    arrange(desc(marketcap)) %>% 
    filter(n_auditors == 1) %>% 
    select(symbol, issuer_name, marketcap, industry, sector) 


  write_csv(df, "obscure_auditor_screened.csv")


  return("obscure_auditor_screened.csv")
}




