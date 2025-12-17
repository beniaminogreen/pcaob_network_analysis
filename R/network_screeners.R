
score_auditors <- function(data, bad_auditors_file) {
  known_bad_auditors <- read_csv(bad_auditors_file) %>%
    pull(firm_id)
  big4 <- c(
    "238",
    "185",
    "42",
    "34"
  )

# we must ensure that each firm is 'connected' to other firms by a client,
# otherwise the Laplacian matrix will be rank-deficient
    # connected_clients <- data %>%
    #   group_by(issuer_id) %>%
    #   filter(n_distinct(firm_id) > 1) %>%
    #   ungroup() %>%
    #   pull(issuer_cik) %>%
    #   unique()

    jaccard_data <- data %>%
      group_by(firm_id) %>%
      summarize(
        clients = list(unique(issuer_cik)),
        n_clients = n()
    ) %>%
      # mutate(
      #   connected = map_lgl(clients, ~ any(.x %in% connected_clients))
      # ) %>%
      # filter(connected) %>% # ensures similarity mat is full-rank
      mutate(
        known_bad = firm_id %in% known_bad_auditors,
        known_good = firm_id %in% big4,
        labelled = known_bad | known_good,
      ) %>%
      arrange(desc(labelled)) %>%
      ungroup()

    
    similarities <- get_matrixes(jaccard_data$clients)

    j <- sum(jaccard_data$labelled)
    labels <- propagate_labels(jaccard_data$clients, jaccard_data$known_good[1:j])
    fhat <- ecdf(labels)
    jaccard_data$labels <- fhat(labels)

    df <- jaccard_data %>% 
      select(firm_id, labels, n_clients)

    return(list(
      mats = similarities, 
      df = df
    ))
}




network_screener <- function(full_client_data, auditor_scores) {
  auditor_scores <- auditor_scores %>% 
    mutate(score = 1-labels)

  score_lookup <- auditor_scores$score
  names(score_lookup) <- as.character(auditor_scores$firm_id)

  full_client_data %>% 
    mutate(
      score = map_dbl(auditors, ~sum(score_lookup[as.character(.x)]))
    ) %>% 
    arrange(desc(score)) %>% 
    filter(marketcap > 10^8, exchange %in% c("NSYE", "NASDAQ"), n < 15) %>% 
    select(issuer_name,symbol, score, exchange, marketcap, n, n_auditors)  %>%
    print(n=50)

  full_client_data %>%  
    filter(symbol == "REKR") %>% 
    pull(description) %>% 
    cat()

}



