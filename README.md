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
