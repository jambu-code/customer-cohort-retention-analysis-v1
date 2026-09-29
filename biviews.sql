use hima
select * from fact_sales

CREATE OR REPLACE VIEW view_customer_cohorts AS
SELECT 
    CustomerID,
    MIN(InvoiceDate_text) AS FirstPurchaseDate,
    DATE_FORMAT(MIN(InvoiceDate_text), '%Y-%m-01') AS CohortMonth
FROM 
    fact_sales
WHERE 
    CustomerID IS NOT NULL
GROUP BY 
    CustomerID;


use hima
CREATE OR REPLACE VIEW view_retention_matrix AS
SELECT 
    s.CustomerID, -- Preserved for Power BI relationships
    c.CohortMonth,
    TIMESTAMPDIFF(MONTH, c.CohortMonth, DATE_FORMAT(s.InvoiceDate_text, '%Y-%m-01')) AS MonthIndex
FROM 
    fact_sales s
JOIN 
    view_customer_cohorts c ON s.CustomerID = c.CustomerID;




    
    CREATE OR REPLACE VIEW view_cohort_ltv AS
WITH CustomerTotalSpent AS (
    -- Calculates the total cumulative spent by each individual customer per month index
    SELECT 
        s.CustomerID,
        c.CohortMonth,
        TIMESTAMPDIFF(MONTH, c.CohortMonth, DATE_FORMAT(s.InvoiceDate_text, '%Y-%m-01')) AS MonthIndex,
        SUM(s.Quantity * s.UnitPrice) AS MonthlyRevenue
    FROM 
        fact_sales s
    JOIN 
        view_customer_cohorts c ON s.CustomerID = c.CustomerID
    GROUP BY 
        s.CustomerID, c.CohortMonth, 3
)
SELECT 
    CustomerID, -- Preserved for Power BI relationships
    CohortMonth,
    MonthIndex,
    MonthlyRevenue,
    -- Tracks running cumulative revenue for this specific customer
    SUM(MonthlyRevenue) OVER (PARTITION BY CustomerID ORDER BY MonthIndex) AS CumulativeRevenue
FROM 
    CustomerTotalSpent;

    
    
    
    
    
    
    
    CREATE OR REPLACE VIEW view_cohort_ltv AS
WITH MonthlySales AS (
    SELECT 
        c.CohortMonth,
        TIMESTAMPDIFF(MONTH, c.CohortMonth, DATE_FORMAT(s.InvoiceDate_text, '%Y-%m-01')) AS MonthIndex,
        SUM(s.Quantity * s.UnitPrice) AS MonthlyRevenue,
        COUNT(DISTINCT s.CustomerID) AS CohortSize
    FROM 
        fact_sales s
    JOIN 
        view_customer_cohorts c ON s.CustomerID = c.CustomerID
    GROUP BY 
        1, 2
)
SELECT 
    CohortMonth,
    MonthIndex,
    MonthlyRevenue,
    -- Calculates cumulative revenue moving forward across the months
    Sum(MonthlyRevenue)OVER (PARTITION BY CohortMonth ORDER BY MonthIndex) AS CumulativeRevenue,
    -- Average revenue generated per original cohort member
    SUM(MonthlyRevenue) OVER (PARTITION BY CohortMonth ORDER BY MonthIndex) / CohortSize AS CumulativeLTV
FROM 
    MonthlySales;




