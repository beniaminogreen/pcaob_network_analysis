# PACOB Stock Screener

This repository holds materials for my PACOB stock screener, which identifies NASDAQ and NYSE listed stocks in with market caps between $500M-10B that have anomalous audit histories.  Anomalous audit histories are defined as either a pattern of moving between audit firms, or routinely partnering with firms or audit partners who have been sanctioned for lax audit supervision, or historically have partnered with suspicious companies. The aim is to identify companies that have an elevated risk of a material misstatement on SEC filings.

Specifically, the code identifies identify: 

- Companies that routinely contract with audit firms that have been sanctioned by PACOB for lax oversight 
- Companies over $1B in market cap that are advised by firms that seem 'too small' or by firms that mostly audit firms in a different sector
- Companies that appear to "audit-shop", or switch between auditors frequently, especially if they switch between firms that have either been sanctioned by PACOB or shutdown by the S.E.C.

## Data Sources

- [The PACOB Auditor Search](https://pcaobus.org/resources/auditorsearch), which provides historical data on the audit history of all publicly-traded companies
- [PACOB Enforcement Site](https://pcaobus.org/oversight/enforcement), which provides records of enforecment actions brought by PACOB against audit firms
- [Financial Modelling Prep](https://site.financialmodelingprep.com/), which provides information on market,cap, sector, etc for stocks by CIK (API key required).

