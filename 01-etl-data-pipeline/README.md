## 01-ETL-Data-Pipeline README

## Part I Requirements

### Building the Data Warehouse/Pipeline & Performing ETL

Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making through the process of Extracting, Transforming and Loading the data.

- **Data Sources**: CRM, ERP systems

<br>

**STEPS**

- Upload data to SSMS from data sources
- Create the data architecture required (the database) to house the data (in our case, the medallion architecture)
- Transform and clean the data
- Create/Define the data model we will use for the final business objects (gold layer views) by establishing fact & dimension tables
- Load the data into business objects that will be used to perform Part II EDA (Exploratory Data Analysis)

<br>

🧰**SKILLS DEMONSTRATED**🧰

- Database Engineering
- Data Validation (true validation)
- Data Modeling
- Data Normalization
- Data Cleaning

* * *

<br>

## 🏗️ Data Architecture (structure for building the data warehouse)

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.
