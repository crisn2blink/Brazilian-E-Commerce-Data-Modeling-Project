/*===========================================
                Customer table
===========================================*/
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
WHERE LEN(TRIM(customer_id)) = 32

/*===========================================
                Orders table
===========================================*/

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
WHERE LEN(TRIM(order_id)) = 32

/*===========================================
                Order Items table
===========================================*/
WITH CTE_order_totals AS (
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

/*===========================================
                Payments table
===========================================*/
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
        WHEN TRY_CAST(TRIM(payment_value) AS DECIMAL(10,2)) >= 0 THEN 'Valid'
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

/*===========================================
                Products table
===========================================*/
SELECT 
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    _dwh_source_file,
    _dwh_source_system,
    _dwh_load_datetime,
    _dwh_batch_id
  FROM bronze.olist_products

SELECT*
FROM bronze.olist_products