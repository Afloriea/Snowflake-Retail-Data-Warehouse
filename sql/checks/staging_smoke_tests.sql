/* Smoke tests on the staging layer, run after loading to confirm the joins between
   source tables work before any modelling. */

-- Most popular product colour by units sold
SELECT p.Color, SUM(sd.SalesQuantity) AS total_quantity_sold
FROM STAGING_PRODUCT p
JOIN STAGING_SALESDETAIL sd ON p.ProductID = sd.ProductID
GROUP BY p.Color
ORDER BY total_quantity_sold DESC;

-- Order lines per customer
SELECT c.FirstName, c.LastName, COUNT(*) AS order_lines
FROM STAGING_CUSTOMER c
JOIN STAGING_SALESHEADER sh ON c.CustomerID = sh.CustomerID
JOIN STAGING_SALESDETAIL sd ON sh.SalesHeaderID = sd.SalesHeaderID
GROUP BY c.FirstName, c.LastName
ORDER BY order_lines DESC;

-- Transactions per store manager
SELECT s.StoreID, s.StoreNumber, s.StoreManager, COUNT(sh.SalesHeaderID) AS total_transactions
FROM STAGING_STORE s
JOIN STAGING_SALESHEADER sh ON s.StoreID = sh.StoreID
GROUP BY s.StoreID, s.StoreNumber, s.StoreManager
ORDER BY total_transactions DESC;
