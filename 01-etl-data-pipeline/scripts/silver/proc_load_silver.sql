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
        WHEN CAST(TRIM(product_name_length) AS INT) >= 1 THEN TRIM(product_name_length)
        ELSE NULL
    END AS product_name_length,
    CASE
        WHEN NULLIF(TRIM(product_name_length), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_name_length) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_name_length_valid,
    CASE
        WHEN NULLIF(TRIM(product_description_length), '') IS NULL THEN NULL
        WHEN CAST(TRIM(product_description_length) AS INT) >= 1 THEN TRIM(product_description_length)
        ELSE NULL
    END AS product_description_length,
    CASE
        WHEN NULLIF(TRIM(product_description_length), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_description_length) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_description_length_valid,
    CASE
        WHEN NULLIF(TRIM(product_photos_qty), '') IS NULL THEN NULL
        WHEN CAST(TRIM(product_photos_qty) AS INT) >= 1 THEN TRIM(product_photos_qty)
        ELSE NULL
    END AS product_photos_qty,
    CASE
        WHEN NULLIF(TRIM(product_photos_qty), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_photos_qty) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_photos_qty_valid,
    CASE
        WHEN NULLIF(TRIM(product_weight_g), '') IS NULL THEN NULL
        WHEN CAST(TRIM(product_weight_g) AS INT) >= 1 THEN TRIM(product_weight_g)
        ELSE NULL
    END AS product_weight_g,
    CASE
        WHEN NULLIF(TRIM(product_weight_g), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_weight_g) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_weight_g_valid,
    CASE
        WHEN NULLIF(TRIM(product_length_cm), '') IS NULL THEN NULL
        WHEN CAST(TRIM(product_length_cm) AS INT) >= 1 THEN TRIM(product_length_cm)
        ELSE NULL
    END AS product_length_cm,
    CASE
        WHEN NULLIF(TRIM(product_length_cm), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_length_cm) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_length_cm_valid,
    CASE
        WHEN NULLIF(TRIM(product_height_cm), '') IS NULL THEN NULL
        WHEN CAST(TRIM(product_height_cm) AS INT) >= 1 THEN TRIM(product_height_cm)
        ELSE NULL
    END AS product_height_cm,
    CASE
        WHEN NULLIF(TRIM(product_height_cm), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_height_cm) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_height_cm_valid,
    CASE
        WHEN NULLIF(TRIM(product_width_cm), '') IS NULL THEN NULL
        WHEN CAST(TRIM(product_width_cm) AS INT) >= 1 THEN TRIM(product_width_cm)
        ELSE NULL
    END AS product_width_cm,
    CASE
        WHEN NULLIF(TRIM(product_width_cm), '') IS NULL THEN 'Source Null'
        WHEN CAST(TRIM(product_width_cm) AS INT) >= 1 THEN 'Valid'
        ELSE NULL
    END AS product_width_cm_valid,
    _dwh_source_file,
    _dwh_source_system,
    _dwh_load_datetime,
    _dwh_batch_id
  FROM bronze.olist_products
  WHERE LEN(TRIM(product_id)) =32