--create database Retail_info
use [Retail_info];
---Q1----------------------------------
--Begin
Select sum(b.A) as 'Total No. of Rows' from(
select count(*) as A from Customer
union All
select count(*) from Prod_Cat_Info
union All
select count(*) from Transactions)b

--end 
----------------------Q2---------------------------------------
---Begin
select count(transaction_id) as 'Number of Returns' from Transactions where total_amt<0 

--end 
---------------Q4------------------------------------------------------------------------

select avg(yr) as 'Years',avg(Months) as 'Months',avg(Day) as 'Days' from(select  DATEDIFF("YEAR",tran_date,GETDATE()) as Yr,Datediff("DAY",tran_date,getdate()) as 'Day',
Datediff("MONTH",tran_date,getdate()) as 'Months'

from Transactions)b


--------------------Q5---------------------
select prod_cat from Prod_Cat_Info where prod_subcat='DIY'


-------------------Data Analysis-----------------------------
-------------------Q1--------------------------------
--Q1--Begin

select  Top 1 Store_type,NumberofTran from(select distinct Store_type,count(transaction_id) over(Partition by Store_type) as NumberofTran  from Transactions)T order by T.NumberofTran desc

--Q1 ENd

--Q2--Begin

select distinct (case when Gender='M' then'Male' else 'Female' end) as 'Gender',count(Customer_id) over(Partition by Gender) from Customer where Gender is Not null

--Q2--End



--Q3--Begin
select top 1 b.city_code,citycount from (select distinct city_code,count(customer_id) over(Partition by city_code) as Citycount from Customer)b order by Citycount desc

--Q3--End-------------------

--Q4--Begin

select count(distinct prod_subcat) as'Number of SubCat',prod_cat  from  Prod_Cat_Info where prod_cat like 'Book%' group by prod_cat

--Q4--End


--Q5--Begin

select count(transaction_id) as'Total Number of Orders'  from Transactions where total_amt>0

--Q5--End


--Q6--Begin

select  P.PCode as Product,T.prod_cat_code,sum(total_amt) as 'Total Revenue'  from Transactions as T join (select distinct prod_cat as PCode,prod_cat_code as pccode  from prod_cat_info)P  on 

P.pccode=T.prod_cat_code

where T.prod_cat_code in(3,5)
group by  T.prod_cat_code,P.PCode

--Q6--End


--Q7--Begin

select count(cust_id) as 'Number Of Customers' from (select distinct cust_id,count(transaction_id) over(Partition by cust_id) as Count_Trans from Transactions where total_amt>0)T where T.Count_Trans>10 


--Q7--End



--Q8--Begin

 
 
select sum(total_amt) as 'Total Revenue' from Transactions  as T 
join  
(select distinct prod_cat,prod_cat_code from Prod_Cat_Info)Pc  on Pc.prod_cat_code=T.prod_cat_code

where Pc.prod_cat in ('Electronics','Clothing') And Store_Type like 'Flagship%'


--Q8--End

--Q9--Begin

select  case when C.Gender='M'then 'Male' end as Gender,P.PSCode as Product,sum(total_amt)   as 'Total Revenue'  

from Transactions as T join 

(select distinct prod_subcat as PSCode,prod_sub_cat_code as PRO_sub_cat_code,prod_cat  from prod_cat_info)P  on 

P.PRO_sub_cat_code=T.prod_subcat_code

join (Select * from Customer where gender ='M') as C  on C.customer_id=T.cust_id

where P.prod_cat='Electronics'
group by P.PSCode,T.prod_subcat_code,C.Gender

--Q9--End


--Q10-Begin


select  P.PSCode as Product,T.prod_subcat_code,sum(t.total_amt) as 'Total revenue',

sum(case when total_amt>0 then total_amt else 0 end )*100/(select sum(total_amt) from Transactions)    as 'PercentageofSales',  
sum(abs(case when total_amt<0 then total_amt else 0 end ))*100/(select sum(total_amt) from Transactions)    as 'Percentage of Return'  

from Transactions as T join 

(select distinct prod_subcat as PSCode,prod_sub_cat_code as PRO_sub_cat_code,prod_cat  from prod_cat_info)P  on 

P.PRO_sub_cat_code=T.prod_subcat_code

group by P.PSCode,T.prod_subcat_code
order by PercentageofSales desc

--Q10--End

--Q11--Begin


 select Tr.cust_id,sum(total_amt) over(Partition by tr.cust_id),tran_date  from Transactions as  tr 
 left join
 (select customer_Id,DATEDIFF("YEAR",DOB,getdate()) as Age from Customer where DATEDIFF("YEAR",DOB,getdate()) between 25 and 35)Cr
 on Cr.customer_Id=tr.cust_id
 join
( select cust_id,dateadd("Day",-30,Maxdate) as Newdate,Maxdate from(select distinct cust_id,max(tran_date) over(partition by Cust_id) as MaxDate from Transactions)T)TP

on TP.cust_id=tr.cust_id

where  (tr.tran_date>=tp.Newdate and tr.tran_date<=tp.MaxDate)
 

--Q11--End
 
 --Q12--Begin


SELECT TOP 1
    prod_cat_code
    ,SUM(Total_amt) as 'Totalofreturns',count(transaction_id) as 'Returntransactions'
    FROM TRANSACTIONS
WHERE Tran_date >= DATEADD(day, -90, '2014-12-31') 
    AND Total_amt < 0
GROUP BY prod_cat_code
ORDER BY Totalofreturns ASC


--Q12--End

--Q13--Begin

with Store as (select store_type,count(prod_subcat_code) as CountofProduct,sum(total_amt) as Sum1 from Transactions group by store_type )
select top 1 * from store order by Sum1 desc,CountofProduct desc

--Q13--End

--Q14--Begin

select prod_cat_code,avg(total_amt) from Transactions  group by prod_cat_code having avg(total_amt)>(select avg(total_amt) from Transactions)

--Q14--End

--Q15--Begin


select prod_cat_code,prod_subcat_code,avg(total_amt) 'Avereage' ,sum(total_amt) 'Total revenue',count(Qty) 'Quantity sold' from Transactions where qty>0 group by prod_cat_code,prod_subcat_code
order by count(qty) desc

--Q15--End