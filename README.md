# Liferay Data Analytics

This repository houses scripts used for various forms of data analysis across our organization.
Scripts are organized according to relevant systems and processes.

## SQL
### Description
A library of mysql scripts that can be used to explore data in various liferay systems. 
Symbolic references should be used in sql connection statements.	
Each system should have it's own config file. 

### Folder Structure
- connections/system-name.properties
- systemName/query.sql

## Tableau
### Description
SQL connections will be used in tableau.
Storing a map of connections and related datasources/reports will allow for some automation across tableau, if one SQL statement is altered.

### Folder Structure
- datasources/site/project
- reports/site/project

# Future Development

## Pentaho Kettle
### Description
ETL scripts and kettle routines used to build a data warehouse
### Folder Structure
- config
- transformations
- jobs

## Python/ R Programming
### Description
Provide a shared, organized, central space for analysts to share their research. 

This may break out into a separate repo since SQL and Data Warehouse components will require a different review process.
### Folder Structure
- config
- reports (jupyter)
- scripts
	- lib


# Contribute

We're just getting started, so we expect the organization of this repo to evolve over time. 