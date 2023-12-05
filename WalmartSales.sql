-- Create table
CREATE DATABASE IF NOT EXISTS salesDataWalmart;
-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- --------------------------------------------------------------
-- ----------------------FEATURE ENGINEERING----------------------
-- time_of_day

Select time,
(Case 
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening" end) as time_of_date
from sales;

alter table sales add column time_of_day VARCHAR(20); 
update sales
set time_of_day=(Case 
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening" end);

-- day_name
   
Select date,
dayname(date) AS day_name
from sales;    
alter table sales add column day_name VARCHAR(10);
update sales
set day_name=dayname(date);

-- month_name
Select date,
monthname(date)
from sales ;
alter table sales add column month_name VARCHAR(10);
update sales
set month_name=monthname(date);

-- -----------------------------------------------------------
-- --------------------------GENERIC--------------------------


-- How many unique cities does the data have?
Select distinct city from sales;
-- In which city is each branch?
Select distinct city,branch from sales;

-- ---------------------------------------------------------------
-- -----------------------PRODUCT---------------------------------
-- How many unique product lines does the data have?
SELECT count(distinct product_line) from sales

-- What is the most common payment method?
Select payment,count(payment) as count from sales
group by payment
order by count desc
limit 1

-- What is the most selling product line?
Select product_line,count(product_line) as count from sales
group by product_line
order by count desc

-- What is the total revenue by month?
select month_name as month,
sum(total) as revenue
from sales 
group by month
order by revenue desc

-- What month had the largest COGS?
select month_name,sum(cogs) as cogs from sales
group by month_name
order by cogs desc

-- What product line had the largest revenue?
select product_line,sum(total) as total
from sales
group by product_line
order by total desc

-- What is the city with the largest revenue?
select branch,city,sum(total) as total from sales
group by city,branch
order by total desc

-- What product line had the largest VAT?
select product_line,avg(tax_pct) as avg_vat
from sales
group by product_line
order by avg_vat desc

-- Fetch each product line and add a column to those product line showing
-- "Good", "Bad". Good if its greater than average sales

-- Which branch sold more products than average product sold?
select branch,sum(quantity) as qty
from sales
group by branch
having sum(quantity)>(select avg(quantity) from sales)

-- What is the most common product line by gender?
select gender ,product_line,count(gender) as total_cnt from sales
group by gender,product_line
order by total_cnt desc

-- What is the average rating of each product line?
  select product_line,round(avg(rating),2) as avg_rating from sales
  group by product_line
  order by avg_rating desc
  
  -- ---------------------------------------------------------------
  -- ------------------------SALES----------------------------------
-- Number of sales made in each time of the day per weekday
select day_name,time_of_day,count(*) as total_sales
from sales
-- where day_name="Monday"
group by day_name,time_of_day
order by day_name desc

-- Which of the customer types brings the most revenue?
select customer_type,sum(total) as tot_revenue from sales
group by customer_type
order by tot_revenue desc

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select city,avg(tax_pct) as vat
from sales
group by city
order by vat desc

-- Which customer type pays the most in VAT?
select customer_type,avg(tax_pct) as vat
from sales
group by customer_type
order by vat desc

-- --------------------------------------------------------------
-- ------------------CUSTOMER------------------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type from sales
-- How many unique payment methods does the data have?
-- What is the most common customer type?

-- Which customer type buys the most?
select customer_type,count(*) as customer
from sales
group by customer_type

-- What is the gender of most of the customers?
select gender,count(*) as customer
from sales
group by gender
order by customer desc
-- What is the gender distribution per branch?
select branch,gender,count(*) as customer
from sales
group by branch,gender
order by branch desc,customer desc

-- Which time of the day do customers give most ratings?
select time_of_day,avg(rating) as avg_rating from sales
group by time_of_day
order by avg_rating desc

-- Which time of the day do customers give most ratings per branch?
select branch,time_of_day,avg(rating) as avg_rating from sales
group by branch,time_of_day
order by branch,avg_rating desc

-- Which day fo the week has the best avg ratings?
select day_name,avg(rating) as avg_rating from sales
group by day_name
order by avg_rating desc

-- Which day of the week has the best average ratings per branch?
select branch,day_name,avg(rating) as avg_rating from sales
group by branch,day_name
order by branch,avg_rating desc