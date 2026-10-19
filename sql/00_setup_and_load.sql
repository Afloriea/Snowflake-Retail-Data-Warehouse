/* 00 · Setup and load
   Creates the database, a CSV file format and one stage per source file, then copies
   each CSV into its staging table (run 01_staging_tables.sql first).

   Source: 15 CSV extracts in Azure Blob Storage. SEGMENT was not in the blob container,
   so it uses an internal stage and the file is uploaded through the Snowflake UI.
   The stage and file-format definitions are written out here for reproducibility; the
   original build created them through the Snowflake UI.
   Replace <account>, <container> and <sas_token> before running.
*/

CREATE DATABASE IF NOT EXISTS RETAIL_DW;
USE DATABASE RETAIL_DW;

CREATE OR REPLACE FILE FORMAT my_csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE;

-- External stage per source file (same pattern for each)
CREATE OR REPLACE STAGE CHANNEL
    URL = 'azure://<account>.blob.core.windows.net/<container>/Channel/'
    CREDENTIALS = (AZURE_SAS_TOKEN = '<sas_token>')
    FILE_FORMAT = my_csv_format;

-- Internal stage: Segment.csv is uploaded manually
CREATE OR REPLACE STAGE SEGMENT;

-- Load
COPY INTO STAGING_CHANNEL
FROM @CHANNEL/Channel.csv
FILE_FORMAT = my_csv_format;

COPY INTO STAGING_SEGMENT
FROM @SEGMENT/Segment.csv
FILE_FORMAT = my_csv_format;

-- ...repeated for the remaining staging tables:
-- CHANNELCATEGORY, SUBSEGMENT, RESELLER, STORE, CUSTOMER, SALESHEADER, SALESDETAIL,
-- PRODUCTCATEGORY, PRODUCTTYPE, UNITOFMEASURE, PRODUCT,
-- TARGET_CHANNEL_RESELLER_STORE, TARGET_PRODUCT
