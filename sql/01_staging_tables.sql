/* 01 · Staging layer
   Raw landing tables, one per source CSV. Column types mirror the source files; audit
   columns (Created/Modified) are kept as VARCHAR because the source mixes date formats.
*/

CREATE OR REPLACE TABLE STAGING_CHANNELCATEGORY (
    ChannelCategoryID INT PRIMARY KEY,
    ChannelCategory VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGING_CHANNEL (
    ChannelID INT PRIMARY KEY,
    ChannelCategoryID INT,
    Channel VARCHAR(255),
    CreatedDate DATETIME,
    CreatedBy VARCHAR(255),
    ModifiedDate DATETIME,
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (ChannelCategoryID) REFERENCES STAGING_CHANNELCATEGORY(ChannelCategoryID)
);

CREATE OR REPLACE TABLE STAGING_SEGMENT (
    SegmentID INT PRIMARY KEY,
    Segment VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGING_SUBSEGMENT (
    SubSegmentID INT PRIMARY KEY,
    SegmentID INT,
    SubSegment VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (SegmentID) REFERENCES STAGING_SEGMENT(SegmentID)
);

CREATE OR REPLACE TABLE STAGING_RESELLER (
    ResellerID VARCHAR(255) PRIMARY KEY,
    Contact VARCHAR(255),
    EmailAddress VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    StateProvince VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(255),
    PhoneNumber VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    ResellerName VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGING_STORE (
    StoreID INT PRIMARY KEY,
    SubSegmentID INT,
    StoreNumber INT,
    StoreManager VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    StateProvince VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(255),
    PhoneNumber VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (SubSegmentID) REFERENCES STAGING_SUBSEGMENT(SubSegmentID)
);

CREATE OR REPLACE TABLE STAGING_CUSTOMER (
    CustomerID VARCHAR(255) PRIMARY KEY,
    SubSegmentID INT,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Gender VARCHAR(50),
    EmailAddress VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    StateProvince VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(255),
    PhoneNumber VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (SubSegmentID) REFERENCES STAGING_SUBSEGMENT(SubSegmentID)
);

CREATE OR REPLACE TABLE STAGING_SALESHEADER (
    SalesHeaderID INT PRIMARY KEY,
    Date DATE,
    ChannelID INT,
    StoreID INT,
    CustomerID VARCHAR(255),
    ResellerID VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (ChannelID) REFERENCES STAGING_CHANNEL(ChannelID),
    FOREIGN KEY (StoreID) REFERENCES STAGING_STORE(StoreID),
    FOREIGN KEY (CustomerID) REFERENCES STAGING_CUSTOMER(CustomerID),
    FOREIGN KEY (ResellerID) REFERENCES STAGING_RESELLER(ResellerID)
);

CREATE OR REPLACE TABLE STAGING_PRODUCTCATEGORY (
    ProductCategoryID INT PRIMARY KEY,
    ProductCategory VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGING_PRODUCTTYPE (
    ProductTypeID INT PRIMARY KEY,
    ProductCategoryID INT,
    ProductType VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (ProductCategoryID) REFERENCES STAGING_PRODUCTCATEGORY(ProductCategoryID)
);

CREATE OR REPLACE TABLE STAGING_UNITOFMEASURE (
    UnitOfMeasureID INT PRIMARY KEY,
    UnitOfMeasure VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGING_PRODUCT (
    ProductID INT PRIMARY KEY,
    ProductTypeID INT,
    Product VARCHAR(255),
    Color VARCHAR(255),
    Style VARCHAR(255),
    UnitofMeasureID INT,
    Weight FLOAT,
    Price FLOAT,
    Cost FLOAT,
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    WholesalePrice FLOAT,
    FOREIGN KEY (ProductTypeID) REFERENCES STAGING_PRODUCTTYPE(ProductTypeID),
    FOREIGN KEY (UnitofMeasureID) REFERENCES STAGING_UNITOFMEASURE(UnitOfMeasureID)
);

CREATE OR REPLACE TABLE STAGING_SALESDETAIL (
    SalesDetailID INT PRIMARY KEY,
    SalesHeaderID INT,
    ProductID INT,
    SalesQuantity INT,
    SalesAmount FLOAT,
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    FOREIGN KEY (SalesHeaderID) REFERENCES STAGING_SALESHEADER(SalesHeaderID),
    FOREIGN KEY (ProductID) REFERENCES STAGING_PRODUCT(ProductID)
);

CREATE OR REPLACE TABLE STAGING_TARGET_CHANNEL_RESELLER_STORE (
    Year INT,
    ChannelName VARCHAR(255),
    TargetName VARCHAR(255),
    TargetSalesAmount FLOAT
);

CREATE OR REPLACE TABLE STAGING_TARGET_PRODUCT (
    ProductID INT,
    Product VARCHAR(255),
    Year INT,
    SalesQuantityTarget INT
);
