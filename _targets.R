library(targets)

tar_option_set(packages = c("tidyverse", "httr", "jsonlite"))

tar_source()


readRenviron("~/.Renviron")

list(
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
  tar_target(one_a_data, clean_1a_data(raw_1a_data)),
  tar_target(firm_data, clean_firm_data(raw_pacob_data)),
  tar_target(client_data, clean_client_data(raw_pacob_data)),
  tar_target(api_data, get_api_data(client_data)),
  tar_target(full_client_data, augment_client_data(client_data, api_data)),
  tar_target(screener_1, suspicious_auditor_screener(
    raw_sanctioned_auditors,
    full_client_data,
    firm_data
  ),
  format = "file"
  ),
  tar_target(screener_2, obscure_auditor_filter(
    full_client_data,
    firm_data
  ),
  format = "file"
  )
)
