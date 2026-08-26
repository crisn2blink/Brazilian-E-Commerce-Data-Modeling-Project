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