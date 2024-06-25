select * from orders_data;
-- Write a SQL query to list all distinct cities where orders have been shipped.
select distinct City from orders_data;

-- Calculate the total selling price and profits for all orders.
select [Order Id] , CAST((Quantity * Unit_selling_price) as decimal(10,2)) as selling_price
from orders_data;

-- Write a query to find all orders from the 'Technology' category 
-- that were shipped using 'Second Class' ship mode, ordered by order date.
select [Order Id], [Order Date] from orders_data 
where Category = 'Technology' and  [Ship Mode] = 'Second Class'
order by [Order Date];

-- Write a query to find the average order value
select (sum(Quantity * Unit_selling_price))/ count([Order Id]) as avg_order_value
FROM orders_data;

-- find the city with the highest total quantity of products ordered.
select top 1 City , sum(Quantity) AS total_qty from orders_data
group by City
Order by total_qty desc

select * from orders_data;
-- Use a window function to rank orders in each region by quantity in descending order.
select [Order Id] , Region, Quantity, 
DENSE_RANK() OVEr (partition by Region order by Quantity desc) as rank 
from orders_data
order by region, rank;

-- Write a SQL query to list all orders placed in the first quarter of any year (January to March), including the total cost for these orders.

select [Order Id], sum(Quantity*Unit_selling_price) as Total_sale
from orders_data
where month([Order Date]) in (1,2,3)
group by [Order Id]
order by [Total_sale] desc

-- Q1. find top 10 highest profit generating products 
select * from orders_data;
select TOP 10 [Product Id], sum(Total_profit)
from orders_data
group by [Product Id]
order by sum(Total_profit) desc

--find top 3 highest selling products in each region
with cte as (
SELECT Region, [Product Id], sum(Quantity*Unit_selling_price) AS highest_selling_products,
ROW_NUMBER() over(partition by Region Order by sum(Quantity*Unit_selling_price) DESC) as Rank
from orders_data 
Group by Region, [Product Id])
select * from cte where rank <=3;

-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
use dataholics
select * from orders_data;
with cte as (
select Year([Order Date]) as order_year,
month([Order Date]) as order_month,
sum(Quantity * Unit_selling_price) as sales
from orders_data
GROUP BY year([order date]),month([order date])
)
select order_month,
round(sum(case when order_year = 2022 then sales else 0 end ),2) as sales_2022,
round(sum(case when order_year = 2023 then sales else 0 end ),2) as sales_2023
from cte 
group by order_month
order by order_month;

-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023 as DIFFERENCE
with cte as (
select Year([Order Date]) as order_year,
month([Order Date]) as order_month,
sum(Quantity * Unit_selling_price) as sales
from orders_data
GROUP BY year([order date]),month([order date])
),
cte1 as (
select order_month,
round(sum(case when order_year = 2022 then sales else 0 end ),2) as sales_2022,
round(sum(case when order_year = 2023 then sales else 0 end ),2) as sales_2023
from cte 
group by order_month
)
select order_month, sales_2022, sales_2023, (sales_2022-sales_2023) as diff
from cte1 
order by order_month;

-- for each category which month had highest sales 
with cte as (
SELECT Category, format([Order Date], 'yyyy-MM') as order_year_month, sum(Quantity*Unit_selling_price) as sales,
ROW_NUMBER() over (partition by Category order by sum(Quantity*Unit_selling_price) DESC) as rank
from orders_data
group by Category, format([Order Date], 'yyyy-MM')
)
select Category, order_year_month, sales from cte where rank =1

-- which sub category had highest growth by sales in 2023 compare to 2022
with cte as (
select [Sub Category], YEAR([Order Date]) as year ,sum(Quantity*Unit_selling_price) as sales
from orders_data
group by [Sub Category], YEAR([Order Date])
),
cte1 as (
select [Sub Category], 
sum(case when year = 2022 then sales else 0 end ) as SALES2022,
sum(case when year = 2023 then sales else 0 end ) as SALES2023
from cte 
group by [Sub Category]
)
select 
[Sub Category], SALES2022, SALES2023,
(SALES2023 - SALES2022) as diff
from cte1
ORDER BY 
diff DESC;

