/* 
   Pizza sales ANALYSIS
   Author: Shashank Gupta
   Purpose: SQL-based analysis of Pizza Sales
*/

--Create Database

create database PizzaCave;
use PizzaCave;

-- TABLE STRUCTURE

--Create Orders Table
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

--Create Orders_Details Table
create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

-- Retrieve the total numbers of orders placed.

select count(order_id) as Total_Orders
from  orders;

-- Revenue Generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_Sales
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id;

-- Highest Price pizza Name
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Most Common Pizza Size Ordered
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- top 5 most ordered pizza type with their quantity
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- join the necessary table to find the total quantity  of each pizza category ordered

SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- distribution of order by hour of the day
SELECT 
    HOUR(order_time) as hour, COUNT(order_id) as order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- category wise distribution of pizzas
select category, count(name) from pizza_types
group by category;

-- group the orders by date and calculate the avg no. of pizza ordered per day
SELECT 
    round(AVG(quantity),0) as Avg_pizzas_orders_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) as quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_qty;

-- top 3 most ordered pizza based on revenue
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Percentage Contribution of each pizza type to total revenue
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    SUM(od.quantity * p.price) AS Total_Sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id) * 100),
            2) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- Analyses the cumulative revenue generated over time
select order_date, 
sum(revenue) over (order by order_Date) as cum_revenue 
from (select o.order_date, sum(od.quantity*p.price) as revenue
from order_details od 
join pizzas p on od.pizza_id = p.pizza_id
join orders o on o.order_id = od.order_id
group by o.order_date) as sales;




