SELECT COUNT(*) AS total_rows 
From ecommerce;

SELECT *  FROM ecommerce;

-- CORRECT - ::numeric should be inside ROUND()
SELECT ROUND("Total Price"::numeric, 2) FROM ecommerce;
SELECT *  FROM ecommerce;




--Overview--
SELECT COUNT(DISTINCT "CustomerID") AS Total_Customers FROM ecommerce;

SELECT COUNT(DISTINCT "StockCode") AS Total_Products FROM ecommerce;

SELECT COUNT(DISTINCT "Country") AS Total_Countries FROM ecommerce;

SELECT COUNT(DISTINCT "InvoiceNo") AS Total_Orders FROM ecommerce;
select count(distinct "Description") as total_products from ecommerce;

--Totall Price  and revenue part Overview--

selct sum("Total Pri")
select max("Total Price") as max_order_value from ecommerce;
select min("Total Price") as min_order_value from ecommerce;


SELECT count(*) FROM ecommerce
WHERE "Total Price" = 0.00;
--THe top selling products are--
SELECT 
    "Description", 
    SUM("Quantity") AS Total_Quantity
FROM ecommerce
GROUP BY "Description"
ORDER BY Total_Quantity DESC
LIMIT 10;



SELECT 
    "Description", 
    ROUND(SUM("Total Price")::numeric, 2) AS Total_Revenue
FROM ecommerce
GROUP BY "Description"
ORDER BY Total_Revenue DESC
LIMIT 10;

UPDATE ecommerce
SET "Total Price" = ROUND("Total Price"::numeric, 2);

SELECT "Total Price" 
FROM ecommerce 
LIMIT 10;

SELECT 
    MIN("Total Price") AS Min_Price,
    MAX("Total Price") AS Max_Price
FROM ecommerce;

SELECT COUNT(*) AS Zero_Count
FROM ecommerce
WHERE "Total Price" = 0;

DELETE FROM ecommerce
WHERE "Total Price" <= 0;


SELECT 
    MIN("Total Price") AS Min_Price,
    COUNT(*) AS Total_Rows
FROM ecommerce;

--top 10 products sold by quantity--
  	SELECT
    "Description",
    SUM("Quantity") AS quantity_sold
FROM ecommerce
GROUP BY "Description"
ORDER BY quantity_sold DESC
LIMIT 10;
--least selling products--
SELECT
    "Description",
    SUM("Quantity") AS quantity_sold
FROM ecommerce
GROUP BY "Description"
ORDER BY quantity_sold asc
LIMIT 10;

--total customers--
select count(distinct "CustomerID")
from ecommerce;

--top customers by revenue--

SELECT
    "CustomerID",
    round(SUM("Total Price"):: numeric,2) AS revenue
FROM ecommerce
GROUP BY "CustomerID"
ORDER BY revenue DESC
LIMIT 10;


--countries genersting most revenue --
SELECT
    "Country",
    round(SUM("Total Price")::numeric, 2) AS revenue
FROM ecommerce
GROUP BY "Country"
ORDER BY revenue DESC;



 --customer segmentation
 --who are the VIP Customer

WITH customer_revenue AS (
    SELECT
        "CustomerID",
        SUM("Total Price") AS total_revenue
    FROM ecommerce
    GROUP BY "CustomerID"
)

SELECT
    CASE
        WHEN total_revenue > 10000 THEN 'VIP'
        WHEN total_revenue BETWEEN 1000 AND 10000 THEN 'Regular'
        ELSE 'Low Value'
    END AS customer_segment,

    COUNT(*) AS total_customers
FROM customer_revenue
GROUP BY customer_segment
ORDER BY total_customers DESC;

--cumulative learning
WITH product_revenue AS (
    SELECT
        "Description",
        SUM("Total Price") AS revenue
    FROM ecommerce
    GROUP BY "Description"
)

SELECT
    "Description",
    revenue,

    SUM(revenue) OVER (
        ORDER BY revenue DESC
    ) AS running_revenue

FROM product_revenue
ORDER BY revenue DESC;


--products responsible for most revenue
WITH product_revenue AS (
    SELECT
        "Description",
        SUM("Total Price") AS revenue
    FROM ecommerce
    GROUP BY "Description"
),

revenue_ranked AS (
    SELECT
        "Description",
        revenue,

        SUM(revenue) OVER (
            ORDER BY revenue DESC
        ) AS cumulative_revenue,

        SUM(revenue) OVER () AS total_revenue

    FROM product_revenue
)

SELECT
    "Description",
    ROUND(revenue::numeric, 2) AS revenue,

    ROUND(
        (cumulative_revenue / total_revenue * 100)::numeric,
        2
    ) AS cumulative_percentage

FROM revenue_ranked
WHERE (cumulative_revenue / total_revenue * 100) <= 80
ORDER BY revenue DESC;


--get monthly revenue

WITH monthly_revenue AS (
    SELECT
        "Year_Month",
        SUM("Total Price") AS revenue
    FROM ecommerce
    GROUP BY "Year_Month"
)

SELECT
    "Year_Month",
    revenue,

    LAG(revenue) OVER (
        ORDER BY "Year_Month"
    ) AS previous_month_revenue

FROM monthly_revenue;

select * from original_data;
--RFM
WITH customer_fm AS (
    SELECT
        "CustomerID",
        COUNT(DISTINCT "InvoiceNo") AS frequency,
        ROUND(SUM("UnitPrice" * "Quantity")::numeric, 2) AS monetary
    FROM original_data
    GROUP BY "CustomerID"
)

SELECT
    "CustomerID",
    frequency,
    monetary,

    CASE
        WHEN frequency >= 20 AND monetary >= 10000
            THEN 'Champion'
        WHEN frequency >= 10
            THEN 'Loyal'
        WHEN frequency >= 5
            THEN 'Regular'
        ELSE 'Low Activity'
    END AS customer_segment

FROM customer_fm


ORDER BY monetary DESC;

--return items details
--1. Total number of returned units
SELECT
    ABS(SUM("Quantity")) AS total_returned_units
FROM original_data
WHERE "Quantity" < 0;

--2. Number of return transactions
	SELECT
    COUNT(*) AS return_transactions
FROM original_data
WHERE "Quantity" < 0;