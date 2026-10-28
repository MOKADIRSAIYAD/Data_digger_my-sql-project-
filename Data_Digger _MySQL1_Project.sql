-- ============================================================
-- PROJECT: DATA DIGGER
-- Database: MySQL 8.0+
-- Topic: E-Commerce Database using CRUD, JOINs and Aggrega

-- ============================================================

CREATE DATABASE IF NOT EXISTS DataDigger;
USE DataDigger;

-- Drop child tables before parent tables so foreign keys do not fail.
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

-- ============================================================
-- 1. CUSTOMERS TABLE
-- Fields: CustomerID, Name, Email, Address
-- ============================================================
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name       VARCHAR(100) NOT NULL,
    Email      VARCHAR(150) NOT NULL UNIQUE,
    Address    VARCHAR(255)
);

-- Insert at least 5 sample customers.
INSERT INTO Customers (Name, Email, Address) VALUES
('Alice', 'alice@example.com', '12 Park Street, Ahmedabad'),
('Rahul', 'rahul@example.com', '24 River Road, Ahmedabad'),
('Priya', 'priya@example.com', '8 MG Road, Mumbai'),
('Amit', 'amit@example.com', '19 Lake View, Pune'),
('Neha', 'neha@example.com', '41 Green Avenue, Delhi');

-- Query 1: Retrieve all customer details.
SELECT * FROM Customers;

-- Query 2: Update a customer's address.
UPDATE Customers
SET Address = '55 New Market Road, Ahmedabad'
WHERE CustomerID = 1;

-- Verify the updated address.
SELECT * FROM Customers WHERE CustomerID = 1;

-- Query 3: Display all customers whose name is 'Alice'.
SELECT * FROM Customers
WHERE Name = 'Alice';

-- Query 4: Delete a customer using CustomerID.
-- This is commented out to preserve sample data and avoid foreign-key
-- errors if the customer has orders. To test it, delete their order
-- details and orders first, or choose a customer with no orders.
-- DELETE FROM Customers WHERE CustomerID = 5;


-- ============================================================
-- 2. ORDERS TABLE
-- Fields: OrderID, CustomerID, OrderDate, TotalAmount
-- ============================================================
CREATE TABLE Orders (
    OrderID     INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Insert at least 5 sample orders.
-- Dates use CURDATE() so the last-30-days query remains useful.
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, CURDATE() - INTERVAL 2 DAY,  2500.00),
(2, CURDATE() - INTERVAL 7 DAY,  1800.00),
(1, CURDATE() - INTERVAL 12 DAY, 3200.00),
(3, CURDATE() - INTERVAL 20 DAY, 950.00),
(4, CURDATE() - INTERVAL 45 DAY, 4100.00);

-- Query 1: Retrieve all orders made by a specific customer.
-- Example: CustomerID = 1
SELECT *
FROM Orders
WHERE CustomerID = 1;

-- Query 2: Update an order's total amount.
UPDATE Orders
SET TotalAmount = 2600.00
WHERE OrderID = 1;

-- Verify the updated order.
SELECT * FROM Orders WHERE OrderID = 1;

-- Query 3: Retrieve orders placed in the last 30 days.
SELECT *
FROM Orders
WHERE OrderDate >= CURDATE() - INTERVAL 30 DAY
  AND OrderDate <= CURDATE()
ORDER BY OrderDate DESC;

-- Query 4: Retrieve highest, lowest and average order amount.
SELECT
    MAX(TotalAmount) AS HighestOrderAmount,
    MIN(TotalAmount) AS LowestOrderAmount,
    AVG(TotalAmount) AS AverageOrderAmount
FROM Orders;

-- Query 5: Delete an order using its OrderID.
-- Uncomment to test after checking which order you want to remove.
-- If that order has OrderDetails, delete those detail rows first.
-- DELETE FROM Orders WHERE OrderID = 5;


-- ============================================================
-- 3. PRODUCTS TABLE
-- Fields: ProductID, ProductName, Price, Stock
-- ============================================================
CREATE TABLE Products (
    ProductID   INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_products_price CHECK (Price >= 0),
    CONSTRAINT chk_products_stock CHECK (Stock >= 0)
);

-- Insert at least 5 sample products.
INSERT INTO Products (ProductName, Price, Stock) VALUES
('Wireless Mouse', 650.00, 25),
('Mechanical Keyboard', 1800.00, 12),
('USB-C Cable', 500.00, 40),
('Headphones', 1500.00, 18),
('Laptop Stand', 1200.00, 10),
('Old Phone Case', 300.00, 0);

-- Query 1: Retrieve all products sorted by price in descending order.
SELECT *
FROM Products
ORDER BY Price DESC;

-- Query 2: Update the price of a specific product.
UPDATE Products
SET Price = 700.00
WHERE ProductID = 1;

-- Verify the updated price.
SELECT * FROM Products WHERE ProductID = 1;

-- Query 3: Retrieve products whose price is between ₹500 and ₹2000.
-- BETWEEN includes both 500 and 2000.
SELECT *
FROM Products
WHERE Price BETWEEN 500 AND 2000
ORDER BY Price ASC;

-- Query 4: Retrieve the most expensive and cheapest product using MAX/MIN.
SELECT
    MAX(Price) AS HighestPrice,
    MIN(Price) AS LowestPrice
FROM Products;

-- Optional: Show product names for the highest and lowest prices.
SELECT *
FROM Products
WHERE Price = (SELECT MAX(Price) FROM Products)
   OR Price = (SELECT MIN(Price) FROM Products);

-- Query 5: Delete a product if it is out of stock.
-- ProductID 6 is out of stock in the sample data.
-- This will work only if the product is not referenced in OrderDetails.
-- DELETE FROM Products WHERE Stock = 0;


-- ============================================================
-- 4. ORDERDETAILS TABLE
-- Fields: OrderDetailID, OrderID, ProductID, Quantity, SubTotal
-- ============================================================
CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID       INT NOT NULL,
    ProductID     INT NOT NULL,
    Quantity      INT NOT NULL,
    SubTotal      DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_orderdetails_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orderdetails_product
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_orderdetails_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_orderdetails_subtotal CHECK (SubTotal >= 0)
);

-- Insert at least 5 sample order-detail records.
-- SubTotal is Quantity multiplied by the product price at time of sale.
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, SubTotal) VALUES
(1, 1, 2, 1400.00),
(1, 2, 1, 1800.00),
(2, 3, 2, 1000.00),
(3, 4, 1, 1500.00),
(3, 1, 1, 700.00),
(4, 5, 1, 1200.00),
(5, 2, 2, 3600.00);

-- Query 1: Retrieve all order details for a specific order.
-- Example: OrderID = 1
SELECT *
FROM OrderDetails
WHERE OrderID = 1;

-- Query 2: Calculate total revenue generated from all orders using SUM().
SELECT SUM(SubTotal) AS TotalRevenue
FROM OrderDetails;

-- Query 3: Retrieve the top 3 most ordered products.
-- Ranking is based on total quantity sold, not just number of rows.
SELECT
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantityOrdered
FROM OrderDetails AS od
JOIN Products AS p ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalQuantityOrdered DESC
LIMIT 3;

-- Query 4: Count how many times a specific product has been sold using COUNT().
-- Example: ProductID = 1. COUNT(*) counts order-detail records.
SELECT
    p.ProductID,
    p.ProductName,
    COUNT(od.OrderDetailID) AS TimesSold
FROM Products AS p
LEFT JOIN OrderDetails AS od ON od.ProductID = p.ProductID
WHERE p.ProductID = 1
GROUP BY p.ProductID, p.ProductName;

-- Helpful extra query: View order details with customer and product names.
SELECT
    o.OrderID,
    c.Name AS CustomerName,
    o.OrderDate,
    p.ProductName,
    od.Quantity,
    od.SubTotal
FROM OrderDetails AS od
JOIN Orders AS o ON o.OrderID = od.OrderID
JOIN Customers AS c ON c.CustomerID = o.CustomerID
JOIN Products AS p ON p.ProductID = od.ProductID
ORDER BY o.OrderID, od.OrderDetailID;

-- Helpful extra query: Recalculate each order's total from its detail rows.
-- This updates orders using the current OrderDetails records.
UPDATE Orders AS o
JOIN (
    SELECT OrderID, SUM(SubTotal) AS CalculatedTotal
    FROM OrderDetails
    GROUP BY OrderID
) AS totals ON totals.OrderID = o.OrderID
SET o.TotalAmount = totals.CalculatedTotal;

-- Verify all four tables.
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM OrderDetails;

-- ============================================================
-- END OF DATA DIGGER PROJECT
-- Notes:
-- - UPDATE statements above are executable examples.
-- - DELETE examples are commented out so the full script can run
--   without removing records or causing foreign-key conflicts.
-- - To test a DELETE, remove the leading "-- " from that statement
--   and follow the foreign-key notes beside it.
-- ============================================================
