/*===========================================
                Customer table
===========================================*/
SELECT
    TRIM(customer_id) AS customer_id,
    NULLIF(TRIM(customer_unique_id), '') AS customer_unique_id,
    NULLIF(TRIM(customer_zip_code_prefix), '') AS customer_zip_code_prefix,
    CASE
        WHEN TRIM(customer_city) = 'arraial d ajuda' 
            THEN 'arraial d''ajuda'
        WHEN TRIM(customer_city) = 'dias d avila'
            THEN 'dias d''avila'
        WHEN TRIM(customer_city) = 'itapage'
            THEN 'itapaje'
        WHEN TRIM(customer_city) = 'planaltina'
            AND UPPER(TRIM(customer_state)) = 'GO'
            THEN 'planaltina de goias'
        WHEN TRIM(customer_city) = 'brasopolis'
            THEN 'brazopolis'
        WHEN TRIM(customer_city) = 'piumhii'
            THEN 'piumhi'
        WHEN TRIM(customer_city) = 'bataipora'
            THEN 'bataypora'
        WHEN TRIM(customer_city) = 'sao jorge do oeste'
            THEN 'sao jorge d''oeste'
        WHEN TRIM(customer_city) = 'parati'
            THEN 'paraty'
        WHEN TRIM(customer_city) = 'embu'
            THEN 'embu das artes'
        WHEN TRIM(customer_city) = 'estrela d oeste'
            THEN 'estrela d''oeste'
        WHEN TRIM(customer_city) = 'mogi-mirim'
            THEN 'mogi mirim'
        WHEN TRIM(customer_city) = 'palmeira d oeste'
            THEN 'palmeira d''oeste'
        WHEN TRIM(customer_city) = 'santa barbara d oeste'
            THEN 'santa barbara d''oeste'
            ELSE NULLIF(TRIM(customer_city), '')
        END AS customer_city,
    CASE
        WHEN UPPER(TRIM(customer_state)) IN (
            'AC','AL','AP','AM','BA','CE','DF','ES','GO',
            'MA','MT','MS','MG','PA','PB','PR','PE','PI',
            'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
            )
        THEN UPPER(TRIM(customer_state))
        ELSE NULL
    END AS customer_state,
    _dwh_source_file,
    _dwh_source_system,
    _dwh_load_datetime,
    _dwh_batch_id
FROM bronze.olist_customers

/*===========================================
                Orders table
===========================================*/

SELECT
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
FROM bronze.olist_orders