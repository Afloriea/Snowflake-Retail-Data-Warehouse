/* 04 · Fact tables
   Three facts at different grains: actual sales (one row per sales-detail line),
   store/reseller sales targets and product quantity targets (annual targets keyed to each day of the year).
*/

--Create Fact Tables
DROP TABLE FACT_SRCSalesTarget
CREATE OR REPLACE TABLE FACT_SRCSalesTarget (
    DimStoreID INT CONSTRAINT FK_StoreID FOREIGN KEY REFERENCES DIM_STORE(DimStoreID),
    DimResellerID INT CONSTRAINT FK_ResellerID FOREIGN KEY REFERENCES DIM_RESELLER(DimResellerID),
    DimChannelID INT CONSTRAINT FK_ChannelID FOREIGN KEY REFERENCES DIM_CHANNEL(DimChannelID),
    DimTargetDateID NUMBER(9) CONSTRAINT FK_TargetDateID FOREIGN KEY REFERENCES DIM_DATE(DATE_PKEY),
    SalesTargetAmount FLOAT
);

CREATE OR REPLACE TABLE FACT_ProductSalesTarget (
    DimProductID INT CONSTRAINT FK_ProductID FOREIGN KEY REFERENCES DIM_PRODUCT(DimProductID),
    DimTargetDateID NUMBER(9) CONSTRAINT FK_DateID FOREIGN KEY REFERENCES DIM_DATE(DATE_PKEY),
    ProductTargetSalesQuantity INT
);

CREATE OR REPLACE TABLE FACT_SalesActual (
    DimProductID INT CONSTRAINT FK_ProductID FOREIGN KEY REFERENCES DIM_PRODUCT(DimProductID),
    DimStoreID INT CONSTRAINT FK_StoreID FOREIGN KEY REFERENCES DIM_STORE(DimStoreID),
    DimResellerID INT CONSTRAINT FK_ResellerID FOREIGN KEY REFERENCES DIM_RESELLER(DimResellerID),
    DimCustomerID INT CONSTRAINT FK_CustomerID FOREIGN KEY REFERENCES DIM_CUSTOMER(DimCustomerID),
    DimChannelID INT CONSTRAINT FK_ChannelID FOREIGN KEY REFERENCES DIM_CHANNEL(DimChannelID),
    DimSaleDateID NUMBER(9) CONSTRAINT FK_SaleDateID FOREIGN KEY REFERENCES DIM_DATE(DATE_PKEY),
    DimLocationID INT CONSTRAINT FK_LocationID FOREIGN KEY REFERENCES DIM_LOCATION(DimLocationID),
    SalesHeaderID INT,
    SalesDetailID INT,
    SaleAmount FLOAT,
    SaleQuantity INT,
    SaleUnitPrice FLOAT,
    SaleExtendedCost FLOAT,
    SaleTotalProfit FLOAT
);

--Before inserting data into the fact table, we need to update data, ensuring data across tables are aligned in order to complete the task smoothly.

--Update StoreNmae from DIM_STORE
UPDATE DIM_STORE
SET StoreName = 'Store Number ' || StoreNumber
WHERE StoreName = 'Unknown'
  AND StoreNumber != -1;

--Update Channel Name from DIM_CHANNEL
UPDATE DIM_CHANNEL
SET ChannelName = 'Online'
WHERE ChannelName = 'On-line';

--Insert Data to FACT_SRCSalesTarget
TRUNCATE TABLE FACT_SRCSalesTarget;

INSERT INTO FACT_SRCSalesTarget (
    DimStoreID,
    DimResellerID,
    DimChannelID,
    DimTargetDateID,
    SalesTargetAmount
)
SELECT DISTINCT
    COALESCE(S.DimStoreID, -1),
    COALESCE(R.DimResellerID, -1),
    C.DimChannelID,
    D.DATE_PKEY AS DimTargetDateID,
    T.TargetSalesAmount AS SalesTargetAmount
FROM STAGING_TARGET_CHANNEL_RESELLER_STORE T
LEFT JOIN DIM_STORE S ON T.TargetName = S.StoreName
LEFT JOIN DIM_RESELLER R ON T.TargetName = R.ResellerName
JOIN DIM_CHANNEL C ON T.ChannelName = C.ChannelName
JOIN DIM_DATE D ON D.YEAR = T.Year;

SELECT COUNT(*) FROM FACT_SRCSalesTarget;
--Check for Null Values
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN DimStoreID IS NULL THEN 1 ELSE 0 END) AS null_dimstoreid,
    SUM(CASE WHEN DimResellerID IS NULL THEN 1 ELSE 0 END) AS null_dimresellerid,
    SUM(CASE WHEN DimChannelID IS NULL THEN 1 ELSE 0 END) AS null_dimchannelid,
    SUM(CASE WHEN DimTargetDateID IS NULL THEN 1 ELSE 0 END) AS null_dimtargetid,
    SUM(CASE WHEN SalesTargetAmount IS NULL THEN 1 ELSE 0 END) AS null_salestargtamount
FROM FACT_SRCSALESTARGET

--Insert data to FACT_ProductSalesTarget
INSERT INTO FACT_ProductSalesTarget (
    DimProductID,
    DimTargetDateID,
    ProductTargetSalesQuantity
)
SELECT DISTINCT
    P.DimProductID,
    D.DATE_PKEY AS DimTargetDateID,
    T.SalesQuantityTarget AS ProductTargetSalesQuantity
FROM STAGING_TARGET_PRODUCT T
JOIN DIM_PRODUCT P ON T.ProductID = P.ProductID
JOIN DIM_DATE D ON D.YEAR = T.Year
WHERE T.SalesQuantityTarget IS NOT NULL;

--Check for null values
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN DimProductID IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN DimTargetDateID IS NULL THEN 1 ELSE 0 END) AS null_target_date_id,
  SUM(CASE WHEN ProductTargetSalesQuantity IS NULL THEN 1 ELSE 0 END) AS null_sales_quantity
FROM FACT_ProductSalesTarget;
