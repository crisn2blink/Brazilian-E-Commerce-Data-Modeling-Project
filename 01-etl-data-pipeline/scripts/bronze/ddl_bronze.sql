/*
===========================================================================================
DDL for all CRM environment csv files
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

--Create table for olist_customers_dataset.csv
IF OBJECT_ID ('bronze.olist_customers', 'U') IS NOT NULL
    DROP TABLE bronze.olist_customers;
CREATE TABLE bronze.olist_customers
(
    customer_id NVARCHAR(100),
    customer_unique_id NVARCHAR(100),
    customer_zip_code_prefix NVARCHAR(100),
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_geolocation_dataset.csv
IF OBJECT_ID ('bronze.olist_geolocation', 'U') IS NOT NULL
    DROP TABLE bronze.olist_geolocation;
CREATE TABLE bronze.olist_geolocation
(
    geolocation_zip_code_prefix NVARCHAR(100),
    geolocation_lat NVARCHAR(100),
    geolocation_lng NVARCHAR(100),
    geolocation_city NVARCHAR(100),
    geolocation_state NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_order_items.csv
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

--Create table for olist_orders_dataset.csv
IF OBJECT_ID ('bronze.olist_orders', 'U') IS NOT NULL
    DROP TABLE bronze.olist_orders;
CREATE TABLE bronze.olist_orders
(
    order_id NVARCHAR(100),
    customer_id NVARCHAR(100),
    order_status NVARCHAR(100),
    order_purchase_timestamp NVARCHAR(100),
    order_approved_at NVARCHAR(100),
    order_delivered_carrier_date NVARCHAR(100),
    order_delivered_customer_date NVARCHAR(100),
    order_estimated_delivery_date NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_payments_dataset.csv
IF OBJECT_ID ('bronze.olist_payments', 'U') IS NOT NULL
    DROP TABLE bronze.olist_payments;
CREATE TABLE bronze.olist_payments
(
    order_id NVARCHAR(100),
    payment_sequential NVARCHAR(100),
    payment_type NVARCHAR(100),
    payment_installments NVARCHAR(100),
    payment_value NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_products_dataset.csv
IF OBJECT_ID ('bronze.olist_products', 'U') IS NOT NULL
    DROP TABLE bronze.olist_products;
CREATE TABLE bronze.olist_products
(
    product_id NVARCHAR(100),
    product_category_name NVARCHAR(100),
    product_name_lenght NVARCHAR(100),
    product_description_lenght NVARCHAR(100),
    product_photos_qty NVARCHAR(100),
    product_weight_g NVARCHAR(100),
    product_length_cm NVARCHAR(100),
    product_height_cm NVARCHAR(100),
    product_width_cm NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_reviews_dataset.csv
IF OBJECT_ID ('bronze.olist_reviews', 'U') IS NOT NULL
    DROP TABLE bronze.olist_reviews;
CREATE TABLE bronze.olist_reviews
(
    review_id NVARCHAR(100),
    order_id NVARCHAR(100),
    review_score NVARCHAR(100),
    review_comment_title NVARCHAR(100),
    review_comment_message NVARCHAR(250),
    review_creation_date NVARCHAR(100),
    review_answer_timestamp NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_sellers_dataset.csv
IF OBJECT_ID ('bronze.olist_sellers', 'U') IS NOT NULL
    DROP TABLE bronze.olist_sellers;
CREATE TABLE bronze.olist_sellers
(
    seller_id NVARCHAR(100),
    seller_zip_code_prefix NVARCHAR(100),
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO

--Create table for olist_product_category_translation.csv
IF OBJECT_ID ('bronze.product_category_translation', 'U') IS NOT NULL
    DROP TABLE bronze.product_category_translation;
CREATE TABLE bronze.product_category_translation
(
    product_category_name NVARCHAR(100),
    product_category_name_english NVARCHAR(100),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER
);
GO