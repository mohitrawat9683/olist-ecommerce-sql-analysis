/* =====================================================================
   Olist Brazilian E-Commerce: SQL Business Analysis (MySQL 8+)
   ---------------------------------------------------------------------
   Revenue = SUM(order_items.price) for DELIVERED orders only
   (excludes freight, canceled and unavailable orders).
   Replace each <...> with your real finding after running the query.
   ===================================================================== */


/* ---------------------------------------------------------------------
   Optional data cleaning: if blank dates were imported as empty text,
   convert them to real NULLs once, before running the queries.
   --------------------------------------------------------------------- */
-- UPDATE orders SET order_delivered_customer_date = NULL
-- WHERE order_delivered_customer_date = '';
-- ALTER TABLE orders MODIFY order_delivered_customer_date DATETIME;


/* ---------------------------------------------------------------------
   Q1. Which product categories generate the most revenue?
   Finding: <e.g. top category is X with Y% of revenue>
   Recommendation: <e.g. prioritize seller acquisition in top categories>
   --------------------------------------------------------------------- */
SELECT
    p.product_category_name        AS category,
    ROUND(SUM(oi.price), 2)        AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o       ON oi.order_id  = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q2. Which states generate the most revenue?
   Finding: <e.g. SP contributes X% of total revenue>
   Recommendation: <e.g. revenue is concentrated; explore growth elsewhere>
   --------------------------------------------------------------------- */
SELECT
    c.customer_state               AS state,
    ROUND(SUM(oi.price), 2)        AS revenue,
    ROUND(100 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 2) AS pct_of_total
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q3. Which payment methods are used most?
   Finding: <e.g. credit_card is used in X% of orders>
   Recommendation: <e.g. optimize checkout for card and installments>
   --------------------------------------------------------------------- */
SELECT
    payment_type,
    COUNT(DISTINCT order_id)       AS orders,
    ROUND(SUM(payment_value), 2)   AS total_paid
FROM order_payments
GROUP BY payment_type
ORDER BY orders DESC;


/* ---------------------------------------------------------------------
   Q4. What share of orders is in each order status?
   Finding: <e.g. X% delivered, Y% canceled>
   Recommendation: <e.g. investigate cancellations and unavailable orders>
   --------------------------------------------------------------------- */
SELECT
    order_status,
    COUNT(*)                                                 AS orders,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


/* ---------------------------------------------------------------------
   Q5. How do all states rank by revenue? (full ranking with RANK())
   Finding: <e.g. the bottom states contribute less than X% combined>
   Recommendation: <e.g. decide where logistics or marketing spend is worth it>
   --------------------------------------------------------------------- */
SELECT
    c.customer_state                              AS state,
    ROUND(SUM(oi.price), 2)                       AS revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC)     AS revenue_rank
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue_rank;


/* ---------------------------------------------------------------------
   Q6. Who are the top 10 sellers by revenue?
   Finding: <e.g. top 10 sellers account for X% of revenue>
   Recommendation: <e.g. protect top sellers and reduce dependency on them>
   --------------------------------------------------------------------- */
SELECT
    s.seller_id                                   AS seller,
    ROUND(SUM(oi.price), 2)                       AS revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC)     AS seller_rank
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o       ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id
ORDER BY revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q7. Which customers placed the most orders?
   Finding: <e.g. top customer placed X orders; most placed only 1>
   Recommendation: <e.g. target repeat buyers with loyalty offers>
   --------------------------------------------------------------------- */
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id)     AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY order_count DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q8. How does revenue change by year? (by purchase date)
   Finding: <e.g. revenue grew X% from 2017 to 2018; 2016 is a partial year>
   Recommendation: <e.g. compare full years only; check monthly seasonality>
   --------------------------------------------------------------------- */
SELECT
    YEAR(o.order_purchase_timestamp)  AS year,
    ROUND(SUM(oi.price), 2)           AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY year;


/* ---------------------------------------------------------------------
   Q9. How many orders were delivered each year? (by delivery date)
   Note: grouped by delivery date, so it differs from Q8 (purchase date).
   Finding: <e.g. X orders delivered in 2018 vs Y in 2017>
   Recommendation: <e.g. use together with Q8 to check demand vs fulfillment>
   --------------------------------------------------------------------- */
SELECT
    YEAR(o.order_delivered_customer_date) AS year,
    COUNT(DISTINCT oi.order_id)           AS order_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY YEAR(o.order_delivered_customer_date)
ORDER BY year;
