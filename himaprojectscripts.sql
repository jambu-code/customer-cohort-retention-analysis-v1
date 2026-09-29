create database HIMA;
use hima;
CREATE TABLE raw_sales_landing (
    InvoiceNo VARCHAR(100),
    StockCode VARCHAR(100),
    Description VARCHAR(255),
    Quantity VARCHAR(50),      
    InvoiceDate_Text VARCHAR(100),
    UnitPrice VARCHAR(50),     
    CustomerID VARCHAR(100),
    Country VARCHAR(100)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data.csv'
INTO TABLE raw_sales_landing
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate_Text, UnitPrice, CustomerID, Country);

SELECT COUNT(*) AS total_loaded_records FROM raw_sales_landing;
select * from raw_sales_landing

