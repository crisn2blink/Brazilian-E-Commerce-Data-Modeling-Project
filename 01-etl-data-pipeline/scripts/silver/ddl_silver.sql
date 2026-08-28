/*
===========================================================================================
DDL for all silver layer tables
===========================================================================================
Script Purpose:
  This script creates tables in the 'bronze' schema, dropping existing tables if
  they already exist.
  The table scripts include four metadata columns that were added via a staging table process.
Run this script to re-define the DDL structure of 'bronze' tables
===========================================================================================
IMPORTANT NOTE: T-SQL: used in order to easily refresh the table's DDL on a as-needed basis
by dropping the table if it exists and recreating it with the most up-to-date values
from the source document.

*/

--Create silver layer table for olist_customers
IF OBJECT_ID ('bronze.olist_customers', 'U') IS NOT NULL
    DROP TABLE bronze.olist_customers;
CREATE TABLE bronze.olist_customers
(
    customer_id NVARCHAR(50) NOT NULL,
    customer_unique_id NVARCHAR(50),
    customer_zip_code_prefix VARCHAR(5),
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(5),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER

CONSTRAINT PK_customer_id
    PRIMARY KEY (customer_id)
);
GO

--Create silver layer table for olist_order_items.csv
IF OBJECT_ID ('bronze.olist_order_items', 'U') IS NOT NULL
    DROP TABLE bronze.olist_order_items;
CREATE TABLE bronze.olist_order_items
(
    order_id NVARCHAR(100),
    order_item_id NVARCHAR(100),
    product_id NVARCHAR(100),
    seller_id NVARCHAR(100),
    shipping_limit_date NVARCHAR(100),
    price NVARCHAR(100),
    freight_value NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO