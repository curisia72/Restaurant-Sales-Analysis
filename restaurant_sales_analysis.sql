-- Restaurant Sales Analysis
-- Author: Curisia Allen
-- Description: SQL cleaning steps + 8 business questions answered using SQL
-- Tools: MySQL

CREATE DATABASE resturant_sales;

USE resturant_sales;

SELECT * FROM food_sales;

-- DATA CLEANING + TRANSFOMATION

-- updating date so they are type date instead of text
ALTER TABLE food_sales ADD COLUMN date_converted DATE;
UPDATE food_sales SET date_converted = STR_TO_DATE(date, '%m/%d/%Y');
ALTER TABLE food_sales DROP COLUMN date;

-- order_id column had a weird name when I imported data so changed it 
ALTER TABLE food_sales
RENAME COLUMN ï»¿order_id TO order_id;

-- BUSINESS ANALYSIS QUERIES

-- Which items generated the highest total revenue?
SELECT item_name, SUM(transaction_amount) AS total_revenue, SUM(profit) as total_profit
FROM food_sales
GROUP BY item_name
ORDER BY total_revenue DESC;
-- Ans: Sandwich with total revenue of $65,820 and total profit of 46,074

-- How many transactions came from each payment type?
SELECT transaction_type, COUNT(*) AS transaction_count
FROM food_sales
GROUP BY transaction_type
ORDER BY transaction_count DESC;
-- Ans: Cash 476, Online 417, Gift Card 107

-- What is the average spending by gender?
SELECT gender, ROUND(AVG(transaction_amount),2) AS avg_spend
FROM food_sales
GROUP BY gender;
-- Ans: Male: $280.16, Female: 270.06

-- Which day of the week brings in the highest revenue?
SELECT day_of_week, SUM(transaction_amount) AS total_revenue
FROM food_sales
GROUP BY day_of_week
ORDER BY total_revenue DESC;
-- Ans: Sunday with total_revenue of $43,970

-- Which item is most popular during each time of day? 
SELECT t.time_of_sale, t.item_name, t.item_count
FROM (
    SELECT time_of_sale, item_name, COUNT(*) AS item_count,
           ROW_NUMBER() OVER (PARTITION BY time_of_sale ORDER BY COUNT(*) DESC) AS rn
    FROM food_sales
    GROUP BY time_of_sale, item_name
) t
WHERE t.rn = 1;
-- Ans: Afternoon's most sold item is Sugarcane juice with 41 items sold, ..., Night's most sold item is Cold coffee with 39 items sold

-- Which gender buys each item more often?
SELECT item_name, gender, SUM(transaction_amount) AS total_purchases
FROM food_sales
GROUP BY item_name, gender
ORDER BY item_name, total_purchases DESC;
-- Ans: Aalopuri: Male with $11,660, Cold Coffee: Female with $27,480, ...

-- Which items generate above-average revenue?
SELECT 
    item_name,
    SUM(transaction_amount) AS total_item_revenue
FROM food_sales
GROUP BY item_name
HAVING SUM(transaction_amount) > (
        SELECT AVG(item_total)
        FROM (
            SELECT SUM(transaction_amount) AS item_total
            FROM food_sales
            GROUP BY item_name
        ) AS item_revenues
    );
-- Ans: Frankies, Sandwiches, and Cold Coffees


-- What are the top 3 highest-spending customers?
SELECT order_id, SUM(transaction_amount) AS total_spent
FROM food_sales
GROUP BY order_id
ORDER BY total_spent DESC
LIMIT 3;
-- Ans: Customers 138, 361, and 96 are the three highest spending customers with a transaction total of $900