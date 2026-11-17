/* =====================================================================
   Olist Brazilian E-Commerce: SQL Business Analysis (MySQL 8+)
   ---------------------------------------------------------------------*/

/* ---------------------------------------------------------------------
   Q1. Which product categories generate the most revenue?*/
   --------------------------------------------------------------------- 
SELECT
p.product_category_name AS category,
ROUND(SUM(oi.price), 2) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id  = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q2. Which states generate the most revenue?*/
SELECT
c.customer_state AS state,
ROUND(SUM(oi.price), 2) AS revenue,
ROUND(100 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 2) AS pct_of_total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q3. Which payment methods are used most?*/
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS total_paid
FROM order_payments
GROUP BY payment_type
ORDER BY orders DESC;


/* ---------------------------------------------------------------------
   Q4. What share of orders is in each order status?*/
SELECT
order_status,
COUNT(*) AS orders,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


/* ---------------------------------------------------------------------
   Q5. How do all states rank by revenue? (full ranking with RANK())*/
SELECT
c.customer_state AS state,
ROUND(SUM(oi.price), 2) AS revenue,
RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue_rank;


/* ---------------------------------------------------------------------
   Q6. Who are the top 10 sellers by revenue?*/
SELECT
    s.seller_id AS seller,
    ROUND(SUM(oi.price), 2) AS revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS seller_rank
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id
ORDER BY revenue DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q7. Which customers placed the most orders?*/
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY order_count DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   Q8. How does revenue change by year? (by purchase date)*/
SELECT
    YEAR(o.order_purchase_timestamp)  AS year,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY year;


/* ---------------------------------------------------------------------
   Q9. How many orders were delivered each year? (by delivery date)
*/
SELECT
    YEAR(o.order_delivered_customer_date) AS year,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY YEAR(o.order_delivered_customer_date)
ORDER BY year;
