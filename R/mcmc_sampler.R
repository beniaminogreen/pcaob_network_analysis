run_mcmc_sampler <- function(cleaned_data, suspicious_auditors){
  big4 <- c(
    "238",
    "185",
    "42",
    "34"
  )
  frauds <- c(
    "0001648365", # Tingo
    "0001767582", # Luckin Coffee
    "0001849635", # DJT
    "0001376339", # Mimedx
    "0001731289", # Nikola
    "0001963685", # Ritchtech
    "0001069530",  # Cassava Sciences
    "0001840856", # Soundhound
    "0001824502", # ACHR
    "0001830214" # GINGKO 
  )
  known_good_issuers <- c(
    "0000320193", # Apple
    "0000789019", # Microsoft
    "0001652044", # Alphabet
    "0000104169", # Walmart
    "0001067983", # Berkshire
    "0001018724", # Amazon
    "0001116578", # Prudential
    "0001326801",  # Meta
    "0000884394", # SPY
    "0000200406" # JNJ 
  )

  known_bad_auditors <- read_csv(suspicious_auditors) %>%
    pull(firm_id)
  known_bad_auditors <- c(known_bad_auditors, 100)

  data <- cleaned_data %>% 
    filter(
      #audit_report_type != "Employee Benefit Plan"
      audit_report_type == "Issuer, other than Employee Benefit Plan or Investment Company"
    )

  data <- data %>%
    group_by(firm_id) %>%
    mutate(
      firm_last_audit = max(audit_report_date),
      firm_max_year = max(report_year),
      firm_closed = max(report_year) != 2025
    ) %>%
    ungroup() %>%
    group_by(issuer_cik) %>%
    mutate(
      issuer_last_year = max(fiscal_year),
      issuer_closed = issuer_last_year < 2024
    )  

  transition_data <- data %>%
    group_by(issuer_cik, fiscal_year) %>%
    arrange(audit_report_date) %>%
    filter(row_number() == n()) %>%
    group_by(issuer_cik) %>%
    mutate(
      switched = firm_id != lag(firm_id),
      firm_closed_down = (fiscal_year + 2) >= firm_max_year & firm_closed,
      prior_firm_closed_down = lag(firm_closed_down),
      issuer_closed_down = issuer_closed & fiscal_year == issuer_last_year
    )
  model_df <- transition_data %>%
    ungroup() %>%
    select(
      firm_id, firm_name,
      issuer_cik, issuer_name,
      fiscal_year, switched,
      firm_closed_down, prior_firm_closed_down,
      issuer_closed_down
    ) %>%
    drop_na() %>%
    group_by(issuer_cik) %>%
    mutate(
      switched = ifelse(row_number() == 1, T, switched)
    )
  network_data <- model_df %>% 
    group_by(firm_id) %>% 
    select(issuer_cik, firm_id) %>% 
    distinct() %>% 
    summarize(data = list(unique(issuer_cik)))

  firm_ids <- network_data$firm_id
  firm_lookup <- seq(firm_ids)
  names(firm_lookup) <- firm_ids

  issuer_ids <- unique(model_df$issuer_cik)
  issuer_lookup <- seq(issuer_ids)
  names(issuer_lookup) <- issuer_ids

# This is the STAN dataframe, mostly kept around for historical reasons (and to debug against my STAN MODEL) the STAN data is the same as the rust data, but arrays in rust are zero-indexed, while arrays in STAN are indexed from one. 
  stan_df <- model_df %>%
    ungroup() %>% 
    mutate(
      firm = firm_lookup[as.character(firm_id)],
      issuer = issuer_lookup[as.character(issuer_cik)],
      action = case_when(
        switched ~ 2,
        issuer_closed_down ~ 3,
        TRUE ~ 1
      )
    )

  rust_df <- stan_df %>% 
    group_by(issuer) %>% 
    arrange(fiscal_year) %>% 
    mutate(
      firm = firm - 1,
      issuer = issuer-1,
      action = ifelse(row_number() == 1, 0,action)
    )

  clients <- rust_df %>% 
    arrange(firm) %>% 
    group_by(firm) %>% 
    nest() %>% 
    mutate(clients = map(data, ~as.integer(unique(.x$issuer)))) %>% 
    pull(clients)

  issuer_trajectories <- rust_df   %>% 
    group_by(issuer) %>% 
    arrange(fiscal_year) %>% 
    nest()  %>% 
    mutate(actions = map(data, function(df) {
      map2(df$action, df$firm, ~as.integer(c(.x,.y)))
    }))  %>% 
    arrange(issuer) %>% 
    pull(actions)

  dataset <- Dataset$new()
  dataset$add_firm_clients(clients)
  dataset$add_issuer_trajectories(issuer_trajectories)
  dataset$add_labelled_observations(
    names(firm_lookup) %in% big4,
    names(firm_lookup) %in% known_bad_auditors, 
    names(issuer_lookup) %in% known_good_issuers,
    names(issuer_lookup) %in% frauds
  )

  out <- dataset$sample(20000,20000)

  names(out$p_good) <- issuer_ids
  names(out$p_strong) <- firm_ids

  return(out)
}





