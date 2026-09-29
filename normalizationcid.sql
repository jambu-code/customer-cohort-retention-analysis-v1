
-- 1 THE AUDIT AND CLEANING PART
/*
SELECT * 
FROM him 
WHERE country LIKE '%United Kingdom%';
set sql_safe_updates=0;
UPDATE himi 
SET country = TRIM(REPLACE(REPLACE(country, '\r', ''), '\n', ''));*/

-- CREATING TABLES WITH AND WITHOUT EMPTY IDS
-- cnullID for tables without customerID and withcID for table with customerID

/*
create table cnullID
as select * from himi
where trim(customerid)=''

create table withcid
as select * from himi
where trim(customerid)!=''*/

-- 2 NORMALIZATION
-- creating dimention tables and fact table.Here created customers and products table 
-- as the only dimention tables the fact_sales as the central table


/*-- 2.1. Customer Dimension Table (Stores unique customers and their location)
CREATE TABLE customers (
    CustomerID INT PRIMARY KEY,
    Country VARCHAR(100)
);

-- 2.2 Product Dimension Table (Stores unique products and descriptions)
CREATE TABLE products (
    StockCode VARCHAR(100) PRIMARY KEY,
    Description VARCHAR(255)
);

-- 2.3 Sales Fact Table (Stores numeric, transactional values)
CREATE TABLE fact_sales (
    InvoiceNo VARCHAR(100),
    CustomerID INT,
    StockCode VARCHAR(100),
    Quantity INT,
    UnitPrice DECIMAL(20,7),
    InvoiceDate_text datetime
    ,
    -- Establish relationships
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (StockCode) REFERENCES products(StockCode)
);

-- populating the 2 created dimetion tables and fact table from table withcid
-- since the project is more about customer retention analysis we must use 
--only the rows with customerID


-- 2.1a  Insert unique customers only

-- Clear the table you have partial/failed data in it
TRUNCATE TABLE customers;
-- I realized that there is somecustomers who keeps shifting their location.
-- so here i used this CTE to collect the recent location as per the date
-- 2. Populate the table with exactly one unique customer ID and their latest country
INSERT INTO customers (CustomerID, Country)
WITH RankedCustomers AS (
    SELECT 
        CustomerID, 
        Country,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY InvoiceDate_text DESC) as rn
    FROM withcid
    WHERE CustomerID IS NOT NULL  -- Ensures you don't accidentally import blank IDs
)
SELECT CustomerID, Country
FROM RankedCustomers
WHERE rn = 1;


-- 2.3a Insert unique products
-- (Using MAX(Description) ensures we handle cases where a stock code has
-- slight text variations)
/*INSERT INTO products (StockCode, Description)
SELECT   StockCode,max(description)
FROM withcid
group by stockcode

-- testing
select  stockcode,description
from products
*/


INSERT INTO fact_sales (InvoiceNo, CustomerID, StockCode, Quantity, UnitPrice, InvoiceDate_text)
SELECT InvoiceNo, CustomerID, StockCode, Quantity, UnitPrice, InvoiceDate_text
FROM withcid;

