library(tidyverse)
library(httr)
library(jsonlite)

prep_api_key <- "wxIrNPtf2Om3XJIAoNygqRhVUBvrPcuH"

auditor_data <- read_csv("FirmFilings.csv") %>%
  rename_with(clean_name) %>%
  filter(audit_report_type != "Employee Benefit Plan")

names(auditor_data)

big_5_auditors <- c(
  "Grant Thornton LLP",
  "KPMG LLP",
  "Ernst & Young LLP",
  "PricewaterhouseCoopers LLP",
  "Deloitte &  Touche LLP"
)

firm_level_data <- auditor_data %>%
  group_by(firm_id) %>%
  summarize(
    n_audits = n(),
    firm_name = firm_name[1],
    clients = list(unique(issuer_cik)),
    n_clients = n_distinct(issuer_cik)
  )

client_level_data <- auditor_data %>%
  group_by(issuer_cik) %>%
  summarize(
    issuer_name = issuer_name[1],
    n = n(),
    n_auditors = n_distinct(firm_id),
    auditors = list(unique(firm_id))
  ) %>%
  drop_na() %>%
  filter(n > 1)
