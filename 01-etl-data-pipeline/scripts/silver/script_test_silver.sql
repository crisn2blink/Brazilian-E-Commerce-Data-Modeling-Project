/*
===============================================================================
Silver Layer Quality Checks
===============================================================================

Project:
    Olist Brazilian E-Commerce Data Warehouse

Script Purpose:
    This script performs quality checks across the 'silver' layer to verify
    that data was transferred correctly from the Bronze Layer and that the
    Silver Layer transformation logic is working as intended.

    The checks focus on the most important areas:

    - Bronze-to-Silver row transfer integrity.
    - Primary key integrity.
    - Composite primary key integrity.
    - Missing expected records.
    - Unwanted spaces in important identifier fields.
    - Validation flag consistency.
    - Standardized categorical values.
    - Numeric range validation.
    - Date and timestamp consistency.
    - Derived-column consistency.
    - Cross-table relationship integrity.
    - Data warehouse metadata integrity.

Usage Notes:
    - Run these checks after loading the Silver Layer.
    - Queries marked "Expectation: No Results" should return zero rows.
    - Row-count checks should show no difference between expected Bronze
      records and Silver records.
    - DISTINCT / distribution queries are informational and should be reviewed.
    - Some NULL values are intentionally preserved because Silver Layer
      validation converts invalid/source-null attributes to NULL rather than
      deleting the entire record.
===============================================================================
*/


/*==============================================================================
                        CUSTOMER TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_customers'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Bronze records are eligible when customer_id contains exactly 32 characters.
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_customers
        WHERE LEN(TRIM(customer_id)) = 32
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_customers
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_customers
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_customers
        WHERE LEN(TRIM(customer_id)) = 32
    ) AS row_difference;


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM silver.olist_customers
GROUP BY customer_id
HAVING customer_id IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Primary Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(customer_id) AS customer_id
FROM bronze.olist_customers
WHERE LEN(TRIM(customer_id)) = 32

EXCEPT

SELECT
    customer_id
FROM silver.olist_customers;


-- Check Primary Key Length
-- Expectation: No Results

SELECT
    customer_id
FROM silver.olist_customers
WHERE LEN(customer_id) <> 32;


-- Check for Unwanted Spaces in Important Identifiers
-- Expectation: No Results

SELECT
    customer_id,
    customer_unique_id
FROM silver.olist_customers
WHERE customer_id <> TRIM(customer_id)
    OR customer_unique_id <> TRIM(customer_unique_id);


-- Check Customer Unique ID Validation Logic
-- Expectation: No Results

SELECT
    customer_id,
    customer_unique_id,
    customer_unique_id_valid
FROM silver.olist_customers
WHERE
       customer_unique_id_valid IS NULL
    OR customer_unique_id_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        customer_unique_id_valid = 'Valid'
        AND (
            customer_unique_id IS NULL
            OR LEN(customer_unique_id) <> 32
        )
    )

    OR (
        customer_unique_id_valid IN ('Invalid', 'Source Null')
        AND customer_unique_id IS NOT NULL
    );


-- Check ZIP Code Validation Logic
-- Expectation: No Results

SELECT
    customer_id,
    customer_zip_code_prefix,
    customer_zip_code_prefix_valid
FROM silver.olist_customers
WHERE
       customer_zip_code_prefix_valid IS NULL
    OR customer_zip_code_prefix_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        customer_zip_code_prefix_valid = 'Valid'
        AND (
            customer_zip_code_prefix IS NULL
            OR LEN(customer_zip_code_prefix) <> 5
            OR customer_zip_code_prefix LIKE '%[^0-9]%'
        )
    )

    OR (
        customer_zip_code_prefix_valid IN ('Invalid', 'Source Null')
        AND customer_zip_code_prefix IS NOT NULL
    );


-- Check State Validation Logic
-- Expectation: No Results

SELECT
    customer_id,
    customer_state,
    customer_state_valid
FROM silver.olist_customers
WHERE
       customer_state_valid IS NULL
    OR customer_state_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        customer_state_valid = 'Valid'
        AND customer_state NOT IN (
            'AC','AL','AP','AM','BA','CE','DF','ES','GO',
            'MA','MT','MS','MG','PA','PB','PR','PE','PI',
            'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
        )
    )

    OR (
        customer_state_valid IN ('Invalid', 'Source Null')
        AND customer_state IS NOT NULL
    );


-- Data Standardization & Consistency
-- Informational

SELECT DISTINCT
    customer_state,
    customer_state_valid
FROM silver.olist_customers
ORDER BY customer_state;



/*==============================================================================
                        ORDERS TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_orders'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_orders
        WHERE LEN(TRIM(order_id)) = 32
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_orders
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_orders
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_orders
        WHERE LEN(TRIM(order_id)) = 32
    ) AS row_difference;


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM silver.olist_orders
GROUP BY order_id
HAVING order_id IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Primary Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(order_id) AS order_id
FROM bronze.olist_orders
WHERE LEN(TRIM(order_id)) = 32

EXCEPT

SELECT
    order_id
FROM silver.olist_orders;


-- Check Primary Key Length
-- Expectation: No Results

SELECT
    order_id
FROM silver.olist_orders
WHERE LEN(order_id) <> 32;


-- Check for Unwanted Spaces in Important Identifiers
-- Expectation: No Results

SELECT
    order_id,
    customer_id
FROM silver.olist_orders
WHERE order_id <> TRIM(order_id)
    OR customer_id <> TRIM(customer_id);


-- Check Order Status Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    order_status,
    order_status_valid
FROM silver.olist_orders
WHERE
       order_status_valid IS NULL
    OR order_status_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        order_status_valid = 'Valid'
        AND order_status NOT IN (
            'delivered',
            'approved',
            'created',
            'processing',
            'invoiced',
            'unavailable',
            'cancelled',
            'shipped'
        )
    )

    OR (
        order_status_valid IN ('Invalid', 'Source Null')
        AND order_status IS NOT NULL
    );


-- Data Standardization & Consistency
-- Informational

SELECT
    order_status,
    order_status_valid,
    COUNT(*) AS record_count
FROM silver.olist_orders
GROUP BY
    order_status,
    order_status_valid
ORDER BY
    order_status;


-- Check Timestamp Value / Validation Flag Consistency
-- Expectation: No Results

SELECT
    o.order_id,
    v.column_name,
    v.date_value,
    v.valid_flag
FROM silver.olist_orders AS o

CROSS APPLY (
    VALUES
        (
            'order_purchase_timestamp',
            o.order_purchase_timestamp,
            o.order_purchase_timestamp_valid
        ),
        (
            'order_approved_at',
            o.order_approved_at,
            o.order_approved_at_valid
        ),
        (
            'order_delivered_carrier_date',
            o.order_delivered_carrier_date,
            o.order_delivered_carrier_date_valid
        ),
        (
            'order_delivered_customer_date',
            o.order_delivered_customer_date,
            o.order_delivered_customer_date_valid
        ),
        (
            'order_estimated_delivery_date',
            o.order_estimated_delivery_date,
            o.order_estimated_delivery_date_valid
        )
) AS v(column_name, date_value, valid_flag)

WHERE
       v.valid_flag IS NULL
    OR v.valid_flag NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        v.valid_flag = 'Valid'
        AND v.date_value IS NULL
    )

    OR (
        v.valid_flag IN ('Invalid', 'Source Null')
        AND v.date_value IS NOT NULL
    );


-- Check for Invalid Chronological Order
-- Expectation: No Results
--
-- Estimated delivery date is intentionally NOT included because an order
-- may legitimately be delivered after its estimated delivery date.

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM silver.olist_orders
WHERE
       order_approved_at < order_purchase_timestamp

    OR order_delivered_carrier_date < order_purchase_timestamp

    OR order_delivered_customer_date < order_purchase_timestamp

    OR order_delivered_customer_date < order_delivered_carrier_date;



/*==============================================================================
                        ORDER ITEMS TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_order_items'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Only rows meeting the required order_id and order_item_id rules
-- should reach Silver.
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_order_items
        WHERE
            LEN(TRIM(order_id)) = 32
            AND TRIM(order_item_id) <> ''
            AND TRIM(order_item_id) NOT LIKE '%[^0-9]%'
            AND TRY_CAST(TRIM(order_item_id) AS INT) IS NOT NULL
            AND TRY_CAST(TRIM(order_item_id) AS INT) >= 1
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_order_items
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_order_items
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_order_items
        WHERE
            LEN(TRIM(order_id)) = 32
            AND TRIM(order_item_id) <> ''
            AND TRIM(order_item_id) NOT LIKE '%[^0-9]%'
            AND TRY_CAST(TRIM(order_item_id) AS INT) IS NOT NULL
            AND TRY_CAST(TRIM(order_item_id) AS INT) >= 1
    ) AS row_difference;


-- Check for NULLs or Duplicates in Composite Primary Key
-- Expectation: No Results

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM silver.olist_order_items
GROUP BY
    order_id,
    order_item_id
HAVING
       order_id IS NULL
    OR order_item_id IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(order_id) AS order_id,
    TRY_CAST(TRIM(order_item_id) AS INT) AS order_item_id
FROM bronze.olist_order_items
WHERE
    LEN(TRIM(order_id)) = 32
    AND TRIM(order_item_id) <> ''
    AND TRIM(order_item_id) NOT LIKE '%[^0-9]%'
    AND TRY_CAST(TRIM(order_item_id) AS INT) IS NOT NULL
    AND TRY_CAST(TRIM(order_item_id) AS INT) >= 1

EXCEPT

SELECT
    order_id,
    order_item_id
FROM silver.olist_order_items;


-- Check Required Primary Key Values
-- Expectation: No Results

SELECT
    order_id,
    order_item_id
FROM silver.olist_order_items
WHERE
       LEN(order_id) <> 32
    OR order_item_id < 1;


-- Check total_order_items Derived Column
-- Expectation: No Results

WITH CTE AS (
    SELECT
        order_id,
        order_item_id,
        total_order_items,
        COUNT(*) OVER (
            PARTITION BY order_id
        ) AS recalculated_total_order_items

    FROM silver.olist_order_items
)

SELECT
    order_id,
    order_item_id,
    total_order_items,
    recalculated_total_order_items
FROM CTE
WHERE total_order_items <> recalculated_total_order_items;


-- Check Product ID Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    order_item_id,
    product_id,
    product_id_valid
FROM silver.olist_order_items
WHERE
       product_id_valid IS NULL
    OR product_id_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        product_id_valid = 'Valid'
        AND (
            product_id IS NULL
            OR LEN(product_id) <> 32
        )
    )

    OR (
        product_id_valid IN ('Invalid', 'Source Null')
        AND product_id IS NOT NULL
    );


-- Check Seller ID Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    order_item_id,
    seller_id,
    seller_id_valid
FROM silver.olist_order_items
WHERE
       seller_id_valid IS NULL
    OR seller_id_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        seller_id_valid = 'Valid'
        AND (
            seller_id IS NULL
            OR LEN(seller_id) <> 32
        )
    )

    OR (
        seller_id_valid IN ('Invalid', 'Source Null')
        AND seller_id IS NOT NULL
    );


-- Check Price Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    order_item_id,
    price,
    price_valid
FROM silver.olist_order_items
WHERE
       price_valid IS NULL
    OR price_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        price_valid = 'Valid'
        AND (
            price IS NULL
            OR price < 0
        )
    )

    OR (
        price_valid IN ('Invalid', 'Source Null')
        AND price IS NOT NULL
    );


-- Check Freight Value Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    order_item_id,
    freight_value,
    freight_value_valid
FROM silver.olist_order_items
WHERE
       freight_value_valid IS NULL
    OR freight_value_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        freight_value_valid = 'Valid'
        AND (
            freight_value IS NULL
            OR freight_value < 0
        )
    )

    OR (
        freight_value_valid IN ('Invalid', 'Source Null')
        AND freight_value IS NOT NULL
    );


-- Check Shipping Limit Date Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    order_item_id,
    shipping_limit_date,
    shipping_limit_date_valid
FROM silver.olist_order_items
WHERE
       shipping_limit_date_valid IS NULL
    OR shipping_limit_date_valid NOT IN (
        'Valid',
        'Invalid',
        'Source Null'
    )

    OR (
        shipping_limit_date_valid = 'Valid'
        AND shipping_limit_date IS NULL
    )

    OR (
        shipping_limit_date_valid IN ('Invalid', 'Source Null')
        AND shipping_limit_date IS NOT NULL
    );



/*==============================================================================
                        PAYMENTS TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_payments'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_payments
        WHERE
            LEN(TRIM(order_id)) = 32
            AND TRIM(payment_sequential) <> ''
            AND TRIM(payment_sequential) NOT LIKE '%[^0-9]%'
            AND TRY_CAST(TRIM(payment_sequential) AS INT) IS NOT NULL
            AND TRY_CAST(TRIM(payment_sequential) AS INT) >= 1
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_payments
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_payments
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_payments
        WHERE
            LEN(TRIM(order_id)) = 32
            AND TRIM(payment_sequential) <> ''
            AND TRIM(payment_sequential) NOT LIKE '%[^0-9]%'
            AND TRY_CAST(TRIM(payment_sequential) AS INT) IS NOT NULL
            AND TRY_CAST(TRIM(payment_sequential) AS INT) >= 1
    ) AS row_difference;


-- Check for NULLs or Duplicates in Composite Primary Key
-- Expectation: No Results

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM silver.olist_payments
GROUP BY
    order_id,
    payment_sequential
HAVING
       order_id IS NULL
    OR payment_sequential IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(order_id) AS order_id,
    TRY_CAST(TRIM(payment_sequential) AS INT) AS payment_sequential
FROM bronze.olist_payments
WHERE
    LEN(TRIM(order_id)) = 32
    AND TRIM(payment_sequential) <> ''
    AND TRIM(payment_sequential) NOT LIKE '%[^0-9]%'
    AND TRY_CAST(TRIM(payment_sequential) AS INT) IS NOT NULL
    AND TRY_CAST(TRIM(payment_sequential) AS INT) >= 1

EXCEPT

SELECT
    order_id,
    payment_sequential
FROM silver.olist_payments;


-- Check Required Primary Key Values
-- Expectation: No Results

SELECT
    order_id,
    payment_sequential
FROM silver.olist_payments
WHERE
       LEN(order_id) <> 32
    OR payment_sequential < 1;


-- Check Payment Type Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_type_valid
FROM silver.olist_payments
WHERE
       payment_type_valid IS NULL
    OR payment_type_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        payment_type_valid = 'Valid'
        AND payment_type NOT IN (
            'credit_card',
            'debit_card',
            'voucher',
            'boleto',
            'not_defined'
        )
    )

    OR (
        payment_type_valid IN ('Invalid', 'Source Null')
        AND payment_type IS NOT NULL
    );


-- Data Standardization & Consistency
-- Informational

SELECT
    payment_type,
    payment_type_valid,
    COUNT(*) AS record_count
FROM silver.olist_payments
GROUP BY
    payment_type,
    payment_type_valid
ORDER BY
    payment_type;


-- Check Payment Installment Validation Logic
-- Expectation: No Results

SELECT
    order_id,
    payment_sequential,
    payment_installments,
    payment_installments_valid
FROM silver.olist_payments
WHERE
       payment_installments_valid IS NULL
    OR payment_installments_valid NOT IN (
        'Valid',
        'Invalid',
        'Source Null'
    )

    OR (
        payment_installments_valid = 'Valid'
        AND (
            payment_installments IS NULL
            OR payment_installments < 1
        )
    )

    OR (
        payment_installments_valid IN ('Invalid', 'Source Null')
        AND payment_installments IS NOT NULL
    );


-- Check Payment Value Validation Logic
-- Expectation: No Results
--
-- IMPORTANT:
-- This will also identify a payment marked Valid where payment_value is NULL.

SELECT
    order_id,
    payment_sequential,
    payment_value,
    payment_value_valid
FROM silver.olist_payments
WHERE
       payment_value_valid IS NULL
    OR payment_value_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        payment_value_valid = 'Valid'
        AND (
            payment_value IS NULL
            OR payment_value <= 0
        )
    )

    OR (
        payment_value_valid IN ('Invalid', 'Source Null')
        AND payment_value IS NOT NULL
    );



/*==============================================================================
                        PRODUCTS TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_products'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_products
        WHERE LEN(TRIM(product_id)) = 32
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_products
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_products
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_products
        WHERE LEN(TRIM(product_id)) = 32
    ) AS row_difference;


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM silver.olist_products
GROUP BY product_id
HAVING product_id IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Primary Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(product_id) AS product_id
FROM bronze.olist_products
WHERE LEN(TRIM(product_id)) = 32

EXCEPT

SELECT
    product_id
FROM silver.olist_products;


-- Check Primary Key Length
-- Expectation: No Results

SELECT
    product_id
FROM silver.olist_products
WHERE LEN(product_id) <> 32;


-- Check Product Category Validation Logic
-- Expectation: No Results

SELECT
    product_id,
    product_category_name,
    product_category_name_valid
FROM silver.olist_products
WHERE
       product_category_name_valid IS NULL
    OR product_category_name_valid NOT IN (
        'Valid',
        'Invalid',
        'Source Null'
    )

    OR (
        product_category_name_valid = 'Valid'
        AND product_category_name IS NULL
    )

    OR (
        product_category_name_valid IN ('Invalid', 'Source Null')
        AND product_category_name IS NOT NULL
    );


-- Data Standardization & Consistency
-- Informational

SELECT
    product_category_name,
    product_category_name_valid,
    COUNT(*) AS product_count
FROM silver.olist_products
GROUP BY
    product_category_name,
    product_category_name_valid
ORDER BY
    product_category_name;


-- Check Product Numeric Attributes and Validation Flags
-- Expectation: No Results

SELECT
    p.product_id,
    v.column_name,
    v.numeric_value,
    v.valid_flag
FROM silver.olist_products AS p

CROSS APPLY (
    VALUES
        (
            'product_name_length',
            p.product_name_length,
            p.product_name_length_valid
        ),
        (
            'product_description_length',
            p.product_description_length,
            p.product_description_length_valid
        ),
        (
            'product_photos_qty',
            p.product_photos_qty,
            p.product_photos_qty_valid
        ),
        (
            'product_weight_g',
            p.product_weight_g,
            p.product_weight_g_valid
        ),
        (
            'product_length_cm',
            p.product_length_cm,
            p.product_length_cm_valid
        ),
        (
            'product_height_cm',
            p.product_height_cm,
            p.product_height_cm_valid
        ),
        (
            'product_width_cm',
            p.product_width_cm,
            p.product_width_cm_valid
        )
) AS v(column_name, numeric_value, valid_flag)

WHERE
       v.valid_flag IS NULL
    OR v.valid_flag NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        v.valid_flag = 'Valid'
        AND (
            v.numeric_value IS NULL
            OR v.numeric_value < 1
        )
    )

    OR (
        v.valid_flag IN ('Invalid', 'Source Null')
        AND v.numeric_value IS NOT NULL
    );



/*==============================================================================
                        REVIEWS TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_reviews'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Both review_id and order_id are required because they form the
-- composite primary key.
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_reviews
        WHERE
            LEN(TRIM(review_id)) = 32
            AND LEN(TRIM(order_id)) = 32
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_reviews
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_reviews
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_reviews
        WHERE
            LEN(TRIM(review_id)) = 32
            AND LEN(TRIM(order_id)) = 32
    ) AS row_difference;


-- Check for NULLs or Duplicates in Composite Primary Key
-- Expectation: No Results

SELECT
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM silver.olist_reviews
GROUP BY
    review_id,
    order_id
HAVING
       review_id IS NULL
    OR order_id IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id
FROM bronze.olist_reviews
WHERE
    LEN(TRIM(review_id)) = 32
    AND LEN(TRIM(order_id)) = 32

EXCEPT

SELECT
    review_id,
    order_id
FROM silver.olist_reviews;


-- Check Primary Key Lengths
-- Expectation: No Results

SELECT
    review_id,
    order_id
FROM silver.olist_reviews
WHERE
       LEN(review_id) <> 32
    OR LEN(order_id) <> 32;


-- Check Review Score Validation Logic
-- Expectation: No Results

SELECT
    review_id,
    order_id,
    review_score,
    review_score_valid
FROM silver.olist_reviews
WHERE
       review_score_valid IS NULL
    OR review_score_valid NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        review_score_valid = 'Valid'
        AND (
            review_score IS NULL
            OR review_score NOT BETWEEN 1 AND 5
        )
    )

    OR (
        review_score_valid IN ('Invalid', 'Source Null')
        AND review_score IS NOT NULL
    );


-- Review Score Distribution
-- Informational

SELECT
    review_score,
    review_score_valid,
    COUNT(*) AS review_count
FROM silver.olist_reviews
GROUP BY
    review_score,
    review_score_valid
ORDER BY
    review_score;


-- Check Review Date Validation Logic
-- Expectation: No Results

SELECT
    r.review_id,
    r.order_id,
    v.column_name,
    v.date_value,
    v.valid_flag
FROM silver.olist_reviews AS r

CROSS APPLY (
    VALUES
        (
            'review_creation_date',
            CAST(r.review_creation_date AS DATETIME2(0)),
            r.review_creation_date_valid
        ),
        (
            'review_answer_timestamp',
            r.review_answer_timestamp,
            r.review_answer_timestamp_valid
        )
) AS v(column_name, date_value, valid_flag)

WHERE
       v.valid_flag IS NULL
    OR v.valid_flag NOT IN ('Valid', 'Invalid', 'Source Null')

    OR (
        v.valid_flag = 'Valid'
        AND v.date_value IS NULL
    )

    OR (
        v.valid_flag IN ('Invalid', 'Source Null')
        AND v.date_value IS NOT NULL
    );


-- Check Review Date Order
-- Review answer should not occur before review creation.
-- Expectation: No Results

SELECT
    review_id,
    order_id,
    review_creation_date,
    review_answer_timestamp
FROM silver.olist_reviews
WHERE review_answer_timestamp
      < CAST(review_creation_date AS DATETIME2(0));



/*==============================================================================
                        SELLERS TABLE
==============================================================================*/

-- ====================================================================
-- Checking 'silver.olist_sellers'
-- ====================================================================


-- Check Bronze-to-Silver Row Count
-- Expectation: row_difference = 0

SELECT
    (
        SELECT COUNT(*)
        FROM bronze.olist_sellers
        WHERE LEN(TRIM(seller_id)) = 32
    ) AS expected_bronze_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_sellers
    ) AS silver_rows,

    (
        SELECT COUNT(*)
        FROM silver.olist_sellers
    )
    -
    (
        SELECT COUNT(*)
        FROM bronze.olist_sellers
        WHERE LEN(TRIM(seller_id)) = 32
    ) AS row_difference;


-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM silver.olist_sellers
GROUP BY seller_id
HAVING seller_id IS NULL
    OR COUNT(*) > 1;


-- Check for Expected Bronze Primary Keys Missing from Silver
-- Expectation: No Results

SELECT
    TRIM(seller_id) AS seller_id
FROM bronze.olist_sellers
WHERE LEN(TRIM(seller_id)) = 32

EXCEPT

SELECT
    seller_id
FROM silver.olist_sellers;


-- Check Primary Key Length
-- Expectation: No Results

SELECT
    seller_id
FROM silver.olist_sellers
WHERE LEN(seller_id) <> 32;


-- Check Cleaned Seller ZIP Code
-- Expectation: No Results

SELECT
    seller_id,
    seller_zip_code_cleaned,
    seller_zip_code_cleaned_valid
FROM silver.olist_sellers
WHERE
       seller_zip_code_cleaned_valid IS NULL

    OR seller_zip_code_cleaned_valid NOT IN (
        'Valid',
        'Invalid',
        'Source Null'
    )

    OR (
        seller_zip_code_cleaned_valid = 'Valid'
        AND (
            seller_zip_code_cleaned IS NULL
            OR LEN(seller_zip_code_cleaned) <> 5
            OR seller_zip_code_cleaned LIKE '%[^0-9]%'
        )
    )

    OR (
        seller_zip_code_cleaned_valid IN ('Invalid', 'Source Null')
        AND seller_zip_code_cleaned IS NOT NULL
    );


-- Check ZIP-Derived State Domain
-- Expectation: No Results

SELECT
    seller_id,
    seller_zip_code_cleaned,
    zip_expected_state
FROM silver.olist_sellers
WHERE
    zip_expected_state IS NOT NULL
    AND zip_expected_state NOT IN (
        'AC','AL','AP','AM','BA','CE','DF','ES','GO',
        'MA','MT','MS','MG','PA','PB','PR','PE','PI',
        'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
    );


-- Check Valid ZIP Codes That Did Not Produce an Expected State
-- Expectation: No Results

SELECT
    seller_id,
    seller_zip_code_cleaned,
    seller_zip_code_cleaned_valid,
    zip_expected_state
FROM silver.olist_sellers
WHERE
    seller_zip_code_cleaned_valid = 'Valid'
    AND zip_expected_state IS NULL;


-- Check for Unwanted Spaces in Standardized Seller Fields
-- Expectation: No Results

SELECT
    seller_id,
    expected_state_seller_city,
    zip_expected_state
FROM silver.olist_sellers
WHERE
       seller_id <> TRIM(seller_id)
    OR expected_state_seller_city <> TRIM(expected_state_seller_city)
    OR zip_expected_state <> TRIM(zip_expected_state);


-- Check Seller Location Consistency Classification
-- Expectation: No Results

SELECT
    seller_id,
    seller_location_consistency
FROM silver.olist_sellers
WHERE
       seller_location_consistency IS NULL
    OR seller_location_consistency NOT IN (
        'consistent',
        'inconsistent'
    );


-- Seller Location Consistency Distribution
-- Informational
--
-- IMPORTANT:
-- "inconsistent" is not automatically an error.
-- This classification intentionally identifies source location values that
-- differ from the ZIP-derived / standardized location.

SELECT
    seller_location_consistency,
    COUNT(*) AS seller_count
FROM silver.olist_sellers
GROUP BY seller_location_consistency
ORDER BY seller_location_consistency;



/*==============================================================================
                    CROSS-TABLE RELATIONSHIP CHECKS
==============================================================================*/

-- ====================================================================
-- Checking Important Silver Layer Relationships
-- ====================================================================


-- Orders -> Customers
-- Every non-NULL customer_id in Orders should exist in Customers.
-- Expectation: No Results

SELECT
    o.order_id,
    o.customer_id
FROM silver.olist_orders AS o
LEFT JOIN silver.olist_customers AS c
    ON o.customer_id = c.customer_id
WHERE
    o.customer_id IS NOT NULL
    AND c.customer_id IS NULL;


-- Order Items -> Orders
-- Expectation: No Results

SELECT
    oi.order_id,
    oi.order_item_id
FROM silver.olist_order_items AS oi
LEFT JOIN silver.olist_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order Items -> Products
-- Only evaluate non-NULL validated product IDs.
-- Expectation: No Results

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id
FROM silver.olist_order_items AS oi
LEFT JOIN silver.olist_products AS p
    ON oi.product_id = p.product_id
WHERE
    oi.product_id IS NOT NULL
    AND p.product_id IS NULL;


-- Order Items -> Sellers
-- Only evaluate non-NULL validated seller IDs.
-- Expectation: No Results

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.seller_id
FROM silver.olist_order_items AS oi
LEFT JOIN silver.olist_sellers AS s
    ON oi.seller_id = s.seller_id
WHERE
    oi.seller_id IS NOT NULL
    AND s.seller_id IS NULL;


-- Payments -> Orders
-- Expectation: No Results

SELECT
    p.order_id,
    p.payment_sequential
FROM silver.olist_payments AS p
LEFT JOIN silver.olist_orders AS o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews -> Orders
-- Expectation: No Results

SELECT
    r.review_id,
    r.order_id
FROM silver.olist_reviews AS r
LEFT JOIN silver.olist_orders AS o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;



/*==============================================================================
                    DATA WAREHOUSE METADATA CHECKS
==============================================================================*/

-- ====================================================================
-- Checking Silver Layer Metadata
-- ====================================================================
--
-- Expectation:
--      missing_source_file       = 0
--      missing_source_system     = 0
--      missing_load_datetime     = 0
--      missing_batch_id          = 0
--
-- This confirms that Bronze lineage information was preserved when the
-- records were transferred into Silver.

SELECT
    'olist_customers' AS table_name,
    COUNT(*) AS row_count,
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END)
        AS missing_source_file,
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END)
        AS missing_source_system,
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END)
        AS missing_load_datetime,
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
        AS missing_batch_id
FROM silver.olist_customers

UNION ALL

SELECT
    'olist_orders',
    COUNT(*),
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM silver.olist_orders

UNION ALL

SELECT
    'olist_order_items',
    COUNT(*),
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM silver.olist_order_items

UNION ALL

SELECT
    'olist_payments',
    COUNT(*),
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM silver.olist_payments

UNION ALL

SELECT
    'olist_products',
    COUNT(*),
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM silver.olist_products

UNION ALL

SELECT
    'olist_reviews',
    COUNT(*),
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM silver.olist_reviews

UNION ALL

SELECT
    'olist_sellers',
    COUNT(*),
    SUM(CASE WHEN _dwh_source_file IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_source_system IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_load_datetime IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN _dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM silver.olist_sellers;



/*==============================================================================
                    SOURCE SYSTEM STANDARDIZATION
==============================================================================*/

-- Verify Source System
-- Expectation: Only 'Olist'

SELECT
    _dwh_source_system,
    COUNT(*) AS record_count
FROM (
    SELECT _dwh_source_system FROM silver.olist_customers
    UNION ALL
    SELECT _dwh_source_system FROM silver.olist_orders
    UNION ALL
    SELECT _dwh_source_system FROM silver.olist_order_items
    UNION ALL
    SELECT _dwh_source_system FROM silver.olist_payments
    UNION ALL
    SELECT _dwh_source_system FROM silver.olist_products
    UNION ALL
    SELECT _dwh_source_system FROM silver.olist_reviews
    UNION ALL
    SELECT _dwh_source_system FROM silver.olist_sellers
) AS silver_source_systems
GROUP BY _dwh_source_system
ORDER BY _dwh_source_system;