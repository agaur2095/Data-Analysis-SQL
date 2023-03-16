use [SQL_challenge]

select * from product_hierarchy
select * from product_details
select * from product_prices
select * from clothing_sales

--Q1 What was the total quantity sold for each product?

select prod_id,product_name,sum(qty) as 'Quantitysold' from clothing_sales
join product_details on product_details.product_id=clothing_sales.prod_id
group by prod_id,product_name
order by Quantitysold desc

--Q2 What is the total generated revenue for all products before discounts?

select  sum(qty*price) as 'TotalRevenue' from clothing_sales

--Q3 What was the total discount amount for all products?

select sum(qty*price) 'RevenuebeforeDiscount',sum(qty*price*(100-discount)/100) 'RevenueAfterDiscount' from clothing_Sales

--Q4 How many unique transactions were there?



select count(distinct txn_id) as 'NUmberofUniqueTransc.' from clothing_sales

--Q5  What is the average unique products purchased in each transaction?



select txn_id,count(distinct prod_id) from clothing_sales
group by txn_id

---Q6 What is the percentage split of all transactions for members vs non-members


select case when member=0 then 'Non-Member' else 'Member' end,cast(sum(qty*price) as float)/(select sum(qty*price) from clothing_sales) from clothing_sales

group by member

--Q7


select  TOP 3 Product_name,Revenue from product_details
join
(select prod_id,sum(qty*price)  as 'Revenue' from clothing_Sales
group by prod_id)s
on
s.prod_id=product_details.product_id

order by revenue desc

--Q8 


select  segment_name,Sum(Revenue) as 'Revenue',Sum(s.[ Discount]) as 'revenueofterDiscount',Sum(TotalQuantity) as 'TotalQuantity' from product_details
join
(select prod_id,sum(qty*price)  as 'Revenue',sum(qty*price*(100-discount)/100) as' Discount',sum(qty) as'TotalQuantity' from clothing_Sales
group by prod_id)s
on
s.prod_id=product_details.product_id
group by segment_name

--Q9

with cte as (select  segment_name,product_name,Sum(Revenue) as 'Revenue',Sum(s.[ Discount]) as 'revenueofterDiscount',Sum(TotalQuantity) as 'TotalQuantity' 
from product_details
join
(select prod_id,sum(qty*price)  as 'Revenue',sum(qty*price*(100-discount)/100) as' Discount',sum(qty) as'TotalQuantity' from clothing_Sales
group by prod_id)s
on
s.prod_id=product_details.product_id
group by segment_name,product_name)

select Top 4 *,
rank() over(partition by segment_name order by revenue desc) as 'Rank' from CTE
order by rank

--Q10 What is the total transaction “penetration” for each product? 
--(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided 
--by total number of transactions)



select prod_id,product_name,segment_name,Market_Percentage from product_details
join 
(select prod_id,cast(count(distinct txn_id) as float)*100/(select count(distinct txn_id) from clothing_sales) as 'Market_Percentage'  from clothing_sales
group by prod_id)s
on s.prod_id=product_details.product_id
order by Market_Percentage desc

---Q11 Data 360 File
select * from clothing_sales


select segment_name,category_name,product_name,prod_id,sum(qty*cs.price) as 'Revenue_beforeDiscount',
sum(qty*cs.price*(100-discount)/100) 'RevenueAfterDiscount' ,sum(Case when member =1 then qty*cs.price else 0 end ) as 'RevenuebyMembers',
sum(Case when member =0 then qty*cs.price else 0 end ) as 'RevenuebyNon-Members',count(distinct cs.txn_id) as 'Total Transactions',
sum(qty) as 'Total Quantity',
cast(cast(count(distinct txn_id) as float)*100/(select count(distinct txn_id) from clothing_sales) as varchar)+'%' as 'Market_Percentage' 
from   product_details
join clothing_sales as cs on cs.prod_id=product_details.product_id

group by segment_name,category_name,product_name,prod_id