/*=====================================================================================
Stored Procedure: Load Olist Silver Layer (Bronze -> Silver)
=====================================================================================
Script Purpose:
  This stored procedure performs a full-refresh load of the Olist Silver layer from
  the Bronze layer.

  It performs the following actions:
  - Truncates each Silver table before loading it.
  - Applies the current Silver-layer cleansing, validation, standardization, and
    canonicalization logic from proc_load_silver2.sql.
  - Captures start/end times for every individual Silver table load.
  - Reports the duration of every table load and of the complete Silver-layer batch.
  - Uses TRY/CATCH error handling to surface the failed step, SQL Server error details,
    and a likely cause for common error numbers.
  - Uses the temp-table seller implementation (#seller_clean, #seller_expected_state,
    #seller_expected_city) to avoid the SQL Server expression-services limit.

Parameters:
  None.

Usage Example:
  EXEC silver.load_silver;
=====================================================================================*/
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @batch_start_time DATETIME2(3), @batch_end_time DATETIME2(3);
    DECLARE @customers_start_time DATETIME2(3), @customers_end_time DATETIME2(3);
    DECLARE @orders_start_time DATETIME2(3), @orders_end_time DATETIME2(3);
    DECLARE @order_items_start_time DATETIME2(3), @order_items_end_time DATETIME2(3);
    DECLARE @payments_start_time DATETIME2(3), @payments_end_time DATETIME2(3);
    DECLARE @products_start_time DATETIME2(3), @products_end_time DATETIME2(3);
    DECLARE @reviews_start_time DATETIME2(3), @reviews_end_time DATETIME2(3);
    DECLARE @sellers_start_time DATETIME2(3), @sellers_end_time DATETIME2(3);
    DECLARE @current_step NVARCHAR(200) = N'Procedure initialization';

    SET @batch_start_time = SYSDATETIME();

    BEGIN TRY
        PRINT '============================================================';
        PRINT 'Loading Olist Silver Layer';
        PRINT '============================================================';
        PRINT '';

        /*=================================================================
          Customers table
        =================================================================*/
        SET @customers_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_customers - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_customers';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_customers';
        TRUNCATE TABLE silver.olist_customers;

        SET @current_step = N'silver.olist_customers - insert';
        PRINT '>> Inserting Data Into: silver.olist_customers';

        INSERT INTO silver.olist_customers
                (
                    customer_id,
                    customer_unique_id,
                    customer_unique_id_valid,
                    customer_zip_code_prefix,
                    customer_zip_code_prefix_valid,
                    customer_city,
                    customer_state,
                    customer_state_valid,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT
            TRIM(customer_id) AS customer_id,
            CASE
                WHEN LEN(TRIM(customer_unique_id)) = 32 THEN TRIM(customer_unique_id)
                ELSE NULL
            END AS customer_unique_id,
            CASE
                WHEN NULLIF(TRIM(customer_unique_id), '') IS NULL THEN 'Source Null'
                WHEN LEN(TRIM(customer_unique_id)) = 32 THEN 'Valid'
                ELSE 'Invalid'
            END AS customer_unique_id_valid,
            CASE
                WHEN LEN(TRIM(customer_zip_code_prefix)) = 5 AND TRIM(customer_zip_code_prefix) NOT LIKE '%[^0-9]%'
                THEN TRIM(customer_zip_code_prefix)
                ELSE NULL
            END AS customer_zip_code_prefix,
            CASE
                WHEN NULLIF(TRIM(customer_zip_code_prefix), '') IS NULL THEN 'Source Null'
                WHEN LEN(TRIM(customer_zip_code_prefix)) = 5 AND TRIM(customer_zip_code_prefix) NOT LIKE '%[^0-9]%'
                THEN 'Valid'
                ELSE 'Invalid'
            END AS customer_zip_code_prefix_valid,
            CASE
                WHEN TRIM(customer_city) = 'arraial d ajuda' THEN 'arraial d''ajuda'
                WHEN TRIM(customer_city) = 'dias d avila' THEN 'dias d''avila'
                WHEN TRIM(customer_city) = 'itapage' THEN 'itapaje'
                WHEN TRIM(customer_city) = 'planaltina' AND UPPER(TRIM(customer_state)) = 'GO' THEN 'planaltina de goias'
                WHEN TRIM(customer_city) = 'brasopolis' THEN 'brazopolis'
                WHEN TRIM(customer_city) = 'piumhii' THEN 'piumhi'
                WHEN TRIM(customer_city) = 'bataipora' THEN 'bataypora'
                WHEN TRIM(customer_city) = 'sao jorge do oeste' THEN 'sao jorge d''oeste'
                WHEN TRIM(customer_city) = 'parati' THEN 'paraty'
                WHEN TRIM(customer_city) = 'embu' THEN 'embu das artes'
                WHEN TRIM(customer_city) = 'estrela d oeste' THEN 'estrela d''oeste'
                WHEN TRIM(customer_city) = 'mogi-mirim' THEN 'mogi mirim'
                WHEN TRIM(customer_city) = 'palmeira d oeste' THEN 'palmeira d''oeste'
                WHEN TRIM(customer_city) = 'santa barbara d oeste' THEN 'santa barbara d''oeste'
                ELSE NULLIF(TRIM(customer_city), '')
            END AS customer_city,
            CASE
                WHEN UPPER(TRIM(customer_state)) IN (
                    'AC','AL','AP','AM','BA','CE','DF','ES','GO',
                    'MA','MT','MS','MG','PA','PB','PR','PE','PI',
                    'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
                    ) THEN UPPER(TRIM(customer_state))
                ELSE NULL
            END AS customer_state,
            CASE
                WHEN NULLIF(UPPER(TRIM(customer_state)), '') IS NULL THEN 'Source Null'
                WHEN UPPER(TRIM(customer_state)) IN(
                    'AC','AL','AP','AM','BA','CE','DF','ES','GO',
                    'MA','MT','MS','MG','PA','PB','PR','PE','PI',
                    'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
                    ) THEN 'Valid'
                ELSE 'Invalid'
            END AS customer_state_valid,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        FROM bronze.olist_customers
        WHERE LEN(TRIM(customer_id)) = 32;

        SET @customers_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @customers_start_time, @customers_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        /*=================================================================
          Orders table
        =================================================================*/
        SET @orders_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_orders - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_orders';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_orders';
        TRUNCATE TABLE silver.olist_orders;

        SET @current_step = N'silver.olist_orders - insert';
        PRINT '>> Inserting Data Into: silver.olist_orders';

        INSERT INTO silver.olist_orders
                (
                    order_id,
                    customer_id,
                    customer_id_valid,
                    order_status,
                    order_status_valid,
                    order_purchase_timestamp,
                    order_purchase_timestamp_valid,
                    order_approved_at,
                    order_approved_at_valid,
                    order_delivered_carrier_date,
                    order_delivered_carrier_date_valid,
                    order_delivered_customer_date,
                    order_delivered_customer_date_valid,
                    order_estimated_delivery_date,
                    order_estimated_delivery_date_valid,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT
            TRIM(order_id) AS order_id,
            CASE
                WHEN LEN(TRIM(customer_id)) = 32 THEN TRIM(customer_id)
                ELSE NULL
            END AS customer_id,
            CASE
                WHEN NULLIF(TRIM(customer_id), '') IS NULL THEN 'Source Null'
                WHEN LEN(TRIM(customer_id)) = 32 THEN 'Valid'
                ELSE 'Invalid'
            END AS customer_id_valid,
            CASE
                WHEN TRIM(order_status) IN ('delivered', 'approved', 'created', 'processing', 'invoiced', 'unavailable', 'cancelled', 'shipped')
                THEN TRIM(order_status)
                ELSE NULL
            END AS order_status,
            CASE
                WHEN NULLIF(TRIM(order_status), '') IS NULL THEN 'Source Null'
                WHEN TRIM(order_status) IN ('delivered', 'approved', 'created', 'processing', 'invoiced', 'unavailable', 'cancelled', 'shipped')
                THEN 'Valid'
                ELSE 'Invalid'
            END AS order_status_valid,
            TRY_CAST(NULLIF(TRIM(order_purchase_timestamp), '') AS DATETIME2(0)) AS order_purchase_timestamp,
            CASE
                WHEN NULLIF(TRIM(order_purchase_timestamp), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(NULLIF(TRIM(order_purchase_timestamp), '') AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS order_purchase_timestamp_valid,
            TRY_CAST(NULLIF(TRIM(order_approved_at), '') AS DATETIME2(0)) AS order_approved_at,
            CASE
                WHEN NULLIF(TRIM(order_approved_at), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(NULLIF(TRIM(order_approved_at), '') AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS order_approved_at_valid,
            TRY_CAST(NULLIF(TRIM(order_delivered_carrier_date), '') AS DATETIME2(0)) AS order_delivered_carrier_date,
            CASE
                WHEN NULLIF(TRIM(order_delivered_carrier_date), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(NULLIF(TRIM(order_delivered_carrier_date), '') AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS order_delivered_carrier_date_valid,
            TRY_CAST(NULLIF(TRIM(order_delivered_customer_date), '') AS DATETIME2(0)) AS order_delivered_customer_date,
            CASE
                WHEN NULLIF(TRIM(order_delivered_customer_date), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(NULLIF(TRIM(order_delivered_customer_date), '') AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS order_delivered_customer_date_valid,
            TRY_CAST(NULLIF(TRIM(order_estimated_delivery_date), '') AS DATETIME2(0)) AS order_estimated_delivery_date,
            CASE
                WHEN NULLIF(TRIM(order_estimated_delivery_date), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(NULLIF(TRIM(order_estimated_delivery_date), '') AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS order_estimated_delivery_date_valid,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        FROM bronze.olist_orders
        WHERE LEN(TRIM(order_id)) = 32;

        SET @orders_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @orders_start_time, @orders_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        /*=================================================================
          Order Items table
        =================================================================*/
        SET @order_items_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_order_items - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_order_items';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_order_items';
        TRUNCATE TABLE silver.olist_order_items;

        SET @current_step = N'silver.olist_order_items - insert';
        PRINT '>> Inserting Data Into: silver.olist_order_items';

        ;WITH CTE_order_totals AS (
            SELECT*,
                COUNT(*) OVER(PARTITION BY TRIM(order_id)) AS total_order_items
            FROM bronze.olist_order_items
            WHERE
                LEN(TRIM(order_id)) = 32
                AND TRIM(order_item_id) <> ''
                AND TRIM(order_item_id) NOT LIKE '%[^0-9]%'
                AND TRY_CAST(TRIM(order_item_id) AS INT) IS NOT NULL
                AND TRY_CAST(TRIM(order_item_id) AS INT) >= 1
        )
        INSERT INTO silver.olist_order_items
                (
                    order_id,
                    order_item_id,
                    total_order_items,
                    product_id,
                    product_id_valid,
                    seller_id,
                    seller_id_valid,
                    shipping_limit_date,
                    shipping_limit_date_valid,
                    price,
                    price_valid,
                    freight_value,
                    freight_value_valid,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT
            TRIM(order_id) AS order_id,
            CAST(TRIM(order_item_id) AS INT) AS order_item_id,
            total_order_items,
            CASE
                WHEN LEN(TRIM(product_id)) = 32 THEN TRIM(product_id)
                ELSE NULL
            END AS product_id,
            CASE
                WHEN NULLIF(TRIM(product_id), '') IS NULL THEN 'Source Null'
                WHEN LEN(TRIM(product_id)) = 32 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_id_valid,
            CASE
                WHEN LEN(TRIM(seller_id)) = 32 THEN TRIM(seller_id)
                ELSE NULL
            END AS seller_id,
            CASE
                WHEN (NULLIF(TRIM(seller_id), '')) IS NULL THEN 'Source Null'
                WHEN LEN(TRIM(seller_id)) = 32 THEN 'Valid'
                ELSE 'Invalid'
            END AS seller_id_valid,
            TRY_CAST(NULLIF(TRIM(shipping_limit_date), '') AS DATETIME2(0)) AS shipping_limit_date,
            CASE
                WHEN NULLIF(TRIM(shipping_limit_date), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(NULLIF(TRIM(shipping_limit_date), '') AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS shipping_limit_date_valid,
            CASE
                WHEN TRY_CAST(TRIM(price) AS DECIMAL(10,2)) >= 0 THEN TRY_CAST(TRIM(price) AS DECIMAL(10,2))
                ELSE NULL
            END AS price,
            CASE
                WHEN NULLIF(TRIM(price), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(price) AS DECIMAL(10,2)) >= 0 THEN 'Valid'
                ELSE 'Invalid'
            END AS price_valid,
            CASE
                WHEN TRY_CAST(TRIM(freight_value) AS DECIMAL(10,2)) >=0 THEN TRY_CAST(TRIM(freight_value) AS DECIMAL(10,2))
                ELSE NULL
            END AS freight_value,
            CASE
                WHEN NULLIF(TRIM(freight_value), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(freight_value) AS DECIMAL(10,2)) >=0 THEN 'Valid'
                ELSE 'Invalid'
            END AS freight_value_valid,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        FROM CTE_order_totals;

        SET @order_items_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @order_items_start_time, @order_items_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        /*=================================================================
          Payments table
        =================================================================*/
        SET @payments_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_payments - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_payments';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_payments';
        TRUNCATE TABLE silver.olist_payments;

        SET @current_step = N'silver.olist_payments - insert';
        PRINT '>> Inserting Data Into: silver.olist_payments';

        INSERT INTO silver.olist_payments
                (
                    order_id,
                    payment_sequential,
                    payment_type,
                    payment_type_valid,
                    payment_installments,
                    payment_installments_valid,
                    payment_value,
                    payment_value_valid,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT
            TRIM(order_id) AS order_id,
            CAST(TRIM(payment_sequential) AS INT) AS payment_sequential,
            CASE
                WHEN TRIM(payment_type) IN (
                'credit_card', 'debit_card', 'voucher', 'boleto', 'not_defined') THEN TRIM(payment_type)
                ELSE NULL
            END AS payment_type,
            CASE
                WHEN NULLIF(TRIM(payment_type), '') IS NULL THEN 'Source Null'
                WHEN TRIM(payment_type) IN ('credit_card', 'debit_card', 'voucher', 'boleto', 'not_defined')
                THEN 'Valid'
                ELSE 'Invalid'
            END AS payment_type_valid,
            CASE
                WHEN TRY_CAST(TRIM(payment_installments) AS INT) >= 1
                THEN TRY_CAST(TRIM(payment_installments) AS INT)
                ELSE NULL
            END AS payment_installments,
            CASE
                WHEN NULLIF(TRIM(payment_installments), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(payment_installments) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS payment_installments_valid,
            CASE
                WHEN TRY_CAST(TRIM(payment_value) AS DECIMAL(10,2)) > 0 THEN TRY_CAST(TRIM(payment_value) AS DECIMAL(10,2))
                ELSE NULL
            END AS payment_value,
            CASE
                WHEN NULLIF(TRIM(payment_value), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(payment_value) AS DECIMAL(10,2)) > 0 THEN 'Valid'
                ELSE 'Invalid'
            END AS payment_value_valid,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
          FROM bronze.olist_payments
          WHERE
            LEN(TRIM(order_id)) = 32
            AND TRIM(payment_sequential) <> ''
            AND TRIM(payment_sequential) NOT LIKE '%[^0-9]%'
            AND TRY_CAST(TRIM(payment_sequential) AS INT) IS NOT NULL
            AND TRY_CAST(TRIM(payment_sequential) AS INT) >= 1;

        SET @payments_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @payments_start_time, @payments_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        /*=================================================================
          Products table
        =================================================================*/
        SET @products_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_products - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_products';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_products';
        TRUNCATE TABLE silver.olist_products;

        SET @current_step = N'silver.olist_products - insert';
        PRINT '>> Inserting Data Into: silver.olist_products';

        INSERT INTO silver.olist_products
                (
                    product_id,
                    product_category_name,
                    product_category_name_valid,
                    product_name_length,
                    product_name_length_valid,
                    product_description_length,
                    product_description_length_valid,
                    product_photos_qty,
                    product_photos_qty_valid,
                    product_weight_g,
                    product_weight_g_valid,
                    product_length_cm,
                    product_length_cm_valid,
                    product_height_cm,
                    product_height_cm_valid,
                    product_width_cm,
                    product_width_cm_valid,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT 
            TRIM(product_id) AS product_id,
            CASE
                WHEN NULLIF(TRIM(product_category_name), '') IS NULL THEN NULL
                WHEN TRIM(product_category_name) IN(
                    'agro_industria_e_comercio',
                    'alimentos',
                    'alimentos_bebidas',
                    'artes',
                    'artes_e_artesanato',
                    'artigos_de_festas',
                    'artigos_de_natal',
                    'audio',
                    'automotivo',
                    'bebes',
                    'bebidas',
                    'beleza_saude',
                    'brinquedos',
                    'cama_mesa_banho',
                    'casa_conforto',
                    'casa_conforto_2',
                    'casa_construcao',
                    'cds_dvds_musicais',
                    'cine_foto',
                    'climatizacao',
                    'consoles_games',
                    'construcao_ferramentas_construcao',
                    'construcao_ferramentas_ferramentas',
                    'construcao_ferramentas_iluminacao',
                    'construcao_ferramentas_jardim',
                    'construcao_ferramentas_seguranca',
                    'cool_stuff',
                    'dvds_blu_ray',
                    'eletrodomesticos',
                    'eletrodomesticos_2',
                    'eletronicos',
                    'eletroportateis',
                    'esporte_lazer',
                    'fashion_bolsas_e_acessorios',
                    'fashion_calcados',
                    'fashion_esporte',
                    'fashion_roupa_feminina',
                    'fashion_roupa_infanto_juvenil',
                    'fashion_roupa_masculina',
                    'fashion_underwear_e_moda_praia',
                    'ferramentas_jardim',
                    'flores',
                    'fraldas_higiene',
                    'industria_comercio_e_negocios',
                    'informatica_acessorios',
                    'instrumentos_musicais',
                    'la_cuisine',
                    'livros_importados',
                    'livros_interesse_geral',
                    'livros_tecnicos',
                    'malas_acessorios',
                    'market_place',
                    'moveis_colchao_e_estofado',
                    'moveis_cozinha_area_de_servico_jantar_e_jardim',
                    'moveis_decoracao',
                    'moveis_escritorio',
                    'moveis_quarto',
                    'moveis_sala',
                    'musica',
                    'papelaria',
                    'pc_gamer',
                    'pcs',
                    'perfumaria',
                    'pet_shop',
                    'portateis_casa_forno_e_cafe',
                    'portateis_cozinha_e_preparadores_de_alimentos',
                    'relogios_presentes',
                    'seguros_e_servicos',
                    'sinalizacao_e_seguranca',
                    'tablets_impressao_imagem',
                    'telefonia',
                    'telefonia_fixa',
                    'utilidades_domesticas'
                ) THEN TRIM(product_category_name)
                ELSE NULL
            END AS product_category_name,
            CASE
                WHEN NULLIF(TRIM(product_category_name), '') IS NULL THEN 'Source Null'
                WHEN TRIM(product_category_name) IN(
                    'agro_industria_e_comercio',
                    'alimentos',
                    'alimentos_bebidas',
                    'artes',
                    'artes_e_artesanato',
                    'artigos_de_festas',
                    'artigos_de_natal',
                    'audio',
                    'automotivo',
                    'bebes',
                    'bebidas',
                    'beleza_saude',
                    'brinquedos',
                    'cama_mesa_banho',
                    'casa_conforto',
                    'casa_conforto_2',
                    'casa_construcao',
                    'cds_dvds_musicais',
                    'cine_foto',
                    'climatizacao',
                    'consoles_games',
                    'construcao_ferramentas_construcao',
                    'construcao_ferramentas_ferramentas',
                    'construcao_ferramentas_iluminacao',
                    'construcao_ferramentas_jardim',
                    'construcao_ferramentas_seguranca',
                    'cool_stuff',
                    'dvds_blu_ray',
                    'eletrodomesticos',
                    'eletrodomesticos_2',
                    'eletronicos',
                    'eletroportateis',
                    'esporte_lazer',
                    'fashion_bolsas_e_acessorios',
                    'fashion_calcados',
                    'fashion_esporte',
                    'fashion_roupa_feminina',
                    'fashion_roupa_infanto_juvenil',
                    'fashion_roupa_masculina',
                    'fashion_underwear_e_moda_praia',
                    'ferramentas_jardim',
                    'flores',
                    'fraldas_higiene',
                    'industria_comercio_e_negocios',
                    'informatica_acessorios',
                    'instrumentos_musicais',
                    'la_cuisine',
                    'livros_importados',
                    'livros_interesse_geral',
                    'livros_tecnicos',
                    'malas_acessorios',
                    'market_place',
                    'moveis_colchao_e_estofado',
                    'moveis_cozinha_area_de_servico_jantar_e_jardim',
                    'moveis_decoracao',
                    'moveis_escritorio',
                    'moveis_quarto',
                    'moveis_sala',
                    'musica',
                    'papelaria',
                    'pc_gamer',
                    'pcs',
                    'perfumaria',
                    'pet_shop',
                    'portateis_casa_forno_e_cafe',
                    'portateis_cozinha_e_preparadores_de_alimentos',
                    'relogios_presentes',
                    'seguros_e_servicos',
                    'sinalizacao_e_seguranca',
                    'tablets_impressao_imagem',
                    'telefonia',
                    'telefonia_fixa',
                    'utilidades_domesticas'
                ) THEN 'Valid'
                ELSE 'Invalid'
            END AS product_category_name_valid,
            CASE
                WHEN NULLIF(TRIM(product_name_length), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_name_length) AS INT) >= 1 THEN TRY_CAST(TRIM(product_name_length) AS INT)
                ELSE NULL
            END AS product_name_length,
            CASE
                WHEN NULLIF(TRIM(product_name_length), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_name_length) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_name_length_valid,
            CASE
                WHEN NULLIF(TRIM(product_description_length), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_description_length) AS INT) >= 1 THEN TRY_CAST(TRIM(product_description_length) AS INT)
                ELSE NULL
            END AS product_description_length,
            CASE
                WHEN NULLIF(TRIM(product_description_length), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_description_length) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_description_length_valid,
            CASE
                WHEN NULLIF(TRIM(product_photos_qty), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_photos_qty) AS INT) >= 1 THEN TRY_CAST(TRIM(product_photos_qty) AS INT)
                ELSE NULL
            END AS product_photos_qty,
            CASE
                WHEN NULLIF(TRIM(product_photos_qty), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_photos_qty) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_photos_qty_valid,
            CASE
                WHEN NULLIF(TRIM(product_weight_g), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_weight_g) AS INT) >= 1 THEN TRY_CAST(TRIM(product_weight_g) AS INT)
                ELSE NULL
            END AS product_weight_g,
            CASE
                WHEN NULLIF(TRIM(product_weight_g), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_weight_g) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_weight_g_valid,
            CASE
                WHEN NULLIF(TRIM(product_length_cm), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_length_cm) AS INT) >= 1 THEN TRY_CAST(TRIM(product_length_cm) AS INT)
                ELSE NULL
            END AS product_length_cm,
            CASE
                WHEN NULLIF(TRIM(product_length_cm), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_length_cm) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_length_cm_valid,
            CASE
                WHEN NULLIF(TRIM(product_height_cm), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_height_cm) AS INT) >= 1 THEN TRY_CAST(TRIM(product_height_cm) AS INT)
                ELSE NULL
            END AS product_height_cm,
            CASE
                WHEN NULLIF(TRIM(product_height_cm), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_height_cm) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_height_cm_valid,
            CASE
                WHEN NULLIF(TRIM(product_width_cm), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(product_width_cm) AS INT) >= 1 THEN TRY_CAST(TRIM(product_width_cm) AS INT)
                ELSE NULL
            END AS product_width_cm,
            CASE
                WHEN NULLIF(TRIM(product_width_cm), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(product_width_cm) AS INT) >= 1 THEN 'Valid'
                ELSE 'Invalid'
            END AS product_width_cm_valid,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
          FROM bronze.olist_products
          WHERE LEN(TRIM(product_id)) =32;

        SET @products_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @products_start_time, @products_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        /*=================================================================
          Reviews table
        =================================================================*/
        SET @reviews_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_reviews - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_reviews';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_reviews';
        TRUNCATE TABLE silver.olist_reviews;

        SET @current_step = N'silver.olist_reviews - insert';
        PRINT '>> Inserting Data Into: silver.olist_reviews';

        INSERT INTO silver.olist_reviews
                (
                    review_id,
                    order_id,
                    review_score,
                    review_score_valid,
                    review_creation_date,
                    review_creation_date_valid,
                    review_answer_timestamp,
                    review_answer_timestamp_valid,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT
            TRIM(review_id) AS review_id,
            TRIM(order_id) AS order_id,
            CASE
                WHEN NULLIF(TRIM(review_score), '') IS NULL THEN NULL
                WHEN TRY_CAST(TRIM(review_score) AS INT) BETWEEN 1 AND 5 THEN TRY_CAST(TRIM(review_score) AS INT)
                ELSE NULL
            END AS review_score,
            CASE
                WHEN NULLIF(TRIM(review_score), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(review_score) AS INT) BETWEEN 1 AND 5 THEN 'Valid'
                ELSE 'Invalid'
            END AS review_score_valid,
            TRY_CAST(NULLIF(TRIM(review_creation_date), '') AS DATE) AS review_creation_date,
            CASE
                WHEN NULLIF(TRIM(review_creation_date), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(review_creation_date) AS DATE) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS review_creation_date_valid,
            TRY_CAST(NULLIF(TRIM(review_answer_timestamp), '') AS DATETIME2(0)) AS review_answer_timestamp,
            CASE
                WHEN NULLIF(TRIM(review_answer_timestamp), '') IS NULL THEN 'Source Null'
                WHEN TRY_CAST(TRIM(review_answer_timestamp) AS DATETIME2(0)) IS NOT NULL THEN 'Valid'
                ELSE 'Invalid'
            END AS review_answer_timestamp_valid,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        FROM bronze.olist_reviews
        WHERE
            LEN(TRIM(review_id)) = 32
            AND LEN(TRIM(order_id)) = 32;

        SET @reviews_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @reviews_start_time, @reviews_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        /*=================================================================
          Sellers table
        =================================================================*/
        SET @sellers_start_time = SYSDATETIME();
        SET @current_step = N'silver.olist_sellers - truncate';

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table: silver.olist_sellers';
        PRINT '------------------------------------------------------------';
        PRINT '>> Truncating Table: silver.olist_sellers';
        TRUNCATE TABLE silver.olist_sellers;
        PRINT '>> Building seller staging temp tables';

        --      -> Seller substep 1 of 4: Clean base seller fields
        PRINT '   -> Seller substep 1/4: Cleaning base seller fields';
        SET @current_step = N'silver.olist_sellers - substep 1/4: clean base seller fields';

        DROP TABLE IF EXISTS #seller_clean;
        SELECT
            TRIM(seller_id) AS seller_id,
            seller_zip_code_prefix,
            CASE
                WHEN NULLIF(TRIM(seller_zip_code_prefix), '') IS NULL THEN NULL
                WHEN LEN(TRIM(seller_zip_code_prefix)) = 5
                     AND TRIM(seller_zip_code_prefix) NOT LIKE '%[^0-9]%'
                THEN TRIM(seller_zip_code_prefix)
                ELSE NULL
            END AS seller_zip_code_cleaned,
            TRIM(seller_city) AS seller_city,
            TRIM(seller_state) AS seller_state,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        INTO #seller_clean
        FROM bronze.olist_sellers
        WHERE LEN(TRIM(seller_id)) = 32;

        --      -> Seller substep 2 of 4: Determine expected state
        PRINT '   -> Seller substep 2/4: Determining expected state';
        SET @current_step = N'silver.olist_sellers - substep 2/4: determine expected state';

        DROP TABLE IF EXISTS #seller_expected_state;
        SELECT
            *,
            CASE
                WHEN seller_zip_code_cleaned BETWEEN '01000' AND '19999'
                    THEN 'SP'
                WHEN seller_zip_code_cleaned BETWEEN '20000' AND '28999'
                    THEN 'RJ'
                WHEN seller_zip_code_cleaned BETWEEN '29000' AND '29999'
                    THEN 'ES'
                WHEN seller_zip_code_cleaned BETWEEN '30000' AND '39999'
                    THEN'MG'
                WHEN seller_zip_code_cleaned BETWEEN '40000' AND '48999'
                    THEN 'BA'
                WHEN seller_zip_code_cleaned BETWEEN '49000' AND '49999'
                    THEN 'SE'
                WHEN seller_zip_code_cleaned BETWEEN '50000' AND '56999'
                    THEN 'PE'
                WHEN seller_zip_code_cleaned BETWEEN '57000' AND '57999'
                    THEN 'AL'
                WHEN seller_zip_code_cleaned BETWEEN '58000' AND '58999'
                    THEN 'PB'
                WHEN seller_zip_code_cleaned BETWEEN '59000' AND '59999'
                    THEN 'RN'
                WHEN seller_zip_code_cleaned BETWEEN '60000' AND '63999'
                    THEN 'CE'
                WHEN seller_zip_code_cleaned BETWEEN '64000' AND '64999'
                    THEN 'PI'
                WHEN seller_zip_code_cleaned BETWEEN '65000' AND '65999'
                    THEN 'MA'
                WHEN seller_zip_code_cleaned BETWEEN '66000' AND '68899'
                    THEN 'PA'
                WHEN seller_zip_code_cleaned BETWEEN '68900' AND '68999'
                    THEN 'AP'
                WHEN seller_zip_code_cleaned BETWEEN '69000' AND '69299'
                    THEN 'AM'
                WHEN seller_zip_code_cleaned BETWEEN '69300' AND '69399'
                    THEN 'RR'
                WHEN seller_zip_code_cleaned BETWEEN '69400' AND '69899'
                    THEN 'AM'
                WHEN seller_zip_code_cleaned BETWEEN '69900' AND '69999'
                    THEN 'AC'
                WHEN seller_zip_code_cleaned BETWEEN '70000' AND '72799'
                    THEN 'DF'
                WHEN seller_zip_code_cleaned BETWEEN '72800' AND '72999'
                    THEN 'GO'
                WHEN seller_zip_code_cleaned BETWEEN '73000' AND '73699'
                    THEN 'DF'
                WHEN seller_zip_code_cleaned BETWEEN '73700' AND '76799'
                    THEN 'GO'
                WHEN seller_zip_code_cleaned BETWEEN '76800' AND '76999'
                    THEN 'RO'
                WHEN seller_zip_code_cleaned BETWEEN '77000' AND '77999'
                    THEN 'TO'
                WHEN seller_zip_code_cleaned BETWEEN '78000' AND '78899'
                    THEN 'MT'
                WHEN seller_zip_code_cleaned BETWEEN '79000' AND '79999'
                    THEN 'MS'
                WHEN seller_zip_code_cleaned BETWEEN '80000' AND '87999'
                    THEN 'PR'
                WHEN seller_zip_code_cleaned BETWEEN '88000' AND '89999'
                    THEN 'SC'
                WHEN seller_zip_code_cleaned BETWEEN '90000' AND '99999'
                    THEN 'RS'
                    
                ELSE NULL
            END AS zip_expected_state
        INTO #seller_expected_state
        FROM #seller_clean;

        --      -> Seller substep 3 of 4: Correct / standardize city
        PRINT '   -> Seller substep 3/4: Correcting / standardizing city';
        SET @current_step = N'silver.olist_sellers - substep 3/4: correct / standardize city';

        DROP TABLE IF EXISTS #seller_expected_city;
        SELECT
            *,
            CASE
                WHEN NULLIF(seller_city, '') IS NULL
                    THEN NULL
            /* ======================================================
                ZIP-SPECIFIC CORRECTIONS
                These values cannot safely be corrected by city text
                alone, so seller_zip_code_prefix is used.
                ===================================================== */

                /* Bahia */
                WHEN TRIM(zip_expected_state) = 'BA'
                    AND TRIM(seller_city) = 'bahia'
                    AND TRIM(seller_zip_code_cleaned) = '48602'
                    THEN 'paulo afonso'

                /* Minas Gerais */
                WHEN TRIM(zip_expected_state) = 'MG'
                    AND TRIM(seller_city) = 'centro'
                    AND TRIM(seller_zip_code_cleaned) = '35660'
                    THEN 'para de minas'

                WHEN TRIM(zip_expected_state) = 'MG'
                    AND TRIM(seller_city) = 'minas gerais'
                    AND TRIM(seller_zip_code_cleaned) = '37165'
                    THEN 'campo do meio'

                /* Paraná */
                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) = 'parana'
                    AND TRIM(seller_zip_code_cleaned) = '87083'
                    THEN 'maringa'

                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) = 'vendas@creditparts.com.br'
                    AND TRIM(seller_zip_code_cleaned) = '87025'
                    THEN 'maringa'

                /* Rio de Janeiro */
                WHEN TRIM(zip_expected_state) = 'RJ'
                    AND TRIM(seller_city) = '04482255'
                    AND TRIM(seller_zip_code_cleaned) = '22790'
                    THEN 'rio de janeiro'

                WHEN TRIM(zip_expected_state) = 'RJ'
                    AND TRIM(seller_city) = 'rio de janeiro'
                    AND TRIM(seller_zip_code_cleaned) = '25900'
                    THEN 'mage'

                WHEN TRIM(zip_expected_state) = 'RJ'
                    AND TRIM(seller_city) = 'rio de janeiro'
                    AND TRIM(seller_zip_code_cleaned) = '28035'
                    THEN 'campos dos goytacazes'

                /* Santa Catarina */
                WHEN TRIM(zip_expected_state) = 'SC'
                    AND TRIM(seller_city) = 'santa catarina'
                    AND TRIM(seller_zip_code_cleaned) = '88135'
                    THEN 'palhoca'

                WHEN TRIM(zip_expected_state) = 'SC'
                    AND TRIM(seller_city) = 'sao jose'
                    AND TRIM(seller_zip_code_cleaned) = '88075'
                    THEN 'florianopolis'

                /* São Paulo */
                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sp'
                    AND TRIM(seller_zip_code_cleaned) = '04776'
                    THEN 'sao paulo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sp'
                    AND TRIM(seller_zip_code_cleaned) = '05141'
                    THEN 'sao paulo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sp'
                    AND TRIM(seller_zip_code_cleaned) = '12903'
                    THEN 'braganca paulista'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sp'
                    AND TRIM(seller_zip_code_cleaned) = '16021'
                    THEN 'aracatuba'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sp / sp'
                    AND TRIM(seller_zip_code_cleaned) = '03363'
                    THEN 'sao paulo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sao paulo'
                    AND TRIM(seller_zip_code_cleaned) = '09560'
                    THEN 'sao caetano do sul'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'tatui'
                    AND TRIM(seller_zip_code_cleaned) = '18500'
                    THEN 'laranjal paulista'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sao paulo'
                    AND TRIM(seller_zip_code_cleaned) = '37540'
                    THEN 'santa rita do sapucai'

                --STRAIGHTFORWARD SPELLING / FORMAT STANDARDIZATION
                
                /* Ceará */
                WHEN TRIM(zip_expected_state) = 'CE'
                    AND TRIM(seller_city) = 'juzeiro do norte'
                    THEN 'juazeiro do norte'

                /* Distrito Federal */
                WHEN TRIM(zip_expected_state) = 'DF'
                    AND TRIM(seller_city) = 'brasilia df'
                    THEN 'brasilia'

                /* Espírito Santo */
                WHEN TRIM(zip_expected_state) = 'ES'
                    AND TRIM(seller_city) = 'cariacica / es'
                    THEN 'cariacica'

                /* Minas Gerais */
                WHEN TRIM(zip_expected_state) = 'MG'
                    AND TRIM(seller_city) = 'barbacena/ minas gerais'
                    THEN 'barbacena'

                WHEN TRIM(zip_expected_state) = 'MG'
                    AND TRIM(seller_city) = 'belo horizont'
                    THEN 'belo horizonte'

                /* Paraná */
                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) = 'andira-pr'
                    THEN 'andira'

                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) = 'cascavael'
                    THEN 'cascavel'

                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) = 'paincandu'
                    THEN 'paicandu'

                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) = 'pinhais/pr'
                    THEN 'pinhais'

                WHEN TRIM(zip_expected_state) = 'PR'
                    AND TRIM(seller_city) IN (
                        'sao  jose dos pinhais',
                        'sao jose dos pinhas'
                    )
                    THEN 'sao jose dos pinhais'

                /* Rio de Janeiro */
                WHEN TRIM(zip_expected_state) = 'RJ'
                    AND TRIM(seller_city) = 'angra dos reis rj'
                    THEN 'angra dos reis'

                WHEN TRIM(zip_expected_state) = 'RJ'
                    AND TRIM(seller_city) IN (
                        'rio de janeiro / rio de janeiro',
                        'rio de janeiro \rio de janeiro',
                        'rio de janeiro, rio de janeiro, brasil'
                    )
                    THEN 'rio de janeiro'

                /* Rio Grande do Sul */
                WHEN TRIM(zip_expected_state) = 'RS'
                    AND TRIM(seller_city) =
                        'novo hamburgo, rio grande do sul, brasil'
                    THEN 'novo hamburgo'

                /* Santa Catarina */
                WHEN TRIM(zip_expected_state) = 'SC'
                    AND TRIM(seller_city) = 'balenario camboriu'
                    THEN 'balneario camboriu'

                WHEN TRIM(zip_expected_state) = 'SC'
                    AND TRIM(seller_city) = 'floranopolis'
                    THEN 'florianopolis'

                WHEN TRIM(zip_expected_state) = 'SC'
                    AND TRIM(seller_city) = 'lages - sc'
                    THEN 'lages'

                WHEN TRIM(zip_expected_state) = 'SC'
                    AND TRIM(seller_city) = 'sao miguel d''oeste'
                    THEN 'sao miguel do oeste'

                /* São Paulo */

                /* Remove state text while preserving locality granularity */
                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'aguas claras df'
                    THEN 'aguas claras'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        'ao bernardo do campo',
                        'sao bernardo do capo',
                        'sbc',
                        'sbc/sp'
                    )
                    THEN 'sao bernardo do campo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'auriflama/sp'
                    THEN 'auriflama'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'carapicuiba / sao paulo'
                    THEN 'carapicuiba'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'ferraz de  vasconcelos'
                    THEN 'ferraz de vasconcelos'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'garulhos'
                    THEN 'guarulhos'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'jacarei / sao paulo'
                    THEN 'jacarei'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'maua/sao paulo'
                    THEN 'maua'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        'mogi das cruses',
                        'mogi das cruzes / sp'
                    )
                    THEN 'mogi das cruzes'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'portoferreira'
                    THEN 'porto ferreira'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        'ribeirao preto / sao paulo',
                        'ribeirao pretp',
                        'riberao preto',
                        'robeirao preto'
                    )
                    THEN 'ribeirao preto'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        's jose do rio preto',
                        'sao jose do rio pret'
                    )
                    THEN 'sao jose do rio preto'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        'sando andre',
                        'santo andre/sao paulo'
                    )
                    THEN 'santo andre'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        'santa barbara d oeste',
                        'santa barbara d´oeste'
                    )
                    THEN 'santa barbara d''oeste'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) IN (
                        'sao  paulo',
                        'sao paulo - sp',
                        'sao paulo / sao paulo',
                        'sao paulo sp',
                        'sao paluo',
                        'sao paulop',
                        'sao pauo'
                    )
                    THEN 'sao paulo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = N'são paulo'
                    THEN 'sao paulo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'sao sebastiao da grama/sp'
                    THEN 'sao sebastiao da grama'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'scao jose do rio pardo'
                    THEN 'sao jose do rio pardo'

                WHEN TRIM(zip_expected_state) = 'SP'
                    AND TRIM(seller_city) = 'tabao da serra'
                    THEN 'taboao da serra'

                ELSE TRIM(seller_city)
            END AS expected_state_seller_city
        INTO #seller_expected_city
        FROM #seller_expected_state;

        --      -> Seller substep 4 of 4: Insert final seller rows
        PRINT '   -> Seller substep 4/4: Inserting final seller rows';
        SET @current_step = N'silver.olist_sellers - substep 4/4: insert final rows';

        INSERT INTO silver.olist_sellers
                (
                    seller_id,
                    seller_zip_code_cleaned,
                    seller_zip_code_cleaned_valid,
                    expected_state_seller_city,
                    zip_expected_state,
                    seller_location_consistency,
                    _dwh_source_file,
                    _dwh_source_system,
                    _dwh_load_datetime,
                    _dwh_batch_id
                )
        SELECT
            seller_id,
            seller_zip_code_cleaned,
            CASE
                WHEN NULLIF(TRIM(seller_zip_code_prefix), '') IS NULL
                    THEN 'Source Null'
                WHEN seller_zip_code_cleaned IS NOT NULL
                    THEN 'Valid'
                ELSE 'Invalid'
            END AS seller_zip_code_cleaned_valid,
            expected_state_seller_city,
            zip_expected_state,
            CASE
                WHEN seller_city = expected_state_seller_city
                     AND seller_state = zip_expected_state
                    THEN 'consistent'
                ELSE 'inconsistent'
            END AS seller_location_consistency,
            _dwh_source_file,
            _dwh_source_system,
            _dwh_load_datetime,
            _dwh_batch_id
        FROM #seller_expected_city;

        --      -> Seller temp-table cleanup (still subordinate to seller load)
        DROP TABLE IF EXISTS #seller_expected_city;
        DROP TABLE IF EXISTS #seller_expected_state;
        DROP TABLE IF EXISTS #seller_clean;

        SET @sellers_end_time = SYSDATETIME();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @sellers_start_time, @sellers_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '';

        SET @batch_end_time = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'Loading of Olist Silver Layer is Complete';
        PRINT 'Total Load Duration: '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '============================================================';
        PRINT '';

    END TRY
    BEGIN CATCH
        DECLARE @error_number INT = ERROR_NUMBER();
        DECLARE @error_severity INT = ERROR_SEVERITY();
        DECLARE @error_state INT = ERROR_STATE();
        DECLARE @error_line INT = ERROR_LINE();
        DECLARE @error_procedure NVARCHAR(256) = COALESCE(ERROR_PROCEDURE(), N'N/A');
        DECLARE @error_message NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @possible_cause NVARCHAR(4000);

        SET @possible_cause =
            CASE
                WHEN @error_number = 207
                    THEN N'Invalid column name. Verify the Bronze/Silver column definitions and aliases.'
                WHEN @error_number = 208
                    THEN N'Invalid object name. Verify that the referenced Bronze/Silver table or schema exists.'
                WHEN @error_number = 213
                    THEN N'INSERT column/value count mismatch. Verify the target column list against the SELECT list.'
                WHEN @error_number = 229
                    THEN N'Permission denied. Verify EXECUTE, SELECT, INSERT, and TRUNCATE permissions.'
                WHEN @error_number = 245
                    THEN N'Data type conversion failed. Review source values being converted to numeric or other typed columns.'
                WHEN @error_number = 515
                    THEN N'NULL was inserted into a NOT NULL column. Review required fields and filtering logic.'
                WHEN @error_number = 547
                    THEN N'A CHECK, FOREIGN KEY, or other constraint was violated.'
                WHEN @error_number = 1205
                    THEN N'The transaction was selected as a deadlock victim. Retry after the competing transaction clears.'
                WHEN @error_number = 1222
                    THEN N'Lock request timeout. Another session may be holding a conflicting lock.'
                WHEN @error_number = 2601
                    THEN N'Duplicate key violation on a unique index.'
                WHEN @error_number = 2627
                    THEN N'PRIMARY KEY or UNIQUE constraint violation caused by duplicate rows.'
                WHEN @error_number = 2628
                    THEN N'String or binary data would be truncated. A source value exceeds the target column length.'
                WHEN @error_number = 4712
                    THEN N'TRUNCATE TABLE is blocked because the table is referenced by a FOREIGN KEY constraint.'
                WHEN @error_number = 8114
                    THEN N'Error converting one data type to another. Review casts and target data types.'
                WHEN @error_number = 8115
                    THEN N'Arithmetic overflow. A numeric value exceeds the capacity of the target data type.'
                WHEN @error_number = 8152
                    THEN N'String or binary data would be truncated. A source value exceeds the target column length.'
                WHEN @error_number = 8632
                    THEN N'SQL Server expression-services limit reached. Review unusually complex expressions; the seller load already uses temp tables to reduce expression complexity.'
                WHEN @error_number = 9002
                    THEN N'The transaction log is full. Check log space, recovery model, and active transactions.'
                ELSE N'No predefined cause is mapped for this error number. Use the SQL Server error details below for diagnosis.'
            END;

        PRINT '============================================================';
        PRINT 'ERROR OCCURRED DURING LOADING OF OLIST SILVER LAYER';
        PRINT 'Failed Step: ' + COALESCE(@current_step, N'Unknown');
        PRINT 'Error Number: ' + CAST(@error_number AS NVARCHAR(20));
        PRINT 'Error Severity: ' + CAST(@error_severity AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(@error_state AS NVARCHAR(20));
        PRINT 'Error Procedure: ' + @error_procedure;
        PRINT 'Error Line: ' + CAST(@error_line AS NVARCHAR(20));
        PRINT 'Error Message: ' + @error_message;
        PRINT 'Possible Cause: ' + @possible_cause;
        PRINT '============================================================';

    END CATCH
END;
GO
