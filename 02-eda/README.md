## 02-EDA README

## Part II: EDA

A comprehensive collection of SQL scripts for data exploration, analytics, and reporting. These scripts cover various analyses such as database exploration, measures and metrics, time-based trends, cumulative analytics, segmentation, and more. This repository contains SQL queries designed to help data analysts and BI professionals quickly explore, segment, and analyze data within a relational database. Each script focuses on a specific analytical theme and demonstrates best practices for SQL queries. This project was done as part of a SQL masterclass (Data with Baraa). The document PDFs provided (project\_notes & project\_roadmap) are his creations and the credit for the graphics in these goes to Baraa.

* * *

<br>

## Part II Requirements

### Performing EDA (Exploratory Data Analysis)

Objective

Perform EDA using the output of Part I (the gold layer business views) to gain general business insights and to begin shaping the blueprint for the dashboard created in Part III

- **Data Sources**: gold layer business views

<br>

**STEPS**

- Run the EDA queries and record the results
- Summarize the results in a one-page document (summary page)

<br>

🧰**SKILLS DEMONSTRATED**🧰

- Data Analysis
- EDA
- Critical Thinking
- Understanding of Business Operations

* * *

<br>

## 🎯 EDA Analysis Breakdown

1. **Dimension Exploration:**
    - Identify the unique values (or categories) in each dimension
    - Recognizing how data might be grouped or segmented, which is useful for later analysis
    - Understanding the granularity of our dimensions as well as the hierarchical layers
2. **Date Exploration**: Find the dates for the range of orders
    - Identify the earliest and latest dates (boundaries)
    - Understand the time-span

Syntax:

MIN/MAX \[date dimensions\]

3. **Measure Exploration**
    - Calculate and find out the key metrics of our business (Big Numbers)
    - Highest level of aggregation/lowest level of details

Examples:

- SUM(Sales)
- AVG(price)
- SUM(quantity)
- COUNT(DISTINCT customer\_key)

4. **Magnitude Analysis**
    - Here we will start putting things together and really begin our analysis (this is basic).
    - Magnitude analysis is comparing the measure values **by categories**.
    - Helps us to understand the importance of different categories.

Scenarios:

- Total sales by country
- Total quantity by category
- Average price by products
- Total orders by customers

5. **Ranking Analysis**
    - Order the values and dimensions by measures
    - Top performers|Bottom performers

Examples:

- RANK \[dimension\] by \[measure\]
- RANK countries by total\_sales
- TOP 5 products by quantity
- BOTTOM 3 customers by total\_sales

6. **Change Over Time**  
    - Technique to analyze how a measure evolves over time
    - Helps to track trends and identify seasonality

Scenarios:

- Total sales by year
- Average cost by month

7. **Cumulative Analysis**: Running total & Moving Average
    - Used to aggregate the data progressively across time
    - Helps to understand whether our business is growing or declining
    - Very similar to change over time but cumulative

Case Use:

- Aggregate \[cumulative measure\] By \[date dimension\]

8. **Performance Analysis (YoY Analysis)**
    - Process of comparing the current value with a target value. 

Case Use:

- Current\[measure\] - Target\[measure\]

Scenarios:

- Current sales - Average sales
- Current year sales - previous year sales
- Current sales - lowest sales
- Highest sales - Current sales

9. **Part-to-Whole Analysis**
    - Proportional Analysis: Analyze how an individual part is performing compared to the overall, allowing us to understand which category has the greatest impact on the business.

Case Use:

- (\[measure\]/Total \[measure\]) \* 100 BY \[dimension\]

Examples:

- (Sales/Total Sales) \* 100 By Category
- (Quantity/Total Quantity) \* 100 By Country

10. **Data Segmentation Analysis**
    - Group the data based on a specific range
    - Helps to understand the correlation between two measures

Case Use:

- \[Measure\] by \[Measure\]

Scenarios:

- Total products By Sales Range
- Total customers By Age

THE RESULTS OF THE EDA ARE FOUND IN THE “SUMMARY PAGE” DOCUMENT IN THIS REPOSITORY

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
