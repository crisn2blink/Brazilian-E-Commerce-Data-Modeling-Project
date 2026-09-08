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
    ),
CONSTRAINT CK_customers_customer_state
    CHECK (customer_state IS NULL
    OR customer_state IN(
        'AC','AL','AP','AM','BA','CE','DF','ES','GO',
        'MA','MT','MS','MG','PA','PB','PR','PE','PI',
        'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
            )
    ),
CONSTRAINT CK_customers_customer_unique_id_valid
    CHECK (
        customer_unique_id_valid IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_customers_zip_code_prefix_valid
    CHECK (
        customer_zip_code_prefix_valid IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_customers_customer_state_valid
    CHECK (
        customer_state_valid IN ('Source Null', 'Valid', 'Invalid')
        )
);
GO

--Create silver layer table for olist_orders
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
    _dwh_batch_id UNIQUEIDENTIFIER,

CONSTRAINT PK_olist_orders
    PRIMARY KEY (order_id),
CONSTRAINT CK_orders_order_id_length
    CHECK (LEN(order_id) = 32),
CONSTRAINT CK_orders_customer_id_length
    CHECK (LEN(customer_id) = 32),
 CONSTRAINT CK_orders_customer_id_valid
    CHECK (
        customer_id_valid IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_orders_order_status
    CHECK (order_status IS NULL
    OR order_status IN(
        'delivered', 'approved', 'created', 'processing',
        'invoiced', 'unavailable', 'cancelled', 'shipped')
    ),
CONSTRAINT CK_orders_order_status_valid
    CHECK (order_status_valid IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_orders_order_purchase_timestamp_valid
    CHECK (order_purchase_timestamp_valid IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_orders_order_approved_at_valid
    CHECK (
        order_approved_at_valid
        IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_orders_order_delivered_carrier_date_valid
    CHECK (
    order_delivered_carrier_date_valid
    IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_orders_order_delivered_customer_date_valid
    CHECK (
    order_delivered_customer_date_valid
    IN ('Source Null', 'Valid', 'Invalid')
        ),
CONSTRAINT CK_orders_order_estimated_delivery_date_valid
    CHECK (
    order_estimated_delivery_date_valid
    IN ('Source Null', 'Valid', 'Invalid')
        )
);
GO

--Create silver layer table for olist_order_items
IF OBJECT_ID ('silver.olist_order_items', 'U' ) IS NOT NULL
    DROP TABLE silver.olist_order_items;
CREATE TABLE silver.olist_order_items
(
    order_id VARCHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    total_order_items INT NOT NULL,
    product_id VARCHAR(32),
    product_id_valid VARCHAR(15),
    seller_id VARCHAR(32),
    seller_id_valid VARCHAR(15),
    shipping_limit_date DATETIME2(0),
    shipping_limit_date_valid VARCHAR(15),
    price DECIMAL(10,2),
    price_valid VARCHAR(15),
    freight_value DECIMAL(10,2),
    freight_value_valid VARCHAR(15),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER,

CONSTRAINT PK_order_items
    PRIMARY KEY (order_id, order_item_id),
CONSTRAINT CK_order_items_order_id_length
    CHECK (LEN(order_id) = 32),
CONSTRAINT CK_order_items_order_item_id_positive
    CHECK (order_item_id >= 1),
CONSTRAINT CK_order_items_product_id_length
    CHECK (LEN(product_id) = 32),
CONSTRAINT CK_order_items_product_id_valid
    CHECK (product_id_valid IN ('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_order_items_seller_id_length
    CHECK (LEN(seller_id) = 32),
CONSTRAINT CK_order_items_seller_id_valid
    CHECK (seller_id_valid IN ('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_order_items_shipping_limit_date_valid
    CHECK (shipping_limit_date_valid IN ('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_order_items_price_non_negative
    CHECK (price >= 0),
CONSTRAINT CK_order_items_price_valid
    CHECK (price_valid IN ('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_order_items_freight_value_non_negative
    CHECK (freight_value >= 0),
CONSTRAINT CK_order_items_freight_value_valid
    CHECK (freight_value_valid IN ('Source Null', 'Valid', 'Invalid'))
);

--Create silver layer table for olist_payments
IF OBJECT_ID ('silver.olist_payments', 'U') IS NOT NULL
    DROP TABLE silver.olist_payments;
CREATE TABLE silver.olist_payments
(
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(15),
    payment_type_valid VARCHAR(15),
    payment_installments INT,
    payment_installments_valid VARCHAR(15),
    payment_value DECIMAL(10,2),
    payment_value_valid VARCHAR(15),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER,

CONSTRAINT PK_payments
    PRIMARY KEY (order_id, payment_sequential),
CONSTRAINT CK_payments_order_id_length
    CHECK (LEN(TRIM(order_id)) = 32),
CONSTRAINT CK_payments_payment_sequential_positive
    CHECK (payment_sequential >= 1),
CONSTRAINT CK_payments_payment_type_category_consistency
    CHECK (payment_type IN(
        'credit_card', 'debit_card', 'voucher', 'boleto', 'not_defined')),
CONSTRAINT CK_payments_payment_type_valid
    CHECK (payment_type_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_payments_payment_installments_positive
    CHECK (payment_installments >= 1),
CONSTRAINT CK_payments_payment_installments_valid
    CHECK (payment_installments_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_payments_payment_value_positive
    CHECK (payment_value > 0),
CONSTRAINT CK_payments_payment_value_valid
    CHECK (payment_value_valid IN('Source Null', 'Valid', 'Invalid'))
);
GO
