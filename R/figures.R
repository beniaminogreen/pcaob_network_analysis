create_histograms <- function(client_data){
  plt <- client_data %>% 
    ggplot(aes(x=n_auditors)) + 
    geom_histogram(binwidth =1) + 
    theme_minimal(base_size = 14) + 
    ggtitle("Number of Auditors Per Client") + 
    xlab("Number of Auditors Issuer has Used") + 
    ylab("Count")

  path <- "figures/n_auditors.png"
  ggsave(path, plot = plt, height = 4)

  return(path)
}

create_mcmc_plots <- function(mcmc_out) {
  good_transitions <- numeric(4)
  good_transitions[1] <- mcmc_out$p_good_transitions[1]
  good_transitions[2] <- mcmc_out$p_good_transitions[2] * mcmc_out$p_good_strong
  good_transitions[3] <- mcmc_out$p_good_transitions[3] * (1-mcmc_out$p_good_strong)
  good_transitions[4] <- mcmc_out$p_good_transitions[3]
  bad_transitions <- numeric(4)
  bad_transitions[1] <- mcmc_out$p_bad_transitions[1]
  bad_transitions[2] <- mcmc_out$p_bad_transitions[2] * mcmc_out$p_bad_strong
  bad_transitions[3] <- mcmc_out$p_bad_transitions[3] * (1-mcmc_out$p_bad_strong)
  bad_transitions[4] <- mcmc_out$p_bad_transitions[3]


  actions <- c(
    "Stay With Current Auditor", 
    "Switch to Strong Auditor", 
    "Switch to Weak Auditor", 
    "Shutdown / Go Out of Business"
  )
  actions <- factor(actions, levels = actions)

  good_df <- tibble(
    action = actions, 
    prob = good_transitions,
    firm = "Good"
  )
  bad_df <- tibble(
    action = actions, 
    prob = bad_transitions,
    firm = "Bad"
  )

  plt <- bind_rows(good_df, bad_df) %>% 
    ggplot(aes(x=action, y=firm, fill = prob)) + 
    geom_raster() + 
    geom_text(aes(label = round(prob,2)), col = "white") + 
    theme_minimal(base_size = 14) + 
    ylab("Firm Type") + 
    xlab("Transition Type") + 
    theme(
      legend.position = "none", 
      axis.text.x = element_text(angle = 45, hjust = 1),
    ) + 
    ggtitle("Estimated Transition Probabilities by Company Type") + 
    coord_equal()

  path <- "figures/transition_probabilities.png"
  ggsave(path, plot = plt, height = 4)

  return(path)
}

