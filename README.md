![Danny's dinner](https://github.com/nsatangulov/Danny-s_Dinner/assets/138556626/bdfb92af-a496-424e-abdb-19581f9c2d37)
# Danny's Dinner - SQL Case Study #1

### Notes:
- This data analysis is made by the dataset and tasks provided by Danny Ma under his [8 Week SQL Challenge](https://8weeksqlchallenge.com/)
- The purpose of this analysis is to learn and improve knowledge in SQL.

## Case Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

## Dataset and Entity Relationship Diagram
> Code for creating tables and inserting data.
```
CREATE TABLE sales (
	customer_id VARCHAR(50),
	order_date DATE,
	poduct_id INT
)

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

CREATE TABLE members(
	customer_id VARCHAR(50),
	join_date DATE
)

INSERT INTO members
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
```
#### Entity Relationship Diagram
![diagram](https://github.com/nsatangulov/Danny-s_Dinner/assets/138556626/99766d19-85f5-4195-bfcf-5a6d5e40462c)

## Case study questions
### 1.What is the total amount each customer spent at the restaurant?
```
SELECT customer_id, SUM(price) AS total_spent FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY customer_id;
```
| customer_id | total_spent |
| --------- | ----------- |
| A         | 76           |
| B         | 74           |
| C         | 36           |

### 2.How many days has each customer visited the restaurant?
```
SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit_count FROM sales
GROUP BY customer_id;
```
| customer_id | visit_count |
| --------- | ----------- |
| A         | 4           |
| B         | 6           |
| C         | 2           |

### 3.What was the first item from the menu purchased by each customer?
```
WITH FirstItem AS (
SELECT customer_id, order_date, product_name, 
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS item_num
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
)

SELECT DISTINCT(customer_id), order_date, product_name, item_num
FROM FirstItem
WHERE item_num = 1;
```
|customer_id|order_date|product_name|item_num|
|:----|:----|:----|:----|
|A|2021-01-01|curry|1|
|A|2021-01-01|sushi|1|
|B|2021-01-01|curry|1|
|C|2021-01-01|ramen|1|

### 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
```
SELECT product_name, COUNT(order_date) AS tot_orders FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY product_name
ORDER BY tot_orders DESC
```
|product_name|tot_orders|
|:----|:----|
|ramen|8|
|curry|4|
|sushi|3|

### 5.Which item was the most popular for each customer?
```
WITH PopularProduct AS (
SELECT customer_id, product_name, 
COUNT(product_id) AS tot_order,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) AS Ranking
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id, product_name, tot_order
FROM PopularProduct
WHERE Ranking = 1
```
|customer_id|product_name|tot_order|
|:----|:----|:----|
|A|ramen|3|
|B|sushi|2|
|B|curry|2|
|B|ramen|2|
|C|ramen|3|

### 6.Which item was purchased first by the customer after they became a member?
```
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
```
|customer_id|product_name|
|:----|:----|
|A|ramen|
|B|sushi|

### 7.Which item was purchased just before the customer became a member?
```
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
```
|customer_id|product_name|
|:----|:----|
|A|sushi|
|A|curry|
|B|sushi|

### 8.What is the total items and amount spent for each member before they became a member?
```
SELECT sales.customer_id, COUNT(product_id) AS TotalItems, SUM(price) AS total_amount FROM sales
JOIN menu
ON menu.product_id = sales.poduct_id
LEFT JOIN members
ON members.customer_id = sales.customer_id
WHERE order_date < join_date
GROUP BY sales.customer_id
```
|customer_id|TotalItems|total_amount|
|:----|:----|:----|
|A|2|25|
|B|3|40|

### 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```
SELECT sales.customer_id, SUM(
CASE
	WHEN product_name = 'sushi' THEN price * 20
	ELSE price * 10
END) AS points
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
GROUP BY sales.customer_id
```
|customer_id|points|
|:----|:----|
|A|860|
|B|940|
|C|360|

### 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```
SELECT sales.customer_id, SUM(
CASE
	WHEN product_name = 'sushi' THEN price * 20
	WHEN order_date BETWEEN join_date AND DATEADD(day, 6,join_date) THEN price * 20
	ELSE price * 10
END) AS points
FROM sales
JOIN menu
ON sales.poduct_id = menu.product_id
JOIN members
ON sales.customer_id = members.customer_id
WHERE order_date < '2021-02-01'
GROUP BY sales.customer_id
```
|customer_id|points|
|:----|:----|
|A|1370|
|B|820|

## Bonus questions
### Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:
|ustomer_id|order_date|product_name|price|member|
|:----|:----|:----|:----|:----|
|A|2021-01-01|curry|15|N|
|A|2021-01-01|sushi|10|N|
|A|2021-01-07|curry|15|Y|
|A|2021-01-10|ramen|12|Y|
|A|2021-01-11|ramen|12|Y|
|A|2021-01-11|ramen|12|Y|
|B|2021-01-01|curry|15|N|
|B|2021-01-02|curry|15|N|
|B|2021-01-04|sushi|10|N|
|B|2021-01-11|sushi|10|Y|
|B|2021-01-16|ramen|12|Y|
|B|2021-02-01|ramen|12|Y|
|C|2021-01-01|ramen|12|N|
|C|2021-01-01|ramen|12|N|
|C|2021-01-07|ramen|12|N|
```
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
```
### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
|customer_id|order_date|product_name|price|member|ranking|
|:----|:----|:----|:----|:----|:----|
|A|2021-01-01|curry|15|N|null|
|A|2021-01-01|sushi|10|N|null|
|A|2021-01-07|curry|15|Y|1|
|A|2021-01-10|ramen|12|Y|2|
|A|2021-01-11|ramen|12|Y|3|
|A|2021-01-11|ramen|12|Y|3|
|B|2021-01-01|curry|15|N|null|
|B|2021-01-02|curry|15|N|null|
|B|2021-01-04|sushi|10|N|null|
|B|2021-01-11|sushi|10|Y|1|
|B|2021-01-16|ramen|12|Y|2|
|B|2021-02-01|ramen|12|Y|3|
|C|2021-01-01|ramen|12|N|null|
|C|2021-01-01|ramen|12|N|null|
|C|2021-01-07|ramen|12|N|null|
```
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
```
## Conclusion
By answering Danny's questions, we have discovered several useful insights that might be helpful for Danny and his restaurant business. 
1. Customer A visited restaurant 4 times, and spent $76, which is more than other customers has spent. Customer B visited restaurant 6 times and spent in total $74. Both of customers registered as members. 
2. The most popular restaurant meal is Ramen, because it was purchased 8 times in total. 
3. After ordering Curry and Sushi, Customers A & B became a member. After signing in for membership, Customer B ordered sushi again. 
4. Customer C visited restaurant 3 times and ordered only Ramen. Customer C is the only one who has not signed membership. Waiters may suggest Customer C to try Curry and Sushi, because after ordering them other customers decided to sign. 
