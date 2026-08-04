# Brazilian-E-Commerce-Data-Modeling-Project


Welcome to the **Brazilian E-Commerce** repository! This is a three-part project that showcases a comprehensive data warehousing and analytics solution; from building a data warehouse to generating actionable insights through the creation of a business-intelligence dashboard. Designed as a portfolio project that highlights industry best practices in data engineering and analytics with an emphasis in the following areas:

#### <br>

- Creating a data pipeline based on Medallion data warehouse architecture
- ETL on a dataset (silver layer)
- Data enrichment and aggregation (gold layer)
- Normalize the data to create a data model
- Create a star schema data model schema with fact and dimension tables

<br>

Project Goal: To structure and organize the messy raw data to gain insight into business operations and create actionable insights for the business to implement. We will also identify current trends as well as risks.

<br>

#### Three Parts to the Project

1. Part I: ETL (Extract, Transform & Load) Data Pipeline Creation
2. Part II: EDA (Exploratory Data Analysis)
3. Part III: Power BI Dashboard

<br>

## The Dataset

For the project, I selected a dataset from the Kaggle website that originated from a commerce business and dealt with the sales data of an anonymous company.

- 9 tables
- 52 total columns

<br>

#### Kaggle Dataset Description

This is a Brazilian ecommerce public dataset of orders made at [Olist Store](http://www.olist.com/). The dataset has information of 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allows viewing an order from multiple dimensions: from order status, price, payment and freight performance to customer location, product attributes and finally reviews written by customers. We also released a geolocation dataset that relates Brazilian zip codes to lat/lng coordinates.

This is real commercial data, it has been anonymised, and references to the companies and partners in the review text have been replaced with the names of Game of Thrones great houses.

<br>

#### Kaggle Context

This dataset was generously provided by Olist, the largest department store in Brazilian marketplaces. Olist connects small businesses from all over Brazil to channels without hassle and with a single contract. Those merchants are able to sell their products through the Olist Store and ship them directly to the customers using Olist logistics partners. 

<br>

**NOTE**: All text identifying stores and partners where replaced by the names of Game of Thrones great houses.

<br>

## 🧭 How to Navigate this Repository

After reading the entirety of this very short README page to understand how the project is segmented, please feel free to proceed to Part I of this three part project via the folder titled:

- 01-etl-data-pipeline

<br>

Make sure to once again read the full README found within this folder and navigate through the folders inquisitively.

<br>

Once Part I has been covered, proceed in the same manner (making sure to read the README document in each Part folder) for the following two folders:

- 02-eda
- 03-dashboard

<br>
Ultimately, this will provide a clear picture of the overall project and will also highlight my abilities as a business analyst and data engineer (which is the entire point of this portfolio project).

<br>

## 📖 Full Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers. (Part I)
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse. (Part I)
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries. (Part I)
4. **EDA**: Performing Exploratory Data Analysis for the sake of gathering general business insights (Part II)
5. **Analytics & Dashboard Creation**: Creating Power BI interactive dashboard for actionable insights. (Part III)

<br>

## Project Requirements

### Part I: Building the Data Warehouse (Data Engineering) & Pipeline

Tools used: SSMS

#### Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

<br>

#### Specifications

- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

<br>

### Part II: EDA (Exploratory Data Analysis)

Tools used: SSMS

#### Objective

Perform initial EDA using the business objects (gold layer views) created in Part I to:

- Begin to understand general business KPIs.
- Understand the data and get a general snapshot of company performance.
- Begin aggregating information to build the business dashboard with.

<br>

### Part III: Power BI: Analytics & Reporting (Data Analytics)

Tools used: Power BI

#### Objective

Develop Power BI dashboard based on Part II EDA results to deliver detailed business insights into:

<br>

- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

<br>


These insights empower stakeholders with key business metrics, enabling strategic decision-making.

<br>

## 📂 General Repository Structure

<br>

## About Me
