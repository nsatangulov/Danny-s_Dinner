--                                              Introduction
-- Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up 
-- a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.
-- Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very 
-- basic data from their few months of operation but have no idea how to use their data to help them run the business.


--                                            Problem Statement
-- Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, 
-- how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers
-- will help him deliver a better and more personalised experience for his loyal customers.

-- He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally 
-- he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

-- Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are 
-- enough for you to write fully functioning SQL queries to help him answer his questions!

-- Danny has shared with you 3 key datasets for this case study:
-- *sales
-- *menu
-- *members


-- Let's start by creating dataset for analysis. 

CREATE TABLE sales (
	customer_id VARCHAR(50),
	order_date DATE,
	poduct_id INT
)

-- Inserting values.

INSERT INTO sales
VALUES 
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');


-- Checking if the values updated correctly. 

SELECT * FROM sales;

-- Repeat same for other data sets.

CREATE TABLE menu(
	product_id INT,
	product_name VARCHAR(50),
	price INT
)

INSERT INTO menu
VALUES 
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
SELECT * FROM menu

CREATE TABLE members(
	customer_id VARCHAR(50),
	join_date DATE
)

INSERT INTO members
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM members;

-- Let's begin our analysis and answer Danny's questions. 

-- #1 What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS TotalSpent FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY customer_id;

-- Customer A spent in total $76, Customer B $74, Customer C $36.

-- #2 How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT(order_date)) AS VisitCount FROM sales
GROUP BY customer_id;

-- Customer A visited restaurant 4 times, Customer B 6 and Customer C 2 times. 

-- #3 What was the first item from the menu purchased by each customer?

WITH FirstItem AS (
SELECT customer_id, order_date, product_name, 
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ItemNum
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
)

SELECT DISTINCT(customer_id), order_date, product_name, itemnum
FROM FirstItem
WHERE itemnum = 1;

-- Customer A first order contained sushi and curry, Customer B ordered curry and Customer C ordered ramen. 

-- #4 What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, COUNT(order_date) AS TotOrders FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY product_name
ORDER BY TotOrders DESC
;

-- Mostly ordered product is Ramen with 8 total orders. 

-- #5 Which item was the most popular for each customer?

WITH PopularProduct AS (
SELECT customer_id, product_name, 
COUNT(product_id) AS TotOrder,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) AS Ranking
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id, product_name, TotOrder
FROM PopularProduct
WHERE Ranking = 1

-- Customers A and C mostly ordered Ramen Customer B ordered all of the products equally. 

-- #6 Which item was purchased first by the customer after they became a member?

WITH FirstOrder AS (
SELECT sales.customer_id, product_name, order_date, join_date, 
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date) AS Ranking
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
JOIN members
ON sales.customer_id = members.customer_id
WHERE order_date > join_date
)

SELECT customer_id, product_name FROM FirstOrder
WHERE Ranking = 1

-- Customer A purchased Ramen and Customer B purchased sushi after they became members

-- #7 Which item was purchased just before the customer became a member?


WITH LastOrder AS (
SELECT sales.customer_id, product_name, order_date, join_date, 
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) AS Ranking
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
JOIN members
ON members.customer_id = sales.customer_id
WHERE order_date < join_date
)

SELECT customer_id, product_name FROM LastOrder
WHERE Ranking = 1

-- Prior becoming a member, Customer A ordered sushi and curry, while Customer B ordered sushi.

-- #8 What is the total items and amount spent for each member before they became a member?

SELECT sales.customer_id, COUNT(product_id) AS TotalItems, SUM(price) AS TotalAmount FROM sales
JOIN menu
ON menu.product_id = sales.poduct_id
LEFT JOIN members
ON members.customer_id = sales.customer_id
WHERE order_date < join_date OR join_date IS NULL
GROUP BY sales.customer_id

-- Customer A has ordered 2 items for total amount of $25, Customer B 3 items for total amount of $40 before they became a member.
-- Customer C has not subscribed as member and can be removed from the query result if it's not needed. Untill now, Customer C
-- has ordered 3 items for total $36. 

-- #9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT sales.customer_id, SUM(
CASE
	WHEN product_name = 'sushi' THEN price * 20
	ELSE price * 10
END) AS Points
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY sales.customer_id

-- Customer A will have 860, Customer B 940 points and Customer C 360 points. 

-- #10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--     not just sushi - how many points do customer A and B have at the end of January?

SELECT sales.customer_id, SUM(
CASE
	WHEN product_name = 'sushi' THEN price * 20
	WHEN order_date BETWEEN join_date AND DATEADD(day, 6,join_date) THEN price * 20
	ELSE price * 10
END) AS Points
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
JOIN members
ON sales.customer_id = members.customer_id
WHERE order_date < '2021-02-01'
GROUP BY sales.customer_id

-- Customer A has 1370 point, Customer B 820 points. 

--                                            Bonus Questions
--                                          Join All The Things
-- The following questions are related creating basic data tables that Danny and his team can use to quickly derive 
-- insights without needing to join the underlying tables using SQL.

-- Create a table with customer_id, order_date, product_name, price and add new column indicating if the customer was
-- a member at the time of the restoraunt visit and order.

SELECT sales.customer_id, order_date, product_name, price, 
CASE
	WHEN order_date >= join_date THEN 'Y'
	ELSE 'N'
END AS member
FROM sales
JOIN menu 
ON sales.poduct_id = menu.product_id
LEFT JOIN members
ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, order_date

-- Required table created with indication of the status of membership.

--                                          Rank All The Things
-- Danny also requires further information about the ranking of customer products, but he purposely does not need the 
-- ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part 
-- of the loyalty program.

WITH RankTable AS(
SELECT sales.customer_id, order_date, product_name, price, 
(CASE
	WHEN order_date >= join_date THEN 'Y'
	ELSE 'N'
END) AS member
FROM sales
JOIN menu 
ON sales.poduct_id = menu.product_id
LEFT JOIN members
ON sales.customer_id = members.customer_id
)

SELECT *,
CASE
	WHEN member = 'N' THEN null
	ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
END AS ranking
FROM RankTable

-- Required table created with indication of the status of membership and ranking as per Danny's request. 

--                                         CONCLUSION

-- By answering Danny's questions, we have discovered several useful insights that might be helpful for 
-- Danny and his restaurant business. 
-- * Customer A visited restaurant 4 times, and spent $76, which is more than other customers has spent. 
--   Customer B visited restaurant 6 times and spent in total $74. Both of customers registered as members. 
-- * The most popular restaurant meal is Ramen, because it was purchased 8 times in total. 
-- * After ordering Curry and Sushi, Customers A & B became a member. After signing in for membership,
--   Customer B ordered sushi again. 
-- * Customer C visited restaurant 3 times and ordered only Ramen. Customer C is the only one who has not
--   signed membership. Waiters may suggest Customer C to try Curry and Sushi, because after ordering them
--   other customers decided to sign. 