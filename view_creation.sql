-- What's the relation between price and quantity purchased as a whole?
-- Did products with smaller prices have larger or smaller revenue?
-- What product had more orders cancelled?
-- What products were more purchased in each month?
-- Was there preference for faster delivery on some products?
-- What countries of origin were more common?
-- What products had orders with larger quantities?
-- What products had orders with smaller quantities?
-- Does price affect the quantity of products purchased in a single order?
-- Does a higher quantity of items purchased in a single order increase the likelihood of expedited delivery?
-- Which products had higher demand overall?
-- Does a higher product price increase the likelihood of requesting expedited delivery?
-- Does the country of origin correlate with product price?  
-- Does the country or origin correlate with the ratio of products cancelled?
-- What countries or origin had more and less of each product sold?
---------------------------------------------------------------------------------------------------------


-- What's the relation between price and quantity purchased as a whole?
CREATE VIEW price_quantity_relation AS
SELECT p.Preco, SUM(s.qty::numeric) AS total_quantity_purchased
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY p.Preco;

-- Did products with smaller prices have larger or smaller revenue?
CREATE VIEW price_revenue_comparison AS
SELECT p.Preco, SUM((s.qty::numeric) * CAST(REPLACE(REPLACE(p.Preco, '$', ''), ',', '') AS numeric)) AS total_revenue
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY p.Preco;
    
-- What product had more orders cancelled?
CREATE VIEW cancelled_orders AS
SELECT s.Codigo, p.Produto, COUNT(*) AS cancelled_orders_count
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
WHERE s.courier_status = 'Cancelled'
GROUP BY s.Codigo, p.Produto;

-- What products were more purchased in each month?
CREATE VIEW popular_products_per_month AS
SELECT EXTRACT(MONTH FROM TO_DATE(s.date, 'MM/DD/YYYY')) AS month, s.Codigo, p.Produto, SUM(s.qty::numeric) AS total_quantity
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY month, s.Codigo, p.Produto;

-- Was there preference for faster delivery on some products?
CREATE VIEW expedited_delivery_preference AS
SELECT s.Codigo, p.Produto, s.ship_service_level, COUNT(*) AS expedited_orders,total_orders.total_orders_count
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
JOIN (SELECT Codigo, COUNT(*) AS total_orders_count FROM sales GROUP BY Codigo) AS total_orders ON s.Codigo = total_orders.Codigo
WHERE s.ship_service_level = 'Expedited'
GROUP BY s.Codigo, p.Produto, s.ship_service_level, total_orders.total_orders_count;

-- What countries of origin were more common?
CREATE VIEW common_origin_countries as	
SELECT s.ship_country, COUNT(*) AS orders_count
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.ship_country;

-- What products had orders with larger quantities?
CREATE VIEW products_larger_quantities AS
SELECT s.Codigo, p.Produto, MAX(s.qty) AS max_quantity
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.Codigo, p.Produto;

-- What products had orders with smaller quantities?
CREATE VIEW products_smaller_quantities AS
SELECT s.Codigo, p.Produto, MIN(s.qty) AS min_quantity
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.Codigo, p.Produto;

-- Does price affect the quantity of products purchased in a single order?
CREATE VIEW price_quantity_correlation AS
SELECT s.Codigo, p.Produto, p.Preco, AVG(s.qty::numeric) AS avg_quantity
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.Codigo, p.Produto, p.Preco;

-- Does a higher quantity of items purchased in a single order increase the likelihood of expedited delivery?
CREATE VIEW quantity_expedited_delivery_correlation AS
SELECT s.Codigo, p.Produto, AVG(s.qty::numeric) AS avg_quantity, COUNT(*) AS total_orders, SUM(CASE WHEN s.ship_service_level = 'Expedited' THEN 1 ELSE 0 END) AS expedited_orders
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.Codigo, p.Produto;

-- Which products had higher demand overall?
CREATE VIEW high_demand_products AS
SELECT s.Codigo, p.Produto, SUM(s.qty::numeric) AS total_quantity
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.Codigo, p.Produto;

-- Does a higher product price increase the likelihood of requesting expedited delivery?
CREATE VIEW price_expedited_delivery_correlation AS
SELECT s.Codigo, p.Produto, p.Preco, COUNT(*) AS total_orders, SUM(CASE WHEN s.ship_service_level = 'Expedited' THEN 1 ELSE 0 END) AS expedited_orders
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.Codigo, p.Produto, p.Preco;

-- Does the country of origin correlate with product price? ***** 
CREATE VIEW origin_price_correlation AS
SELECT p.Codigo, p.Produto, p.Preco, s.ship_country
FROM sales s
JOIN products p ON s.Codigo = p.Codigo;

-- Does the country or origin correlate with the ratio of products cancelled?
CREATE VIEW origin_cancellation_ratio AS
SELECT s.ship_country, COUNT(*) AS total_orders, SUM(CASE WHEN s.courier_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY s.ship_country;

-- What countries or origin had more and less of each product sold?
CREATE VIEW origin_products_sold AS
SELECT p.Codigo, p.Produto, s.ship_country, COUNT(*) AS products_sold
FROM sales s
JOIN products p ON s.Codigo = p.Codigo
GROUP BY p.Codigo, p.Produto, s.ship_country;