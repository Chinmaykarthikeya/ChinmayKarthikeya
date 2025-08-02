
# Acessing the project data base 
use zepto_sql_analysis_project;
# UPDATE the column data in the zepto1 table
 
 UPDATE zepto1
SET  outOfStock = CASE
    WHEN LOWER(outOfStock) IN ('true', 'yes', '1') THEN TRUE
    WHEN LOWER(outOfStock) IN ('false', 'no', '0') THEN FALSE
    ELSE '0'  -- or handle unknown cases appropriately
END;

# Converting the data into boolean form where the internal representation of the bollean datatupe is stored as tinyint(1)
 

alter table zepto1
modify column outOfStock BOOLEAN;

# Checking the chnages happend inside the table

select * from zepto1;

# insertting the zepto1 table into zepto table 
TRUNCATE table zepto;
insert into zepto (category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, outOfStock, quantity)
SELECT * FROM zepto1;

-- checking the insertion of the data

select count(*) from zepto;

-- counting null values in the zepto table
select * from zepto;

select sum(Category is null) as count_null_in_category,
sum(name is null) as count_null_in_name,
sum(mrp is null) as count_null_in_mrp,
sum(discountPercent is null) as count_null_in_Dp,
sum(availableQuantity is null) as count_null_in_AQ,
sum(discountedSellingPrice is null) as count_null_in_DSP,
sum(weightInGms is null) as count_null_in_WIG,
sum(outOfStock is null ) as count_null_in_OOS,
sum(quantity is null)  as count_null_in_quant from zepto;

# There are no null values in any of the column  from the zepto table

-- need to know what are the product cvategerioes we've  in the zepto table let's see
select DISTINCT Category as product_category from zepto z
ORDER BY z.category ;

-- proct in stock vs product outofstock

select outOfStock, count(sku_id) tcp from 
zepto
GROUP BY outOfStock
ORDER BY tcp DESC;

-- product names which are appeared multiple times in the zepto table

SELECT name, Number_of_times_appeared
FROM (
    SELECT name, COUNT(sku_id) AS Number_of_times_appeared
    FROM zepto
    GROUP BY name
) AS grouped_table
WHERE Number_of_times_appeared = (
    SELECT MAX(count_sku) FROM (
        SELECT COUNT(sku_id) AS count_sku
        FROM zepto
        GROUP BY name
    ) AS counts
)
ORDER BY Number_of_times_appeared DESC;


select name, count(sku_id) No_of_mul_appreance from zepto 
GROUP BY name 
Having count(sku_id)>1
ORDER BY No_of_mul_appreance DESC;

# Now comes the exiting part I am going to clean data in short this is 
# Data Cleanning of the raw data we've in sql.

-- products with zero mrp or discountSelling price

select * from zepto 
where mrp=0 or   discountedSellingPrice=0;

-- Deleting the column with 0 mrp
DELETE from  zepto
where mrp=0;

-- checking if the deletion was sucessfull or not 

select * from zepto 
where mrp=0 or   discountedSellingPrice=0;

# I see the deletion of the rows with 0 mrp was a success

select * from zepto ;

-- upon looking into the above data isinde the table I came to see that the price in mrp and discountedSellingPrice are in paisa but not in ruppes
-- lets convert that to rupes by dividing the columns with 100.00

update zepto
set mrp=mrp/100.00,
discountedSellingPrice=discountedSellingPrice/100.00;

-- checking to see if the changes were succesfull or not 

SELECT * FROM zeptO ;

# The changes was succesfull upon looking into the above data inside the table 

# Let's see few pre requesties to acheive from the below data

#   q1: Find the top  10 best-value products based on the discount percentage.

#  q2: What are the products with high MRP but currently out of stock?

#  q3: Calculate the estimated revenue for each product category.

# q4:  Find all products where the MRP is greater than a specified amount and the discount percentage is less than 10%.

# q5: Identify the top 5 categories offering the highest average discount percentage.

# q6: Find the price per gram for products priced above a 100 grams and sort them by best value.

# q7: Group the products into categories such as Low, Medium, and Bulk based on their weight or quantity. 

# Q1: Answer  

select sku_id,  name, discountPercent from zepto
where discountPercent> ( SELECT AVG(discountPercent) from zepto)
ORDER BY discountPercent DESC
LIMIT 10;

# Q2 Answer:
select name, mrp mrp_of_the_product from zepto
where outOfStock = 1 And mrp>(select avg(mrp) from zepto)
ORDER BY mrp DESC
LIMIT 10; 


# Q3 Answer: 
select * from zepto ; 
select  category, sum(discountedSellingPrice * availableQuantity) as total_revenue from zepto 
GROUP BY category;

# Q4 Answer: 
select category, name, mrp, discountPercent, discountedSellingPrice from zepto
where discountPercent < 10.00 AND mrp > discountedSellingPrice;


# Q5 Answer:  
select category, avg(discountPercent)  average_discount_for_each_category from zepto
GROUP BY category
ORDER BY avg(discountPercent) DESC
limit 5;

#Q6 Answer: # q6: Find the price per gram for products priced above a 100 grams and sort them by best value.

 select name, mrp/weightInGms as price_per_gram from zepto
 where weightInGms>100 
order by mrp/weightInGms DESC ;


# Q7:  Answer --> # q7: Group the products into categories such as Low, Medium, and Bulk based on their weight or quantity. 
 select category, sum(mrp), sum(availableQuantity), sum(weightInGms), avg(weightInGms) from  zepto
group by category;

SELECT  name, weightInGms,
       CASE
           WHEN weightInGms < 100 THEN 'Low'
           WHEN weightInGms BETWEEN 100 AND 500 THEN 'Medium'
           ELSE 'High'
       END AS weight_category
FROM zepto
order by weightInGms DESC;

#Q8: Answer --> What is the total Inventory weight per category

SELECT category, sum(weightInGms * availableQuantity ) Total_Inventory_Weight from zepto
GROUP BY category 
ORDER BY sum(weightInGms) DESC ; 
