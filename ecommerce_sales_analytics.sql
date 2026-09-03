create database project1;
use project1;

select * from customers;
select * from order_items;
select * from orders;
select * from products;

describe customers;
update customers set signup_date=str_to_date(signup_date,'%d-%m-%Y');
alter table customers modify signup_date date;

describe order_items;

describe orders;
update orders set order_date=str_to_date(order_date,'%d-%m-%Y');
alter table orders modify order_date date;

describe products;

#BASIC QS !!

#Q1. The marketing team wants to understand the size of our customer base in each country. 
#Can you provide the number of customers in each country and identify the countries with the largest customer base?
select country,count(customer_id) as no_customers from customers group by country order by no_customers desc;

#Q2. The operations manager wants an overview of our order pipeline.
#Can you show how many orders are currently in each status and identify the most common order status?
select status, count(*) as order_count from orders group by status order by order_count desc;

#Q3. The operations team is currently investigating cancelled orders.
#Can you retrieve the cancelled orders and show their order IDs and order dates?
select order_id,order_date from orders where status='cancelled';

#Q4. The finance team wants to review high-priced transactions.
#Can you identify the order items where the unit price is above ₹100 and display the highest-priced items first?
select * from order_items where price>100 order by price desc;

#Q5. The marketing team wants to identify the dates on which we acquired the most customers.
#Can you show the number of customer signups for each signup date and identify the busiest signup dates?
select signup_date, count(*) as count from customers group by signup_date order by count desc;

#Q6. The operations manager wants to investigate orders placed on a particular date.
#Can you retrieve all orders placed between august to october and arrange them by order ID?
select * from orders where order_date between '2024-08-01' and '2024-10-31' order by order_id;

#Q7. The product manager wants a quick overview of our pricing.
#Can you report the minimum, maximum and average recorded unit price across our transactions?
select min(price) as min, max(price) as max, avg(price) as avg from order_items;

#Q8. Management wants to know whether our orders are concentrated in a particular status. 
#Can you identify the percentage of orders represented by each status?
select status, round(count(*) * 100/ (select count(*) from orders),1 )as percentage from orders group by status;


#INTERMEDIATE QS !!

#Q9. The finance manager wants to know the total sales value generated from the available order items.
#Can you calculate the overall sales value using quantity and unit price?
select sum(quantity*price) as tot_sales from order_items;

#10. The sales manager wants to compare the financial performance of our product categories. 
#Can you calculate total sales value for each category and display the categories from highest to lowest?
select p.category,sum(oi.quantity*oi.price) as tot_sales from products as p
join order_items as oi on p.product_id=oi.product_id group by p.category order by tot_sales desc;

#11. We're planning a customer loyalty program. 
#Can you identify the 10 customers who have generated the highest sales value?
select c.customer_id, sum(oi.quantity*oi.price) as sales from customers as c 
join orders as o on c.customer_id=o.customer_id
join order_items as oi on o.order_id=oi.order_id
group by c.customer_id order by sales desc limit 10;

#12. The product team wants to identify the products with the strongest demand.
#Can you find the top 10 products based on total quantity sold?
select p.product_id,p.product_name, sum(oi.quantity) as tot_qty from products as p
join order_items as oi on p.product_id=oi.product_id
group by p.product_id,p.product_name order by tot_qty desc limit 10;

#13. The sales manager wants to know which individual products contribute the most to revenue.
#Can you display products based on their total sales value like lowest to highest?
select p.product_id,p.product_name, sum(oi.quantity*oi.price) as tot_sales from products as p
join order_items as oi on p.product_id=oi.product_id
group by p.product_id,p.product_name order by tot_sales;

#14. The finance team wants to understand the typical value of an order.
#Can you calculate the average sales value per order?
select avg(sum_sales) as avg_sales from (select o.order_id, sum(oi.quantity*oi.price) as sum_sales from orders as o
join order_items as oi on o.order_id=oi.order_id group by o.order_id) as x;

#15. The CRM team wants to identify customers who have placed multiple orders.
#Can you find customers with more than one order so that we can analyze repeat purchasing behavior?
select o.customer_id, count(*) as order_count from orders as o 
join customers as c on c.customer_id=o.customer_id 
group by o.customer_id having order_count>1; 

#16. The marketing manager wants to create a VIP customer segment.
#Can you identify customers whose total spending exceeds a specified business threshold (i.e, 2500)
select c.customer_id, sum(oi.quantity*oi.price) as tot_spend from customers as c 
join orders as o on c.customer_id=o.customer_id
join order_items as oi on o.order_id=oi.order_id
group by c.customer_id having tot_spend > 2500;

#17. The product team wants to compare pricing across our product categories. 
#Can you identify the minimum and maximum recorded unit price for each category, along with the number of units sold in that category?
select p.category, min(oi.price) as min_unit_price,
max(oi.price) as max_unit_price, sum(oi.quantity) as units_count from products as p
join order_items as oi on oi.product_id=p.product_id group by p.category;

#18. The marketing team wants to divide customers into Low, Medium and High-value groups based on their total spending. 
#Can you classify each customer into the appropriate spending segment?
with details as(
select c.customer_id, sum(oi.quantity*oi.price) as tot_spend from customers as c 
join orders as o on c.customer_id=o.customer_id
join order_items as oi on o.order_id=oi.order_id
group by c.customer_id
)
select customer_id , case
when tot_spend <1000 then 'Low'
when tot_spend between 1000 and 3000 then 'Medium'
else 'High'
end as spending_segment from details;


#ADVANCED QS !!

#Q19. Each category manager wants to know which products are performing best within their category. 
#Can you identify the top three products in every category based on total sales value?
with cat_detail as(
select p.category, p.product_name, sum(oi.quantity*oi.price) as tot_sales,
row_number() over( partition by p.category order by sum(oi.quantity*oi.price) desc) as rs
from products as p join order_items as oi on p.product_id=oi.product_id
group by p.category,p.product_name)
select * from cat_detail where rs<=3;

#Q20. Management wants to identify customers who are more valuable than the average customer. 
#Can you find customers whose total spending is higher than the average spending across all customers?
with spending as(
select c.customer_id,c.country, sum(oi.quantity*oi.price) as tot
 from customers as c join orders as o on c.customer_id=o.customer_id
 join order_items as oi on oi.order_id=o.order_id group by c.customer_id, c.country)
 select*from spending where tot> (select avg(tot) from spending);
 
 #21. The marketing team wants to prioritize customers according to their contribution to sales. 
 #Can you rank customers from highest to lowest based on their total spending?
 select c.customer_id,c.country, sum(oi.quantity*oi.price) as tot,
 dense_rank() over(order by sum(oi.quantity*oi.price) desc) as rs
 from customers as c join orders as o on c.customer_id=o.customer_id
 join order_items as oi on oi.order_id=o.order_id 
 group by c.customer_id, c.country;
 
 #22. The category managers want to identify their strongest individual product. 
 #Can you find the single highest-revenue product within every product category?
 with strong_pdct as (
 select p.product_id,p.product_name,p.category ,row_number() over( partition by category order by sum(oi.quantity*oi.price) desc) as r
 from products as p join order_items as oi on p.product_id=oi.product_id group by p.product_id,p.product_name,p.category)
 select * from strong_pdct where r=1;
 
 #23. Management wants to understand how dependent the business is on its highest-value customers. 
 #What percentage of our total sales value is generated by the top 10 customers?
 select sum(tot)*100/(select sum(quantity*price) from order_items) as percentage from
 (select c.customer_id, sum(oi.quantity*oi.price) as tot
 from customers as c join orders as o on o.customer_id=c.customer_id
 join order_items as oi on oi.order_id=o.order_id group by c.customer_id
 order by tot desc limit 10) as y;
 
 #24. Management wants a reusable customer sales summary for future reporting. 
 #Can you create a SQL view containing each customer's total number of orders, total quantity purchased and total spending?
 create view sales_summary as select c.customer_id,count(distinct o.order_id) as order_count,
 sum(oi.quantity) as tot_qty,sum(oi.quantity*oi.price) as tot_spend from customers as c join orders as o on o.customer_id=c.customer_id
 join order_items as oi on oi.order_id=o.order_id group by c.customer_id;
 select * from sales_summary;
 
 #25. The customer-support team frequently needs to retrieve a customer's purchase history. 
 #Can you create a stored procedure that accepts a customer ID and returns all orders and products purchased by that customer?
 delimiter //
 create procedure purchase_history(in id int)
 begin
	select c.*,o.order_id,order_date,o.status,p.*,oi.quantity,oi.price from customers as c join orders as o on o.customer_id=c.customer_id
 join order_items as oi on oi.order_id=o.order_id 
 join products as p on p.product_id=oi.product_id where c.customer_id=id;
 end //
 delimiter ;
 call purchase_history(45);

