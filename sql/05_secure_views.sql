/* 05 · Data access layer
   Secure pass-through views over every dimension and fact. Tableau connects only to
   these, so the base tables can change without breaking the dashboard.
*/

--Create Pass-Through View for all dimension tables and fact tables

--DIM_DATE
CREATE SECURE VIEW V_DIM_DATE AS
SELECT
    DATE_PKEY,
    DATE,
    FULL_DATE_DESC,
    DAY_NUM_IN_WEEK,
    DAY_NUM_IN_MONTH,
    DAY_NUM_IN_YEAR,
    DAY_NAME,
    DAY_ABBREV,
    WEEKDAY_IND,
    US_HOLIDAY_IND,
    COMPANY_HOLIDAY_IND,
    MONTH_END_IND,
    WEEK_BEGIN_DATE_NKEY,
    WEEK_BEGIN_DATE,
    WEEK_END_DATE_NKEY,
    WEEK_END_DATE,
    WEEK_NUM_IN_YEAR,
    MONTH_NAME,
    MONTH_ABBREV,
    MONTH_NUM_IN_YEAR,
    YEARMONTH,
    QUARTER,
    YEARQUARTER,
    YEAR,
    FISCAL_WEEK_NUM,
    FISCAL_MONTH_NUM,
    FISCAL_YEARMONTH,
    FISCAL_QUARTER,
    FISCAL_YEARQUARTER,
    FISCAL_HALFYEAR,
    FISCAL_YEAR,
    SQL_TIMESTAMP,
    CURRENT_ROW_IND,
    EFFECTIVE_DATE,
    EXPIRATION_DATE
FROM DIM_DATE;

--DIM_LOCATION
CREATE SECURE VIEW V_DIM_LOCATION AS
SELECT
    DimLocationID,
    Address,
    City,
    PostalCode,
    State_Province,
    Country
FROM DIM_LOCATION;

--DIM_STORE
CREATE SECURE VIEW V_DIM_STORE AS
SELECT
    DimStoreID,
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
FROM DIM_STORE;

--DIM_RESELLER
CREATE SECURE VIEW V_DIM_RESELLER AS
SELECT
    DimResellerID,
    DimLocationID,
    ResellerID,
    ResellerName,
    ContactName,
    PhoneNumber,
    Email
FROM DIM_RESELLER;

--DIM_CUSTOMER
CREATE SECURE VIEW V_DIM_CUSTOMER AS
SELECT
    DimCustomerID,
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerGender
FROM DIM_CUSTOMER;

--DIM_CHANNEL
CREATE SECURE VIEW V_DIM_CHANNEL AS
SELECT
    DimChannelID,
    ChannelID,
    ChannelCategoryID,
    ChannelName,
    ChannelCategory
FROM DIM_CHANNEL;

--DIM_PRODUCT
CREATE SECURE VIEW V_DIM_PRODUCT AS
SELECT
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
FROM DIM_PRODUCT;

--FACT_SRCSalesTarget
CREATE SECURE VIEW V_FACT_SRCSalesTarget AS
SELECT
    DimStoreID,
    DimResellerID,
    DimChannelID,
    DimTargetDateID,
    SalesTargetAmount
FROM FACT_SRCSalesTarget;

--FACT_ProductSalesTarget
CREATE SECURE VIEW V_FACT_ProductSalesTarget AS
SELECT
    DimProductID,
    DimTargetDateID,
    ProductTargetSalesQuantity
FROM FACT_ProductSalesTarget;

--FACT_SalesActual
CREATE SECURE VIEW V_FACT_SalesActual AS
SELECT
    DimProductID,
    DimStoreID,
    DimResellerID,
    DimCustomerID,
    DimChannelID,
    DimSaleDateID,
    DimLocationID,
    SalesHeaderID,
    SalesDetailID,
    SaleAmount,
    SaleQuantity,
    SaleUnitPrice,
    SaleExtendedCost,
    SaleTotalProfit
FROM FACT_SalesActual;
