-- Total product categories does Magist have? ans; 74
select count(product_category_name) from product_category_name_translation;


-- What categories of tech products does Magist have? ans; 12
select *,
case 
when product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') then "Tech"
else "Non-Tech"
end as product_classification
from product_category_name_translation having product_classification = "Tech"; 
select count(*) as Total_tech_products from (select *,
case 
when product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') then "Tech"
else "Non-Tech"
end as product_classification
from product_category_name_translation) as classified_products where product_classification = "Tech";


-- How many products of these tech categories have been sold (within the time window of the database snapshot)?
with productclassification as
(select * ,
case when product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') then "Tech"
else "Non tech"
end as Tech_NonTech_Classification
from product_category_name_translation
)
select sum(order_counts.total_orders) as total_orders, productclassification.Tech_NonTech_Classification
from 
(select count(order_id) as total_orders, product_category_name 
from order_items
join products
using (product_id)
group by product_category_name) as order_counts
join productclassification 
on order_counts.product_category_name = productclassification.product_category_name
group by productclassification.Tech_NonTech_Classification;


-- Calculate the number of products sold within the Tech categories
SELECT 
    COUNT(DISTINCT oi.product_id) AS num_tech_products_sold
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE 
    CASE 
        WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
        ELSE 'Non-Tech'
    END = 'Tech';
    
    

-- Calculate the total number of products sold
SELECT 
    COUNT(DISTINCT oi.product_id) AS total_products_sold
FROM 
    order_items oi;



-- Calculate the percentage of products sold within the Tech categories from the overall number of products sold
SELECT 
    (SELECT COUNT(DISTINCT oi.product_id) FROM order_items oi
     JOIN products p ON oi.product_id = p.product_id
     JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
     WHERE 
        CASE 
            WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
            ELSE 'Non-Tech'
        END = 'Tech') / 
    (SELECT COUNT(DISTINCT oi.product_id) FROM order_items oi) * 100 AS percentage_tech_products_sold;



-- What’s the average price of the products being sold?
select round(avg(price),2) from order_items;


-- Are expensive tech products popular? *
select case
when price>500 then 'Expensive'
when price>100 then 'Mid-level'
else 'cheap'
end as price_range, count(product_id)
from order_items
left join product_category_name_translation
using (product_id)
left join product_category_name_translation
using (product_category_name)
where product_category_name_english in ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') group by Price_range;

-- How many months of data are included in the magist database?
SELECT 
    MIN(order_purchase_timestamp) AS earliest_timestamp,
    MAX(order_purchase_timestamp) AS latest_timestamp,
    TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS months_of_data
FROM 
    orders;

-- How many sellers are there?

SELECT COUNT(DISTINCT seller_id) AS num_sellers
FROM sellers;



-- How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-- Count the number of Tech sellers
SELECT COUNT(DISTINCT s.seller_id) AS num_tech_sellers
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE 
    CASE 
        WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
        ELSE 'Non-Tech'
    END = 'Tech';
    
-- Calculate the percentage of Tech sellers out of overall sellers
SELECT 
    COUNT(DISTINCT s.seller_id) AS num_tech_sellers,
    COUNT(DISTINCT s.seller_id) / (SELECT COUNT(DISTINCT seller_id) FROM sellers) * 100 AS percentage_tech_sellers
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE 
    CASE 
        WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
        ELSE 'Non-Tech'
    END = 'Tech';
    
    
-- What is the total amount earned by all sellers? 
select sum(price) as Total_amount from order_items;



-- What is the total amount earned by all Tech sellers?
-- Calculate the total amount earned by all Tech sellers
SELECT 
    SUM(oi.price + oi.freight_value) AS total_earnings
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    sellers s ON oi.seller_id = s.seller_id
JOIN 
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE 
    CASE 
        WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
        ELSE 'Non-Tech'
    END = 'Tech';


-- Can you work out the average monthly income of all sellers?
-- Calculate the average monthly income of all sellers
SELECT 
    (SELECT SUM(oi.price + oi.freight_value) FROM order_items oi) / 
    (SELECT TIMESTAMPDIFF(MONTH, MIN(o.order_purchase_timestamp), MAX(o.order_purchase_timestamp)) AS num_months FROM orders o) AS average_monthly_income;

-- Can you work out the average monthly income of Tech sellers?
-- Calculate the total income earned by Tech sellers
SELECT 
    SUM(oi.price + oi.freight_value) AS total_income
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    sellers s ON oi.seller_id = s.seller_id
JOIN 
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE 
    CASE 
        WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
        ELSE 'Non-Tech'
    END = 'Tech';

-- Calculate the number of months covered by the dataset
SELECT 
    TIMESTAMPDIFF(MONTH, MIN(o.order_purchase_timestamp), MAX(o.order_purchase_timestamp)) AS num_months
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE 
    CASE 
        WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
        ELSE 'Non-Tech'
    END = 'Tech';

-- Calculate the average monthly income of Tech sellers
SELECT 
    (SELECT SUM(oi.price + oi.freight_value) 
     FROM order_items oi
     JOIN products p ON oi.product_id = p.product_id
     JOIN sellers s ON oi.seller_id = s.seller_id
     JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
     WHERE 
        CASE 
            WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
            ELSE 'Non-Tech'
        END = 'Tech') / 
    (SELECT TIMESTAMPDIFF(MONTH, MIN(o.order_purchase_timestamp), MAX(o.order_purchase_timestamp)) AS num_months 
     FROM orders o
     JOIN order_items oi ON o.order_id = oi.order_id
     JOIN products p ON oi.product_id = p.product_id
     JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
     WHERE 
        CASE 
            WHEN pct.product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift') THEN 'Tech'
            ELSE 'Non-Tech'
        END = 'Tech') AS average_monthly_income;

-- What’s the average time between the order being placed and the product being delivered?
select  Avg(time(order_purchase_timestamp)) from orders;
select order_purchase_timestamp, order_delivered_customer_date from orders;
SELECT AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_time_hours
FROM orders
WHERE order_status = 'delivered';

select CASE 
when price > 500 then 'Expensive'
when price > 100 then 'Mid-level'
else 'Cheap'
end as price_range, count(product_id)
from order_items
left join products
	using (product_id)
left join product_category_name_translation
	using (product_category_name)
where product_category_name_english IN ('computers_accessories', 'electronics', 'consoles_games', 'computers', 'pc_gamer', 'watches_gift')
group by price_range;



-- How many orders are delivered on time vs orders delivered with a delay?

    Select CASE
when datediff(order_estimated_delivery_date,order_delivered_customer_date ) >0 then "Delayed"
Else "On time"
end as delivery_status, count(order_id)
from orders
where order_status = 'delivered'
group by delivery_status;
    
    
-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT 
    p.product_id,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    o.order_id,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_delay
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON oi.product_id = p.product_id
WHERE 
    o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL;
select count(order_id) from orders;
    SELECT count(*) from orders;






