# S&DS 365 Final Project

This repository holds materials for my PCAOB network analysis projects, which identifies publicly-traded securities that have anomalous audit histories.  Anomalous audit histories are defined as either a pattern of moving between audit firms, or routinely partnering with firms or audit partners who appear to provide lax audit supervision, or historically have partnered with suspicious companies. The aim is to identify companies that have an elevated risk of a material misstatement on SEC filings.

Specifically, the code identifies identify: 

- Companies that routinely contract with audit firms that have been sanctioned by PACOB for lax oversight 
- Companies that appear to "audit-shop", or switch between auditors frequently, especially if they switch between firms that have either been sanctioned by PACOB or shutdown by the S.E.C.
- Audit firms that routinely contact with companies that appear to be shopping for opinions. 

## Data Sources

- [The PACOB Auditor Search](https://pcaobus.org/resources/auditorsearch), which provides historical data on the audit history of all publicly-traded companies
- [PACOB Enforcement Site](https://pcaobus.org/oversight/enforcement), which provides records of enforecment actions brought by PACOB against audit firms
- [Financial Modelling Prep](https://site.financialmodelingprep.com/), which provides information on market,cap, sector, etc for stocks by CIK (API key required).
- [SEC EDGAR database](https://www.sec.gov/search-filings/edgar-search-assistance/accessing-edgar-data) which provides information on the filings filed by each company

## Replicating the analysis 

All of the code in this repository is in a [targets](https://books.ropensci.org/targets/) pipeline which allows you to replicate every figure with one command.
Simply run the following command in R, which will start building all the analytic outputs for the project.


```
targets::tar_make()
```
