/* 03 · Dimension tables
   Every dimension gets an IDENTITY surrogate key and a -1 "Unknown" member so fact rows
   with missing lookups still join. DIM_LOCATION is shared by stores, resellers and customers.
*/

--Second, create rest of the dimension tables

--DIM_LOCATION
CREATE OR REPLACE TABLE DIM_LOCATION (
    DimLocationID INT IDENTITY(1,1) CONSTRAINT PK_DimLocationID PRIMARY KEY NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(255) NOT NULL,
    PostalCode VARCHAR(255) NOT NULL,
    State_Province VARCHAR(255) NOT NULL,
    Country VARCHAR(255) NOT NULL
);

--Load unknown members
INSERT INTO DIM_LOCATION (
    DimLocationID,
    Address,
    City,
    PostalCode,
    State_Province,
    Country
)
VALUES (
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown'
);
--Load data from STAGING_STORE, STAGING_RESELLER, STAGING_CUSTOMER.
INSERT INTO DIM_LOCATION (
    Address,
    City,
    PostalCode,
    State_Province,
    Country
)
SELECT
    Address,
    City,
    PostalCode,
    StateProvince,
    Country
FROM STAGING_STORE
UNION
SELECT
    Address,
    City,
    PostalCode,
    StateProvince,
    Country
FROM STAGING_RESELLER
UNION
SELECT
    Address,
    City,
    PostalCode,
    StateProvince,
    Country
FROM STAGING_CUSTOMER;

--DIM_STORE
CREATE OR REPLACE TABLE DIM_STORE (
    DimStoreID INT IDENTITY(1,1) CONSTRAINT PK_DimStoreID PRIMARY KEY NOT NULL,
    DimLocationID INT NOT NULL,
    SourceStoreID INT NOT NULL,
    StoreName VARCHAR(255) NOT NULL,
    StoreNumber INT NOT NULL,
    StoreManager VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Store_Location FOREIGN KEY (DimLocationID) REFERENCES DIM_LOCATION(DimLocationID)
);

INSERT INTO DIM_STORE (
    DimStoreID,
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
)
VALUES (
    -1,
    -1,
    -1,
    'Unknown',
    -1,
    'Unknown'
);

INSERT INTO DIM_STORE (
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
)
SELECT
    COALESCE(L.DimLocationID, -1) AS DimLocationID,
    S.StoreID AS SourceStoreID,
    'Unknown' AS StoreName,
    S.StoreNumber,
    S.StoreManager
FROM STAGING_STORE S
LEFT JOIN DIM_LOCATION L
  ON S.Address = L.Address
 AND S.City = L.City
 AND S.PostalCode = L.PostalCode
 AND S.StateProvince = L.State_Province
 AND S.Country = L.Country;

--Source data do not contain the store name, run below code once it is updated.
/**
UPDATE DIM_STORE
SET StoreName = s.StoreName
FROM DIM_STORE ds
JOIN STAGING_STORE s ON ds.SourceStoreID = s.StoreID
WHERE ds.StoreName = 'Unknown'
**/

--DIM_RESELLER
CREATE OR REPLACE TABLE DIM_RESELLER (
    DimResellerID INT IDENTITY(1,1) CONSTRAINT PK_DimResellerID PRIMARY KEY NOT NULL,
    DimLocationID INT NOT NULL,
    ResellerID VARCHAR(255) NOT NULL,
    ResellerName VARCHAR(255) NOT NULL,
    ContactName VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Reseller_Location FOREIGN KEY (DimLocationID) REFERENCES DIM_LOCATION(DimLocationID)
);

INSERT INTO DIM_RESELLER (
    DimResellerID,
    DimLocationID,
    ResellerID,
    ResellerName,
    ContactName,
    PhoneNumber,
    Email
)
VALUES (
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown'
);

INSERT INTO DIM_RESELLER (
    DimLocationID,
    ResellerID,
    ResellerName,
    ContactName,
    PhoneNumber,
    Email
)
SELECT
    COALESCE(L.DimLocationID, -1) AS DimLocationID,
    R.ResellerID,
    R.ResellerName,
    R.Contact AS ContactName,
    R.PhoneNumber,
    R.EmailAddress AS Email
FROM STAGING_RESELLER R
LEFT JOIN DIM_LOCATION L
  ON R.Address = L.Address
 AND R.City = L.City
 AND R.PostalCode = L.PostalCode
 AND R.StateProvince = L.State_Province
 AND R.Country = L.Country;

--DIM_CUSTOMER
CREATE OR REPLACE TABLE DIM_CUSTOMER (
    DimCustomerID INT IDENTITY(1,1) CONSTRAINT PK_DimCustomerID PRIMARY KEY NOT NULL,
    DimLocationID INT NOT NULL,
    CustomerID VARCHAR(255) NOT NULL,
    CustomerFullName VARCHAR(255) NOT NULL,
    CustomerFirstName VARCHAR(255) NOT NULL,
    CustomerLastName VARCHAR(255) NOT NULL,
    CustomerGender VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Customer_Location FOREIGN KEY (DimLocationID) REFERENCES DIM_LOCATION(DimLocationID)
);

INSERT INTO DIM_CUSTOMER (
    DimCustomerID,
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerGender
)
VALUES (
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown'
);

INSERT INTO DIM_CUSTOMER (
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerGender
)
SELECT
    COALESCE(L.DimLocationID, -1) AS DimLocationID,
    C.CustomerID,
    C.FirstName|| ' ' ||C.LastName AS CustomerFullName,
    C.FirstName AS CustomerFirstName,
    C.LastName AS CustomerLastName,
    C.Gender AS CustomerGender
FROM STAGING_CUSTOMER C
LEFT JOIN DIM_LOCATION L
  ON C.Address = L.Address
 AND C.City = L.City
 AND C.PostalCode = L.PostalCode
 AND C.StateProvince = L.State_Province
 AND C.Country = L.Country;

--DIM_CHANNEL
CREATE OR REPLACE TABLE DIM_CHANNEL (
    DimChannelID INT IDENTITY(1,1) CONSTRAINT PK_DimChannelID PRIMARY KEY NOT NULL,
    ChannelID INT NOT NULL,
    ChannelCategoryID INT NOT NULL,
    ChannelName VARCHAR(255) NOT NULL,
    ChannelCategory VARCHAR(255) NOT NULL
);
INSERT INTO DIM_CHANNEL(
    DimChannelID,
    ChannelID,
    ChannelCategoryID,
    ChannelName,
    ChannelCategory
)
VALUES (
    -1,
    -1,
    -1,
    'Unknown',
    'Unknown'
);

INSERT INTO DIM_CHANNEL(
    ChannelID,
    ChannelCategoryID,
    ChannelName,
    ChannelCategory
)
SELECT
    CH.ChannelID,
    CH.ChannelCategoryID,
    CH.Channel AS ChannelName,
    CHC.ChannelCategory
FROM STAGING_CHANNEL CH
JOIN STAGING_CHANNELCATEGORY CHC
ON CH.ChannelCategoryID = CHC.ChannelCategoryID;

--DIM_PRODUCT

CREATE OR REPLACE TABLE DIM_PRODUCT (
    DimProductID INT IDENTITY(1,1) CONSTRAINT PK_DimProductID PRIMARY KEY NOT NULL,
    ProductID INT NOT NULL,
    ProductTypeID INT NOT NULL,
    ProductCategoryID INT NOT NULL,
    ProductName VARCHAR(255) NOT NULL,
    ProductType VARCHAR(255) NOT NULL,
    ProductCategory VARCHAR(255) NOT NULL,
    ProductRetailPrice FLOAT NOT NULL,
    ProductWholesalePrice FLOAT NOT NULL,
    ProductCost FLOAT NOT NULL,
    ProductRetailProfit FLOAT NOT NULL,
    ProductWholesaleUnitProfit FLOAT NOT NULL,
    ProductProfitMarginUnitPercent FLOAT NOT NULL
);
INSERT INTO DIM_PRODUCT (
    DimProductID,
    ProductID,
    ProductTypeID,
    ProductCategoryID,
    ProductName,
    ProductType,
    ProductCategory,
    ProductRetailPrice,
    ProductWholesalePrice,
    ProductCost,
    ProductRetailProfit,
    ProductWholesaleUnitProfit,
    ProductProfitMarginUnitPercent
)
VALUES (
    -1,
    -1,
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    0,
    0,
    0,
    0,
    0,
    0
);

INSERT INTO DIM_PRODUCT (
    ProductID,
    ProductTypeID,
    ProductCategoryID,
    ProductName,
    ProductType,
    ProductCategory,
    ProductRetailPrice,
    ProductWholesalePrice,
    ProductCost,
    ProductRetailProfit,
    ProductWholesaleUnitProfit,
    ProductProfitMarginUnitPercent
)
SELECT
    P.ProductID,
    P.ProductTypeID,
    PC.ProductCategoryID,
    P.Product AS ProductName,
    PT.ProductType,
    PC.ProductCategory,
    P.Price AS ProductRetailPrice,
    P.WholesalePrice AS ProductWholesalePrice,
    P.Cost AS ProductCost,
    P.Price - P.Cost AS RetailProfit,
    P.WholesalePrice - P.Cost AS WholesaleUnitProfit,
    CASE
        WHEN P.Price = 0 THEN 0
        ELSE (P.Price - P.Cost) / P.Price
    END AS ProfitMarginUnitPercent
FROM STAGING_PRODUCT P
JOIN STAGING_PRODUCTTYPE PT ON P.ProductTypeID = PT.ProductTypeID
JOIN STAGING_PRODUCTCATEGORY PC ON PT.ProductCategoryID = PC.ProductCategoryID;
