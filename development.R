library(targets)
library(tidyverse)


tar_read(full_client_data) %>% 
  mutate(avg_superceeded  = n_superceded / n) %>% 
  arrange(desc(avg_superceeded))  %>% 
  select(symbol, issuer_name, avg_superceeded, n, n_auditors, marketcap) %>% 
  drop_na()  %>%
  filter(
    avg_superceeded > .3, marketcap < 10^10,
    marketcap > 5*10^8, n_auditors > 1
  ) %>% 
  head(200) %>% 
  print(n=200)



