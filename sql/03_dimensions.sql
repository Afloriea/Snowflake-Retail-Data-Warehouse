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
