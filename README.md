# Data Digger 🗄️

An e-commerce database project built in **MySQL 8.0+**, practising **CRUD operations, JOINs and aggregate functions** on a realistic four-table schema.

---

## 📌 Project Overview

Data Digger models a simple online store: customers place orders, and each order contains one or more products. The script creates the database, tables, sample data, and a set of queries covering the most common SQL operations.

## 🧱 Database Schema

| Table | Columns | Purpose |
|---|---|---|
| **Customers** | `CustomerID` (PK), `Name`, `Email` (UNIQUE), `Address` | Stores customer details |
| **Orders** | `OrderID` (PK), `CustomerID` (FK), `OrderDate`, `TotalAmount` | One row per order placed |
| **Products** | `ProductID` (PK), `ProductName`, `Price`, `Stock` | Product catalogue |
| **OrderDetails** | `OrderDetailID` (PK), `OrderID` (FK), `ProductID` (FK), `Quantity`, `SubTotal` | Line items of each order |

### Relationships

```
Customers (1) ────< Orders (1) ────< OrderDetails >──── (1) Products
```

- One customer can have many orders.
- One order can have many order-detail rows.
- One product can appear in many order-detail rows.

### Constraints Used

- `PRIMARY KEY` with `AUTO_INCREMENT` on all tables
- `UNIQUE` on `Customers.Email`
- `FOREIGN KEY ... ON UPDATE CASCADE ON DELETE RESTRICT`
- `CHECK` constraints: `Price >= 0`, `Stock >= 0`, `Quantity > 0`, `SubTotal >= 0`
- `DEFAULT` values for `TotalAmount` and `Stock`

## 🚀 How to Run

**Requirements:** MySQL 8.0 or higher (needed for `CHECK` constraints) and any client such as MySQL Workbench, DBeaver or the `mysql` CLI.

**Using the command line:**

```bash
mysql -u root -p < Data_Digger_MySQL1_Project.sql
```

**Using MySQL Workbench:**

1. Open the `.sql` file.
2. Click the ⚡ **Execute** button.
3. Check the result tabs for each query.

> ⚠️ The script runs `DROP TABLE IF EXISTS` on all four tables, so re-running it resets the data.

## 🔍 Queries Included

### Customers
- Retrieve all customers
- Update a customer's address
- Find customers by name
- Delete a customer by `CustomerID` *(commented out)*

### Orders
- Retrieve all orders of a specific customer
- Update an order's total amount
- Orders placed in the last 30 days
- Highest, lowest and average order amount (`MAX`, `MIN`, `AVG`)
- Delete an order by `OrderID` *(commented out)*

### Products
- All products sorted by price (descending)
- Update a product's price
- Products priced between ₹500 and ₹2000 (`BETWEEN`)
- Most expensive and cheapest product
- Delete out-of-stock products *(commented out)*

### OrderDetails
- All details of a specific order
- Total revenue using `SUM()`
- Top 3 most ordered products (by total quantity)
- Number of times a product was sold using `COUNT()`
- Full order report joining **4 tables** (customer, order, product, details)
- Recalculate each order's total from its detail rows

## 🧠 Concepts Covered

| Concept | Where it is used |
|---|---|
| `CREATE`, `INSERT`, `UPDATE`, `DELETE`, `SELECT` | All sections |
| `WHERE`, `ORDER BY`, `LIMIT`, `BETWEEN` | Filtering and sorting |
| `INNER JOIN` / `LEFT JOIN` | Top products, times sold, full order report |
| `GROUP BY` | Product-wise quantity and sales count |
| `SUM`, `COUNT`, `MAX`, `MIN`, `AVG` | Revenue and statistics |
| Subqueries | Highest and lowest priced product |
| `UPDATE ... JOIN` | Recalculating order totals |
| Date functions (`CURDATE()`, `INTERVAL`) | Last-30-days orders |

## 📝 Notes

- `DELETE` statements are **commented out** to protect sample data and avoid foreign-key errors. To test one, remove the leading `-- `. If the row is referenced elsewhere, delete the child rows (`OrderDetails`, then `Orders`) first.
- Order dates use `CURDATE()`, so the "last 30 days" query always returns meaningful results.
- `SubTotal` stores quantity × price **at the time of sale**, so later price changes do not alter past orders.

## 📂 Project Structure

```
Data-Digger/
├── Data_Digger_MySQL1_Project.sql   # Schema, sample data and all queries
└── README.md                        # Project documentation
```

## 🛠️ Tech Stack

- **Database:** MySQL 8.0+
- **Language:** SQL

---

⭐ Built as a hands-on practice project for learning MySQL fundamentals.
