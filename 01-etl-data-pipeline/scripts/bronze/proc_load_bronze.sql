/*
    Procedure: bronze.load_bronze
    Purpose: Full-refresh load of the nine Olist Bronze tables.

    IMPORTANT:
    - SQL Server must be able to read the directory: C:\Olist\
    - If your SQL Server-visible source folder is different, replace that path
      in the nine BULK INSERT statements before execution.
    - The geolocation CSV uses LF row endings (0x0a); the other eight attached
      source files use CRLF row endings (0x0d0a).
    - No explicit transaction/rollback is used by design.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [bronze].[load_bronze]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @load_datetime DATETIME2(0),
        @batch_id UNIQUEIDENTIFIER,
        @current_table NVARCHAR(255);

    SET @batch_start_time = GETDATE();
    SET @batch_id = NEWID();
    SET @current_table = N'Batch initialization';

    BEGIN TRY
        PRINT '=====================================';
        PRINT 'Loading Olist Bronze Layer';
        PRINT 'Batch ID: ' + CAST(@batch_id AS NVARCHAR(36));
        PRINT '=====================================';

        PRINT '-------------------------------------';
        PRINT 'Loading Olist Tables';
        PRINT '-------------------------------------';


        -- =====================================================
        -- 1. Load bronze.olist_customers
        -- Source: olist_customers_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_customers';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_customers';
        TRUNCATE TABLE bronze.olist_customers;

        PRINT '>> Creating Staging Table: #stg_olist_customers';
        DROP TABLE IF EXISTS #stg_olist_customers;
        CREATE TABLE #stg_olist_customers
        (
            customer_id NVARCHAR(100),
            customer_unique_id NVARCHAR(100),
            customer_zip_code_prefix NVARCHAR(100),
            customer_city NVARCHAR(100),
            customer_state NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_customers_dataset.csv';
        BULK INSERT #stg_olist_customers
        FROM 'C:\Olist\olist_customers_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_customers';
        INSERT INTO bronze.olist_customers
        (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            N'olist_customers_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_customers;

        DROP TABLE IF EXISTS #stg_olist_customers;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 2. Load bronze.olist_geolocation
        -- Source: olist_geolocation_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_geolocation';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_geolocation';
        TRUNCATE TABLE bronze.olist_geolocation;

        PRINT '>> Creating Staging Table: #stg_olist_geolocation';
        DROP TABLE IF EXISTS #stg_olist_geolocation;
        CREATE TABLE #stg_olist_geolocation
        (
            geolocation_zip_code_prefix NVARCHAR(100),
            geolocation_lat NVARCHAR(100),
            geolocation_lng NVARCHAR(100),
            geolocation_city NVARCHAR(100),
            geolocation_state NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_geolocation_dataset.csv';
        BULK INSERT #stg_olist_geolocation
        FROM 'C:\Olist\olist_geolocation_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_geolocation';
        INSERT INTO bronze.olist_geolocation
        (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            N'olist_geolocation_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_geolocation;

        DROP TABLE IF EXISTS #stg_olist_geolocation;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 3. Load bronze.olist_order_items
        -- Source: olist_order_items.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_order_items';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_order_items';
        TRUNCATE TABLE bronze.olist_order_items;

        PRINT '>> Creating Staging Table: #stg_olist_order_items';
        DROP TABLE IF EXISTS #stg_olist_order_items;
        CREATE TABLE #stg_olist_order_items
        (
            order_id NVARCHAR(100),
            order_item_id NVARCHAR(100),
            product_id NVARCHAR(100),
            seller_id NVARCHAR(100),
            shipping_limit_date NVARCHAR(100),
            price NVARCHAR(100),
            freight_value NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_order_items.csv';
        BULK INSERT #stg_olist_order_items
        FROM 'C:\Olist\olist_order_items.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_order_items';
        INSERT INTO bronze.olist_order_items
        (
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value,
            N'olist_order_items.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_order_items;

        DROP TABLE IF EXISTS #stg_olist_order_items;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 4. Load bronze.olist_orders
        -- Source: olist_orders_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_orders';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_orders';
        TRUNCATE TABLE bronze.olist_orders;

        PRINT '>> Creating Staging Table: #stg_olist_orders';
        DROP TABLE IF EXISTS #stg_olist_orders;
        CREATE TABLE #stg_olist_orders
        (
            order_id NVARCHAR(100),
            customer_id NVARCHAR(100),
            order_status NVARCHAR(100),
            order_purchase_timestamp NVARCHAR(100),
            order_approved_at NVARCHAR(100),
            order_delivered_carrier_date NVARCHAR(100),
            order_delivered_customer_date NVARCHAR(100),
            order_estimated_delivery_date NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_orders_dataset.csv';
        BULK INSERT #stg_olist_orders
        FROM 'C:\Olist\olist_orders_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_orders';
        INSERT INTO bronze.olist_orders
        (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date,
            N'olist_orders_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_orders;

        DROP TABLE IF EXISTS #stg_olist_orders;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 5. Load bronze.olist_payments
        -- Source: olist_payments_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_payments';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_payments';
        TRUNCATE TABLE bronze.olist_payments;

        PRINT '>> Creating Staging Table: #stg_olist_payments';
        DROP TABLE IF EXISTS #stg_olist_payments;
        CREATE TABLE #stg_olist_payments
        (
            order_id NVARCHAR(100),
            payment_sequential NVARCHAR(100),
            payment_type NVARCHAR(100),
            payment_installments NVARCHAR(100),
            payment_value NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_payments_dataset.csv';
        BULK INSERT #stg_olist_payments
        FROM 'C:\Olist\olist_payments_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_payments';
        INSERT INTO bronze.olist_payments
        (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value,
            N'olist_payments_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_payments;

        DROP TABLE IF EXISTS #stg_olist_payments;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 6. Load bronze.olist_products
        -- Source: olist_products_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_products';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_products';
        TRUNCATE TABLE bronze.olist_products;

        PRINT '>> Creating Staging Table: #stg_olist_products';
        DROP TABLE IF EXISTS #stg_olist_products;
        CREATE TABLE #stg_olist_products
        (
            product_id NVARCHAR(100),
            product_category_name NVARCHAR(100),
            product_name_lenght NVARCHAR(100),
            product_description_lenght NVARCHAR(100),
            product_photos_qty NVARCHAR(100),
            product_weight_g NVARCHAR(100),
            product_length_cm NVARCHAR(100),
            product_height_cm NVARCHAR(100),
            product_width_cm NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_products_dataset.csv';
        BULK INSERT #stg_olist_products
        FROM 'C:\Olist\olist_products_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_products';
        INSERT INTO bronze.olist_products
        (
            product_id,
            product_category_name,
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            product_id,
            product_category_name,
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm,
            N'olist_products_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_products;

        DROP TABLE IF EXISTS #stg_olist_products;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 7. Load bronze.olist_reviews
        -- Source: olist_reviews_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_reviews';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_reviews';
        TRUNCATE TABLE bronze.olist_reviews;

        PRINT '>> Creating Staging Table: #stg_olist_reviews';
        DROP TABLE IF EXISTS #stg_olist_reviews;
        CREATE TABLE #stg_olist_reviews
        (
            review_id NVARCHAR(100),
            order_id NVARCHAR(100),
            review_score NVARCHAR(100),
            review_comment_title NVARCHAR(100),
            review_comment_message NVARCHAR(250),
            review_creation_date NVARCHAR(100),
            review_answer_timestamp NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_reviews_dataset.csv';
        BULK INSERT #stg_olist_reviews
        FROM 'C:\Olist\olist_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_reviews';
        INSERT INTO bronze.olist_reviews
        (
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp,
            N'olist_reviews_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_reviews;

        DROP TABLE IF EXISTS #stg_olist_reviews;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 8. Load bronze.olist_sellers
        -- Source: olist_sellers_dataset.csv
        -- =====================================================
        SET @current_table = N'bronze.olist_sellers';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.olist_sellers';
        TRUNCATE TABLE bronze.olist_sellers;

        PRINT '>> Creating Staging Table: #stg_olist_sellers';
        DROP TABLE IF EXISTS #stg_olist_sellers;
        CREATE TABLE #stg_olist_sellers
        (
            seller_id NVARCHAR(100),
            seller_zip_code_prefix NVARCHAR(100),
            seller_city NVARCHAR(100),
            seller_state NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: olist_sellers_dataset.csv';
        BULK INSERT #stg_olist_sellers
        FROM 'C:\Olist\olist_sellers_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.olist_sellers';
        INSERT INTO bronze.olist_sellers
        (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            N'olist_sellers_dataset.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_olist_sellers;

        DROP TABLE IF EXISTS #stg_olist_sellers;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        -- =====================================================
        -- 9. Load bronze.product_category_translation
        -- Source: product_category_translation.csv
        -- =====================================================
        SET @current_table = N'bronze.product_category_translation';
        SET @start_time = GETDATE();
        SET @load_datetime = GETDATE();

        PRINT '>> Truncating Table: bronze.product_category_translation';
        TRUNCATE TABLE bronze.product_category_translation;

        PRINT '>> Creating Staging Table: #stg_product_category_translation';
        DROP TABLE IF EXISTS #stg_product_category_translation;
        CREATE TABLE #stg_product_category_translation
        (
            product_category_name NVARCHAR(100),
            product_category_name_english NVARCHAR(100)
        );

        PRINT '>> Bulk Inserting File Into Staging: product_category_translation.csv';
        BULK INSERT #stg_product_category_translation
        FROM 'C:\Olist\product_category_translation.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT '>> Inserting Data Into Bronze Table: bronze.product_category_translation';
        INSERT INTO bronze.product_category_translation
        (
            product_category_name,
            product_category_name_english,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        )
        SELECT
            product_category_name,
            product_category_name_english,
            N'product_category_translation.csv' AS _dwh_source_file,
            N'Olist' AS _dwh_source_system,
            @load_datetime AS _dwh_load_datetime,
            @batch_id AS _dwh_batch_id
        FROM #stg_product_category_translation;

        DROP TABLE IF EXISTS #stg_product_category_translation;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>>--------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '========================================';
        PRINT 'Loading of Bronze Layer is Complete';
        PRINT ' -Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT ' -Batch ID: ' + CAST(@batch_id AS NVARCHAR(36));
        PRINT '========================================';
    END TRY
    BEGIN CATCH
        PRINT '==============================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Table/Step: ' + COALESCE(@current_table, N'Unknown');
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Batch ID: ' + CAST(@batch_id AS NVARCHAR(36));
        PRINT '==============================================';

        THROW;
    END CATCH
END
GO