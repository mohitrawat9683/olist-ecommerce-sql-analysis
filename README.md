# Olist E-Commerce SQL Analysis

SQL analysis of 100,000 Brazilian e-commerce orders (2016 to 2018) using MySQL. It answers 9 business questions on revenue, customer behavior, seller performance, payment methods and order trends.

## Business Problem
An online marketplace wants to know where its revenue comes from, who its customers and top sellers are, and how orders and payments behave over time. This project uses SQL to answer those questions and turn the results into recommendations.

## Dataset
- **Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)
- **Size:** about 100,000 orders placed between 2016 and 2018
- **Tables used:** `orders`, `order_items`, `order_payments`, `customers`, `products`, `sellers`
- **Tool:** MySQL 8

The raw data is not included in this repo. Download it from Kaggle and import the CSV files into MySQL.



## Recommendations
1. [Prioritize seller acquisition and marketing in the top-revenue categories.]
2. [Explore growth in lower-revenue states, since sales depend heavily on one region.]
3. [Reduce reliance on a few top sellers by supporting mid-sized sellers.]

## Business Questions Answered
| # | Question | Techniques |
|---|----------|------------|
| 1 | Which product categories generate the most revenue? | JOIN, aggregation |
| 2 | Which states generate the most revenue? | JOIN, window function (share of total) |
| 3 | Which payment methods are used most? | `COUNT(DISTINCT)`, aggregation |
| 4 | What share of orders is in each status? | Subquery |
| 5 | How do all states rank by revenue? | `RANK()` |
| 6 | Who are the top 10 sellers by revenue? | JOIN, `RANK()` |
| 7 | Which customers placed the most orders? | `customer_unique_id`, aggregation |
| 8 | How does revenue change by year? | Date
