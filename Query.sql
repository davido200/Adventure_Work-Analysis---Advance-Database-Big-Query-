-- QUERY 1.1
 --CTE for CustomerInfo
  WITH
  CustomerInfo AS (
  SELECT
    individual.CustomerID,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.Firstname, ' ', contact.LastName) AS FullName,
     CASE
     WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title, ' ', contact.LastName)
     ELSE CONCAT('Dear ', contact.LastName) END AS addressingTitle,
    contact.EmailAddress,
    contact.Phone,
    Customer.AccountNumber,
    Customer.CustomerType,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    stateprovince.Name AS State,
    countryregion.Name AS Country
  FROM `tc-da-1.adwentureworks_db.individual` AS individual
  JOIN `tc-da-1.adwentureworks_db.contact` AS contact
  ON individual.ContactID = contact.ContactID
  JOIN`tc-da-1.adwentureworks_db.customer` AS Customer
  ON individual.CustomerID = Customer.CustomerID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` AS CustomerAddress
  ON Customer.CustomerID = CustomerAddress.CustomerID
  JOIN `tc-da-1.adwentureworks_db.address` AS address
  ON CustomerAddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
  ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` AS countryregion
  ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  WHERE Customer.CustomerType = 'I' ),

--CTE for SalesInfo
  SalesInfo AS (
  SELECT
    salesorder.CustomerID,
    COUNT(salesorder.SalesOrderID) AS NumberOfOrders,
    ROUND(SUM(salesorder.TotalDue),3) AS TotalAmountWithTax,
    MAX(salesorder.OrderDate) AS LastOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
  GROUP BY salesorder.CustomerID )
  
-- Main Query
SELECT
  CustomerInfo.*,
  salesInfo.*
FROM CustomerInfo AS CustomerInfo
JOIN SalesInfo AS salesInfo
ON CustomerInfo.CustomerId = salesInfo.CustomerId
ORDER BY salesInfo.TotalAmountWithTax DESC
LIMIT 200;

-- QUERY 1.2
--CTE latestOrderdate
WITH
  LatestOrderDate AS (
  SELECT
    MAX(OrderDate) AS MaxOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` ),
-- CTE for CustomerInfo
  CustomerInfo AS (
  SELECT
    individual.CustomerID,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.Firstname, ' ', contact.LastName) AS FullName,
    CASE
      WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title, ' ', contact.LastName)
      ELSE CONCAT('Dear ', contact.LastName) END AS AddressingTitle,
    contact.EmailAddress,
    contact.Phone,
    Customer.AccountNumber,
    Customer.CustomerType,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    stateprovince.Name AS State,
    countryregion.Name AS Country
  FROM `tc-da-1.adwentureworks_db.individual` AS individual
  JOIN `tc-da-1.adwentureworks_db.contact` AS contact
  ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customer` AS Customer
  ON individual.CustomerID = Customer.CustomerID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` AS CustomerAddress
  ON Customer.CustomerID = CustomerAddress.CustomerID
  JOIN `tc-da-1.adwentureworks_db.address` AS address
  ON CustomerAddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
  ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` AS countryregion
  ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  WHERE Customer.CustomerType = 'I' ),

    -- CTE for SalesInfo
  SalesInfo AS (
  SELECT
    salesorder.CustomerID,
    COUNT(salesorder.SalesOrderID) AS NumberOfOrders,
    ROUND(SUM(salesorder.TotalDue), 3) AS TotalAmountWithTax,
    MAX(salesorder.OrderDate) AS LastOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
  GROUP BY salesorder.CustomerID )
    -- Main Query
SELECT
  CustomerInfo.*,
  SalesInfo.*
FROM CustomerInfo
JOIN SalesInfo
ON CustomerInfo.CustomerID = SalesInfo.CustomerID
WHERE SalesInfo.LastOrderDate < TIMESTAMP(DATE_SUB(( SELECT MaxOrderDate 
                                                      FROM LatestOrderDate), INTERVAL 365 DAY)) 
ORDER BY SalesInfo.TotalAmountWithTax DESC
LIMIT 200;

-- QUERY 1.3
-- CTE for LatestOrderDate
WITH
  LatestOrderDate AS (
  SELECT
    MAX(OrderDate) AS MaxOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` ),
-- CTE for CustomerInfo
  CustomerInfo AS (
  SELECT
    individual.CustomerID,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.Firstname, ' ', contact.LastName) AS FullName,
    CASE
      WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title, ' ', contact.LastName)
      ELSE CONCAT('Dear ', contact.LastName)
  END
    AS AddressingTitle,
    contact.EmailAddress,
    contact.Phone,
    Customer.AccountNumber,
    Customer.CustomerType,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    stateprovince.Name AS State,
    countryregion.Name AS Country
  FROM `tc-da-1.adwentureworks_db.individual` AS individual
  JOIN `tc-da-1.adwentureworks_db.contact` AS contact
  ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customer` AS Customer
  ON individual.CustomerID = Customer.CustomerID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` AS CustomerAddress
  ON Customer.CustomerID = CustomerAddress.CustomerID
  JOIN `tc-da-1.adwentureworks_db.address` AS address
  ON CustomerAddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
  ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` AS countryregion
  ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  WHERE Customer.CustomerType = 'I' ),
  -- CTE for SalesInfo
  SalesInfo AS (
  SELECT
    salesorder.CustomerID,
    COUNT(salesorder.SalesOrderID) AS NumberOfOrders,
    ROUND(SUM(salesorder.TotalDue), 3) AS TotalAmountWithTax,
    MAX(salesorder.OrderDate) AS LastOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
  GROUP BY salesorder.CustomerID ),
-- CTE for CustomerInfoStatus
  CustomerInfoStatus AS (
  SELECT
    CustomerInfo.CustomerID,
    CustomerInfo.FirstName,
    CustomerInfo.LastName,
    CustomerInfo.FullName,
    CustomerInfo.AddressingTitle,
    CustomerInfo.EmailAddress,
    CustomerInfo.Phone,
    CustomerInfo.AccountNumber,
    CustomerInfo.CustomerType,
    CustomerInfo.City,
    CustomerInfo.AddressLine1,
    CustomerInfo.AddressLine2,
    CustomerInfo.State,
    CustomerInfo.Country,
    SalesInfo.NumberOfOrders,
    SalesInfo.TotalAmountWithTax,
    SalesInfo.LastOrderDate,
    CASE
      WHEN SalesInfo.LastOrderDate >= TIMESTAMP(DATE_SUB(( SELECT MaxOrderDate 
                                                          FROM LatestOrderDate), INTERVAL 365 DAY)) 
                                                          THEN 'Active' ELSE 'Inactive' END AS CustomerStatus
  FROM CustomerInfo
  JOIN SalesInfo
  ON CustomerInfo.CustomerID = SalesInfo.CustomerID )
SELECT
  CustomerID,
  FirstName,
  LastName,
  FullName,
  AddressingTitle,
  EmailAddress,
  Phone,
  AccountNumber,
  CustomerType,
  City,
  AddressLine1,
  AddressLine2,
  State,
  Country,
  NumberOfOrders,
  TotalAmountWithTax,
  LastOrderDate,
  CustomerStatus
FROM CustomerInfoStatus
ORDER BY CustomerID DESC
LIMIT 500;

-- QUERY 1.4
-- CTE for LatestOrderDate
WITH
  LatestOrderDate AS (
  SELECT
    MAX(OrderDate) AS MaxOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` 
  ),
-- CTE for CustomerInfo
  CustomerInfo AS (
  SELECT
    individual.CustomerID,
    contact.FirstName,
    contact.LastName,
    CONCAT(contact.Firstname, ' ', contact.LastName) AS FullName,
    CASE
      WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title, ' ', contact.LastName)
      ELSE CONCAT('Dear ', contact.LastName) END AS AddressingTitle,
    contact.EmailAddress,
    contact.Phone,
    Customer.AccountNumber,
    Customer.CustomerType,
    address.City,
    address.AddressLine1,

    -- Split AddressLine1
    SAFE_CAST(LEFT(address.AddressLine1, STRPOS(address.AddressLine1, ' ') - 1) AS INT64) AS address_no,
    TRIM(SUBSTR(address.AddressLine1, STRPOS(address.AddressLine1, ' ') + 1)) AS Address_st,
    address.AddressLine2,
    stateprovince.Name AS State,
    countryregion.Name AS Country,
    salesterritory.group AS Territory
  FROM `tc-da-1.adwentureworks_db.individual` AS individual
  JOIN `tc-da-1.adwentureworks_db.contact` AS contact
    ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customer` AS Customer
    ON individual.CustomerID = Customer.CustomerID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` AS CustomerAddress
    ON Customer.CustomerID = CustomerAddress.CustomerID
  JOIN `tc-da-1.adwentureworks_db.address` AS address
    ON CustomerAddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
    ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` AS countryregion
    ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  JOIN `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
    ON Customer.TerritoryID = salesterritory.TerritoryID
  WHERE Customer.CustomerType = 'I' AND salesterritory.group = 'North America'),

  -- CTE for SalesInfo
  SalesInfo AS (
  SELECT
    salesorder.CustomerID,
    COUNT(salesorder.SalesOrderID) AS NumberOfOrders,
    ROUND(SUM(salesorder.TotalDue), 3) AS TotalAmountWithTax,
    MAX(salesorder.OrderDate) AS LastOrderDate
  FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
  GROUP BY salesorder.CustomerID 
  ),
-- CTE for CustomerInfoStatus
  CustomerInfoStatus AS (
  SELECT
    CustomerInfo.CustomerID,
    CustomerInfo.FirstName,
    CustomerInfo.LastName,
    CustomerInfo.FullName,
    CustomerInfo.AddressingTitle,
    CustomerInfo.EmailAddress,
    CustomerInfo.Phone,
    CustomerInfo.AccountNumber,
    CustomerInfo.CustomerType,
    CustomerInfo.City,
    CustomerInfo.AddressLine1,
    CustomerInfo.address_no,  -- Added split columns
    CustomerInfo.Address_st,   -- Added split columns
    CustomerInfo.AddressLine2,
    CustomerInfo.State,
    CustomerInfo.Country,
    SalesInfo.NumberOfOrders,
    SalesInfo.TotalAmountWithTax,
    SalesInfo.LastOrderDate,
    CASE
      WHEN SalesInfo.LastOrderDate >= TIMESTAMP(DATE_SUB(( SELECT MaxOrderDate
                                                            FROM LatestOrderDate), INTERVAL 365 DAY)) 
                                                            THEN 'Active' ELSE 'Inactive' END AS CustomerStatus,
      CustomerInfo.Territory
  FROM CustomerInfo
  JOIN SalesInfo
    ON CustomerInfo.CustomerID = SalesInfo.CustomerID 
  )

  -- Main Query
SELECT
  CustomerID,
  FirstName,
  LastName,
  FullName,
  AddressingTitle,
  EmailAddress,
  Phone,
  AccountNumber,
  CustomerType,
  City,
  AddressLine1,
  address_no,  -- Include split columns in the output
  Address_st,   -- Include split columns in the output
  AddressLine2,
  State,
  Country,
  NumberOfOrders,
  TotalAmountWithTax,
  LastOrderDate,
  CustomerStatus,
  Territory
FROM CustomerInfoStatus
WHERE (CustomerStatus = 'Active' AND TotalAmountWithTax >= 2500 OR NumberOfOrders >= 5)
ORDER BY CustomerID DESC
LIMIT 500;

--QUERY 2.1
SELECT 
      LAST_DAY(DATE(salesorder.Orderdate), MONTH) AS order_month,
      salesterritory.CountryRegionCode AS CountryRegionCode ,
      salesterritory.name AS Region,
      COUNT(DISTINCT salesorder.SalesOrderID) AS Number_orders,
      COUNT(DISTINCT salesorder.CustomerID) AS Number_customers,
      COUNT(DISTINCT salesorder.SalesPersonID) AS No_salesperson,
      SUM(salesorder.TotalDue) AS Total_w_tax

FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
JOIN `tc-da-1.adwentureworks_db.customer` AS customer
ON salesorder.CustomerID = customer.CustomerID
JOIN `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
ON customer.TerritoryID = salesterritory.TerritoryID
LEFT JOIN `tc-da-1.adwentureworks_db.salesperson` AS salesperson
ON salesorder.SalesPersonID = salesperson.SalesPersonID

GROUP BY 
        order_month,
        CountryRegionCode,
        Region

-- QUERY 2.2
-- CTE for Orders
-- CTE for Orders
WITH Orders AS (
    SELECT 
        LAST_DAY(DATE(salesorder.Orderdate), MONTH) AS order_month,
        salesterritory.CountryRegionCode AS CountryRegionCode,
        salesterritory.name AS Region,
        COUNT(DISTINCT salesorder.SalesOrderID) AS Number_orders,
        COUNT(DISTINCT salesorder.CustomerID) AS Number_customers,
        COUNT(DISTINCT salesorder.SalesPersonID) AS No_salesperson,
        ROUND(SUM(salesorder.TotalDue)) AS Total_w_tax
    FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
    JOIN `tc-da-1.adwentureworks_db.customer` AS customer
        ON salesorder.CustomerID = customer.CustomerID
    JOIN `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
        ON customer.TerritoryID = salesterritory.TerritoryID
    LEFT JOIN `tc-da-1.adwentureworks_db.salesperson` AS salesperson
        ON salesorder.SalesPersonID = salesperson.SalesPersonID
    GROUP BY 
            order_month,
            CountryRegionCode,
            Region
),
-- CTE for Cumulative
Cumulative AS (
    SELECT 
        Orders.*, -- Select all the columns in CTE for Orders
        ROUND(SUM(Total_w_tax) OVER (PARTITION BY CountryRegionCode, Region ORDER BY order_month)) AS Cumulative_Total_w_tax
    FROM Orders
)
-- Main Query
SELECT 
    Cumulative.* --  Select all the columns in CTE for Cumulative
FROM Cumulative
ORDER BY CountryRegionCode, 
         Region, 
         order_month;


-- QUERY 2.3
-- CTE for Orders
-- CTE for Orders
WITH Orders AS (
    SELECT 
        LAST_DAY(DATE(salesorder.Orderdate), MONTH) AS order_month,
        salesterritory.CountryRegionCode AS CountryRegionCode,
        salesterritory.name AS Region,
        COUNT(DISTINCT salesorder.SalesOrderID) AS Number_orders,
        COUNT(DISTINCT salesorder.CustomerID) AS Number_customers,
        COUNT(DISTINCT salesorder.SalesPersonID) AS No_salesperson,
        ROUND(SUM(salesorder.TotalDue)) AS Total_w_tax
    FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
    JOIN `tc-da-1.adwentureworks_db.customer` AS customer
        ON salesorder.CustomerID = customer.CustomerID
    JOIN `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
        ON customer.TerritoryID = salesterritory.TerritoryID
    LEFT JOIN `tc-da-1.adwentureworks_db.salesperson` AS salesperson
        ON salesorder.SalesPersonID = salesperson.SalesPersonID
    GROUP BY 
        order_month,
        CountryRegionCode,
        Region
),
-- CTE for Cumulative
Cumulative AS (
    SELECT 
        Orders.*,  --  Select all the columns in CTE for Orders
        ROUND(SUM(Total_w_tax) OVER (PARTITION BY CountryRegionCode, Region ORDER BY order_month)) AS Cumulative_Total_w_tax
    FROM Orders
  
)
-- Main Query with Ranking
SELECT 
    Cumulative.*,  --  Select all the columns in CTE for Cumulative
    RANK() OVER (PARTITION BY CountryRegionCode, Region ORDER BY Total_w_tax DESC) AS sales_rank
FROM Cumulative
  WHERE Region = 'France' 
  --QUALIFY sales_rank = 2

ORDER BY CountryRegionCode, 
         Region, 
         order_month;


-- QUERY 2.4
-- CTE for Orders
WITH Orders AS (
    SELECT 
        LAST_DAY(DATE(salesorder.Orderdate), MONTH) AS order_month,
        salesterritory.CountryRegionCode AS CountryRegionCode,
        salesterritory.Name AS Region,
        COUNT(DISTINCT salesorder.SalesOrderID) AS Number_orders,
        COUNT(DISTINCT salesorder.CustomerID) AS Number_customers,
        COUNT(DISTINCT salesorder.SalesPersonID) AS No_salesperson,
        ROUND(SUM(salesorder.TotalDue)) AS Total_w_tax
    FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorder
    JOIN `tc-da-1.adwentureworks_db.customer` AS customer
        ON salesorder.CustomerID = customer.CustomerID
    JOIN `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
        ON customer.TerritoryID = salesterritory.TerritoryID
    LEFT JOIN `tc-da-1.adwentureworks_db.salesperson` AS salesperson
        ON salesorder.SalesPersonID = salesperson.SalesPersonID
    GROUP BY 
        order_month,
        CountryRegionCode,
        Region
),

-- CTE for Province Taxes
ProvinceTaxes AS (
    SELECT 
        stateprovince.CountryRegionCode,
        MAX(salestaxrate.TaxRate) AS TaxRate, -- Choosing the higher Tax
        stateprovince.StateProvinceID
    FROM `tc-da-1.adwentureworks_db.salestaxrate` AS salestaxrate
    JOIN `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
        ON salestaxrate.StateProvinceID = stateprovince.StateProvinceID
    GROUP BY stateprovince.CountryRegionCode, stateprovince.StateProvinceID
),

-- CTE for Country Taxes
CountryTaxes AS (
    SELECT 
        CountryRegionCode,
        ROUND(AVG(TaxRate), 2) AS mean_tax_rate,
        COUNT(DISTINCT StateProvinceID) AS Provinces_w_tax,
        (SELECT COUNT(DISTINCT StateProvinceID)
         FROM `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
         WHERE stateprovince.CountryRegionCode = ProvinceTaxes.CountryRegionCode) AS Total_provinces
    FROM ProvinceTaxes
    GROUP BY CountryRegionCode
),

-- CTE for Cumulative & perc_provinces_w_tax
Cumulative AS (
    SELECT 
        Orders.*,
        CountryTaxes.mean_tax_rate,
        ROUND(SUM(Orders.Total_w_tax) OVER (PARTITION BY Orders.CountryRegionCode, Orders.Region ORDER BY Orders.order_month))  
        AS Cumulative_Total_w_tax,
         ROUND(CountryTaxes.Provinces_w_tax / CountryTaxes.Total_provinces, 2) AS perc_provinces_w_tax
    FROM Orders
    JOIN CountryTaxes
        ON Orders.CountryRegionCode = CountryTaxes.CountryRegionCode
)

-- Main Query with Ranking
SELECT 
    Cumulative.*,
    RANK() OVER (PARTITION BY CountryRegionCode, Region ORDER BY Total_w_tax DESC) AS sales_rank
FROM Cumulative
WHERE CountryRegionCode = 'US' 
ORDER BY CountryRegionCode, 
         Region, 
         order_month
