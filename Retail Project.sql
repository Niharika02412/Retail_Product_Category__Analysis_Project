use NiharikaRetailProject;select* from Data_retail;---1 Identifies products with prices higher than the average price within their categoryWITH AVG_Price_Cat AS (
    SELECT 
        [Product_ID],
        [Product_Name],
        [Category],
        [Price],
        AVG([Price]) OVER (PARTITION BY [Category]) AS avg_price
    FROM Data_retail
    
)

---select * from AVG_Price_Cat;

SELECT 
    [Product_ID],
    [Product_Name],
    [Category],
    [Price],
    avg_price
FROM AVG_Price_Cat
WHERE [Price] > avg_price
ORDER BY [Price] DESC;--2 Finding Categories with Highest Average Rating Across ProductsSELECT 
    [Category], 
    AVG([Rating]) AS AVG_Rating_Per_Category
FROM Data_retail
GROUP BY [Category]
ORDER BY AVG_Rating_Per_Category DESC;

-- 3 Find the most reviewed product in each warehouseWITH RankedProducts AS (
    SELECT 
        [Product_ID],
        [Product_Name],
        [Warehouse],
        [Reviews],
        row_number() OVER (PARTITION BY [Warehouse] ORDER BY [Reviews] DESC) AS review_rank
    FROM Data_retail
)

--select * from RankedProducts

SELECT 
    [Product_ID],
    [Product_Name],
    [Warehouse],
    [Reviews]
FROM RankedProducts
WHERE review_rank = 1;--- 4 find products that have higher-than-average prices within their category, along with their discount and supplier.WITH AVG_Price_Cat AS (
    SELECT 
        [Product_ID],
        [Product_Name],
        [Category],
        [Discount],
        [Supplier],
        [Price],
        AVG([Price]) OVER (PARTITION BY [Category]) AS avg_price
    FROM Data_retail
)
SELECT 
    [Product_ID],
    [Product_Name],
    [Category],
    [Discount],
    [Supplier],
    [Price],
    avg_price
FROM AVG_Price_Cat
WHERE [Price] > avg_price
ORDER BY [Price] DESC;--- 5 Query to find the top 2 products with the highest average rating in each category-- Step 1: Get average rating per product using a window function
WITH AvgRatings AS (
    SELECT
        [Product_ID],
        [Product_Name],
        [Category],
        AVG([Rating]) OVER (
            PARTITION BY [Product_ID], [Product_Name], [Category]
        ) AS avg_rating_per_product
    FROM Data_retail
),

-- Step 2: Rank the products by their average rating within each category
RankedProducts AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY [Category]
ORDER BY avg_rating_per_product DESC
        ) AS rating_rank
    FROM AvgRatings
)

-- Step 3: Get top 2
SELECT DISTINCT
    [Product_ID],
    [Product_Name],
    [Category],
    avg_rating_per_product,
    rating_rank
FROM RankedProducts
WHERE rating_rank <= 2;-- 6 Analysis Across All Return Policy Categories(Count, Avgstock, total stock, weighted_avg_rating, etc)SELECT 
    [Return_Policy],
    COUNT(*) AS product_count,
    AVG([Stock_Quantity]) AS avg_stock,
    SUM([Stock_Quantity]) AS total_stock,
    SUM([Rating] * [Stock_Quantity]) * 1.0 / NULLIF(SUM([Stock_Quantity]), 0) AS weighted_avg_rating
FROM Data_retail
GROUP BY [Return_Policy]
ORDER BY product_count DESC;

select * from Data_retail

