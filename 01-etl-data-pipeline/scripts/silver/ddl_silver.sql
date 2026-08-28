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
IF OBJECT_ID ('silver.olist_customers', 'U') IS NOT NULL
    DROP TABLE silver.olist_customers;
CREATE TABLE silver.olist_customers
(
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32),
    customer_unique_id_valid VARCHAR(15),
    customer_zip_code_prefix VARCHAR(5),
    customer_zip_code_prefix_valid VARCHAR(15),
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(2),
    customer_state_valid VARCHAR(15),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER,

CONSTRAINT PK_olist_customers
    PRIMARY KEY (customer_id),
CONSTRAINT CK_customers_customer_id_length
    CHECK (LEN(customer_id) = 32),
CONSTRAINT CK_customers_customer_unique_id_length
    CHECK (LEN(customer_unique_id) = 32),
CONSTRAINT CK_customers_zip_code_prefix
    CHECK (
        customer_zip_code_prefix IS NULL
        OR (
            LEN(customer_zip_code_prefix) = 5
            AND customer_zip_code_prefix NOT LIKE '%[^0-9]%'
        )
    )
);
GO

--Create table for olist_orders_dataset.csv
IF OBJECT_ID ('silver.olist_orders', 'U') IS NOT NULL
    DROP TABLE silver.olist_orders;
CREATE TABLE silver.olist_orders
(
    order_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32),
    customer_id_valid VARCHAR(15),
    order_status VARCHAR(15),
    order_status_valid VARCHAR(15),
    order_purchase_timestamp DATETIME2(0),
    order_purchase_timestamp_valid VARCHAR(15),
    order_approved_at DATETIME2(0),
    order_approved_at_valid VARCHAR(15),
    order_delivered_carrier_date DATETIME2(0),
    order_delivered_carrier_date_valid VARCHAR(15),
    order_delivered_customer_date DATETIME2(0),
    order_delivered_customer_date_valid VARCHAR(15),
    order_estimated_delivery_date DATETIME2(0),
    order_estimated_delivery_date_valid VARCHAR(15),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER

CONSTRAINT PK_olist_orders
    PRIMARY KEY (order_id),
CONSTRAINT CK_orders_order_id_length
    CHECK (LEN(order_id) = 32),
CONSTRAINT CK_orders_customer_id_length
    CHECK (LEN(customer_id) = 32)
);
GO