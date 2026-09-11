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

CONSTRAINT PK_olist_order_items
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

CONSTRAINT PK_olist_payments
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

--Create silver layer table for olist_products
IF OBJECT_ID ('silver.olist_products', 'U') IS NOT NULL
    DROP TABLE silver.olist_products;
CREATE TABLE silver.olist_products
(
    product_id VARCHAR(32) NOT NULL,
    product_category_name NVARCHAR(100),
    product_category_name_valid VARCHAR(15),
    product_name_length INT,
    product_name_length_valid VARCHAR(15),
    product_description_length INT,
    product_description_length_valid VARCHAR(15),
    product_photos_qty INT,
    product_photos_qty_valid VARCHAR(15),
    product_weight_g INT,
    product_weight_g_valid VARCHAR(15),
    product_length_cm INT,
    product_length_cm_valid VARCHAR(15),
    product_height_cm INT,
    product_height_cm_valid VARCHAR(15),
    product_width_cm INT,
    product_width_cm_valid VARCHAR(15),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER,

CONSTRAINT PK_olist_products
    PRIMARY KEY (product_id),
CONSTRAINT CK_products_product_category_name_inclusion
    CHECK (product_category_name IN (
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
        )
    ),
CONSTRAINT CK_products_product_category_name_valid
    CHECK (product_category_name_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_name_length_positive
    CHECK (product_name_length >= 1),
CONSTRAINT CK_products_product_name_length_valid
    CHECK (product_name_length_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_description_length_positive
    CHECK (product_description_length >= 1),
CONSTRAINT CK_products_product_description_length_valid
    CHECK (product_description_length_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_photos_qty_positive
    CHECK (product_photos_qty >= 1),
CONSTRAINT CK_products_product_photos_qty_valid
    CHECK (product_photos_qty_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_weight_g_positive
    CHECK (product_weight_g >= 1),
CONSTRAINT CK_products_product_weight_g_valid
    CHECK (product_weight_g_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_length_cm_positive
    CHECK (product_length_cm >= 1),
CONSTRAINT CK_products_product_length_cm_valid
    CHECK (product_length_cm_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_height_cm_positive
    CHECK (product_height_cm >= 1),
CONSTRAINT CK_products_product_height_cm_valid
    CHECK (product_height_cm_valid IN('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_products_product_width_cm_positive
    CHECK (product_width_cm >= 1),
CONSTRAINT CK_products_product_width_cm_valid
    CHECK (product_width_cm_valid IN('Source Null', 'Valid', 'Invalid'))

);
GO

--Create silver layer table for olist_reviews
IF OBJECT_ID ('silver.olist_reviews', 'U') IS NOT NULL
    DROP TABLE silver.olist_reviews;
CREATE TABLE silver.olist_reviews(
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INT,
    review_score_valid VARCHAR(15),
    review_creation_date DATE,
    review_creation_date_valid VARCHAR(15),
    review_answer_timestamp DATETIME2(0),
    review_answer_timestamp_valid VARCHAR(15),
    _dwh_source_file NVARCHAR(255),
    _dwh_source_system NVARCHAR(50),
    _dwh_load_datetime DATETIME2(0),
    _dwh_batch_id UNIQUEIDENTIFIER,

CONSTRAINT PK_olist_reviews
    PRIMARY KEY (review_id, order_id),
CONSTRAINT CK_review_id_length
    CHECK (LEN(TRIM(review_id)) = 32),
CONSTRAINT CK_order_id_length
    CHECK (LEN(TRIM(order_id)) = 32),
CONSTRAINT CK_review_score_inclusion
    CHECK (review_score BETWEEN 1 AND 5),
CONSTRAINT CK_review_score_valid
    CHECK (review_score_valid IN ('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_review_creation_date_valid
    CHECK (review_creation_date_valid IN ('Source Null', 'Valid', 'Invalid')),
CONSTRAINT CK_review_answer_timestamp_valid
    CHECK (review_answer_timestamp_valid IN ('Source Null', 'Valid', 'Invalid'))
);
