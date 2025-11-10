# PACOB Stock Screener

This repository holds materials for my PACOB stock screener, which identifies NASDAQ and NYSE listed stocks in the 500M-1B range that have anomalous audit histories.  The aim is to identify firms that have an elevated risk of a material misstatement on SEC filings.

Specifically, I identify: 

- Companies that routinely contract with audit firms that have been sanctioned by PACOB for lax oversight 
- Companies over $1B in market cap that are advised by firms that seem 'too small' or by firms that mostly audit firms in a different sector
- Companies that appear to "audit-shop", or switch between auditors frequently, especially if they switch between firms that have either been sanctioned by PACOB or shutdown by the S.E.C.

## Data Sources

- [The PACOB Auditor Search](https://pcaobus.org/resources/auditorsearch), which provides historical data on the audit history of all publicly-traded companies
- [PACOB Enforcement Site](https://pcaobus.org/oversight/enforcement), which provides records of enforecment actions brought by PACOB against audit firms
- [Financial Modelling Prep](https://site.financialmodelingprep.com/), which provides information on market,cap, sector, etc for stocks by CIK (API key required).

