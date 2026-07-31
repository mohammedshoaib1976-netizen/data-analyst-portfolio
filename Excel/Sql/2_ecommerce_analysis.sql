/* ============================================================
   PROJECT 2: E-COMMERCE ANALYSIS
   Tables: Customers, Products, Orders, OrderItems
   Business questions: Revenue, Top Customers, Monthly Sales,
   Repeat Customers
   Skills demonstrated: multi-table JOINs, GROUP BY, UNION,
   window functions, CTEs, views
   ============================================================ */

-- ---------- SCHEMA ----------
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    customer_id   INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city          TEXT,
    signup_date   DATE
);

CREATE TABLE Products (
    product_id    INTEGER PRIMARY KEY,
    product_name  TEXT NOT NULL,
    category      TEXT,
    unit_price    DECIMAL(10,2)
);

CREATE TABLE Orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL,
    order_date    DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderItems (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL,
    product_id    INTEGER NOT NULL,
    quantity      INTEGER,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ---------- SAMPLE DATA ----------
INSERT INTO Customers (customer_id, customer_name, city, signup_date) VALUES
(1, 'Acme Retail', 'Bengaluru', '2025-01-15'),
(2, 'BlueWave Traders', 'Mumbai', '2025-02-20'),
(3, 'CityMart', 'Delhi', '2025-03-10'),
(4, 'Delta Distributors', 'Chennai', '2025-04-05'),
(5, 'Everest Supplies', 'Pune', '2025-05-18'),
(6, 'FreshLine Corp', 'Hyderabad', '2025-06-22'),
(7, 'Global Basket', 'Kolkata', '2025-07-30'),
(8, 'Horizon Stores', 'Bengaluru', '2025-08-14');

INSERT INTO Products (product_id, product_name, category, unit_price) VALUES
(1, 'Wireless Mouse', 'Electronics', 799),
(2, 'Mechanical Keyboard', 'Electronics', 2999),
(3, 'USB-C Hub', 'Electronics', 1499),
(4, '27" Monitor', 'Electronics', 15999),
(5, 'Laptop Stand', 'Accessories', 999),
(6, 'Office Chair', 'Furniture', 8999),
(7, 'Desk Lamp', 'Furniture', 1299),
(8, 'Notebook Set', 'Stationery', 249);

INSERT INTO Orders (order_id, customer_id, order_date) VALUES
(1, 1, '2026-01-05'), (2, 2, '2026-01-12'), (3, 1, '2026-01-20'),
(4, 3, '2026-02-02'), (5, 4, '2026-02-10'), (6, 2, '2026-02-15'),
(7, 5, '2026-03-01'), (8, 1, '2026-03-08'), (9, 6, '2026-03-14'),
(10, 3, '2026-04-02'), (11, 7, '2026-04-11'), (12, 2, '2026-04-19'),
(13, 8, '2026-05-05'), (14, 4, '2026-05-16'), (15, 1, '2026-05-25'),
(16, 5, '2026-06-03'), (17, 6, '2026-06-10'), (18, 3, '2026-06-20');

INSERT INTO OrderItems (order_item_id, order_id, product_id, quantity) VALUES
(1, 1, 1, 5), (2, 1, 2, 2), (3, 2, 4, 1), (4, 3, 5, 3),
(5, 4, 3, 4), (6, 5, 6, 2), (7, 6, 1, 10), (8, 7, 8, 20),
(9, 8, 2, 3), (10, 9, 7, 5), (11, 10, 4, 1), (12, 11, 1, 8),
(13, 12, 3, 6), (14, 13, 6, 1), (15, 14, 5, 4), (16, 15, 2, 2),
(17, 16, 8, 15), (18, 17, 1, 6), (19, 18, 7, 3), (20, 18, 3, 2);

/* ============================================================
   ANALYSIS QUERIES
   ============================================================ */

-- Q1: Total revenue per order (JOIN + calculated column)
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    SUM(oi.quantity * p.unit_price) AS order_revenue
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY o.order_id
ORDER BY order_revenue DESC;

-- Q2: Total revenue overall + by category
SELECT
    p.category,
    SUM(oi.quantity * p.unit_price) AS category_revenue,
    SUM(oi.quantity) AS units_sold
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Q3: Top 5 customers by total spend
SELECT
    c.customer_name,
    c.city,
    SUM(oi.quantity * p.unit_price) AS total_spend,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 5;

-- Q4: Monthly sales trend
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    SUM(oi.quantity * p.unit_price) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS order_count
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

-- Q5: Repeat customers (customers with more than 1 order) - GROUP BY + HAVING
SELECT
    c.customer_name,
    COUNT(o.order_id) AS number_of_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING COUNT(o.order_id) > 1
ORDER BY number_of_orders DESC;

-- Q6: One-time vs repeat customers using CASE + subquery
SELECT
    CASE WHEN order_count = 1 THEN 'One-Time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS number_of_customers
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM Orders
    GROUP BY customer_id
) sub
GROUP BY customer_type;

-- Q7: Best-selling product by quantity (window function - top product per category)
SELECT
    category,
    product_name,
    total_units,
    rnk
FROM (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity) AS total_units,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM Products p
    JOIN OrderItems oi ON p.product_id = oi.product_id
    GROUP BY p.product_id
) ranked
WHERE rnk = 1;

-- Q8: CTE - Customer lifetime value with running total by signup cohort
WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        strftime('%Y-%m', c.signup_date) AS signup_month,
        SUM(oi.quantity * p.unit_price) AS lifetime_value
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN OrderItems oi ON o.order_id = oi.order_id
    JOIN Products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id
)
SELECT
    signup_month,
    customer_name,
    lifetime_value,
    SUM(lifetime_value) OVER (PARTITION BY signup_month ORDER BY lifetime_value DESC) AS cohort_running_total
FROM CustomerRevenue
ORDER BY signup_month, lifetime_value DESC;

-- Q9: Products never ordered (LEFT JOIN + IS NULL) - inventory insight
SELECT p.product_name, p.category
FROM Products p
LEFT JOIN OrderItems oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- Q10: Customers from Bengaluru UNION customers who spent over 20,000 (UNION)
SELECT customer_name, 'Bengaluru-based' AS reason FROM Customers WHERE city = 'Bengaluru'
UNION
SELECT c.customer_name, 'High spender' AS reason
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY c.customer_id
HAVING SUM(oi.quantity * p.unit_price) > 20000;

-- Q11: VIEW - Reusable monthly revenue view
DROP VIEW IF EXISTS MonthlyRevenue;
CREATE VIEW MonthlyRevenue AS
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    SUM(oi.quantity * p.unit_price) AS revenue
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY month;

SELECT * FROM MonthlyRevenue ORDER BY month;
