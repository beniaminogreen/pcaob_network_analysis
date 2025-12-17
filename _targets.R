library(targets)
library(furrr)

tar_option_set(
  packages = c(
    "tidyverse", "httr", 
    "jsonlite", "auditorinference", 
    "furrr", "lubridate"
  ),
  trust_timestamps = T, # important becuause we don't want to hash every SEC file
)

tar_source()

# allow for parallel processing of SEC files
plan(multisession, workers = 10)


# This stores the API key so it's not committed to github 
readRenviron("./.Renviron")

list(
  tar_target(
    sec_files, list.files("SEC/", full.names = T),
    format = "file"
  ),
  tar_target(raw_pacob_data,
    "FirmFilings.csv",
    format = "file"
  ),
  tar_target(raw_1a_data,
    "inspection-reports-part-1a-csv.csv",
    format = "file"
  ),
  tar_target(raw_sanctioned_auditors,
    "suspicious_auditors.csv",
    format = "file"
  ),

  # CLEAN and Process Raw Data
  tar_target(SEC_data, get_sec_data(sec_files)),
  tar_target(one_a_data, clean_1a_data(raw_1a_data)),
  tar_target(cleaned_data, clean_data(raw_pacob_data)),
  tar_target(firm_data, clean_firm_data(cleaned_data)),
  tar_target(client_data, clean_client_data(cleaned_data)),

  # FINPREP API DATA
  tar_target(api_data, get_api_data(client_data)),
  tar_target(marketcap_data, get_market_cap_data(api_data)),

  tar_target(full_client_data, augment_client_data(client_data, api_data)),

  # CALCUALTES AUDITOR SCORES from Harmonic Function Method (prototype)
  tar_target(naive_auditor_scores,score_auditors(cleaned_data, raw_sanctioned_auditors)), 
  
  # Run Stochastic block model via MCMC
  tar_target(mcmc_out, run_mcmc_sampler(cleaned_data, raw_sanctioned_auditors)),


  # CREATE FIGURES
  #
  tar_target(histograms, create_histograms(client_data), format = "file"),
  tar_target(mcmc_plots, create_mcmc_plots(mcmc_out), format = "file")

  # screener data
  # tar_target(screener_1, suspicious_auditor_screener(
  #   raw_sanctioned_auditors,
  #   full_client_data,
  #   firm_data
  # ),
  # format = "file"
  # ),
  # tar_target(screener_2, obscure_auditor_filter(
  #   full_client_data,
  #   firm_data
  # ),
  # format = "file"
  # )
)
