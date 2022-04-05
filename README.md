# lakehouse

1. Lab Environment Setup Part 1 - Control Plane
    
    * Resource Group
    * Azure Synapse Analytics Workspace
    * Azure Data Lake Gen2 Storage Account
    * Azure SQL Database (serverless)
    * Event Grid Resource Provider

2. Lab Environment Setup Part 2 - Data Plane

    Azure SQL Database
    1. Create Tables (dbo.Customers, dbo.Orders), Trigger, Stored Procedure
    2. Enable CDC
    3. Populate initial records  

    Azure Data Lake Storage Gen2 Account
    1. Create Containers (01-raw, 02-enriched, 03-curated)
    2. Add yourself to the RBAC role Owner against the account
    
3. Incremental copy from an Azure SQL Database to Azure Data Lake Storage Gen2
    * dbo.Customers > raw\wwi\customers\file001.csv (via CDC)
    * dbo.Orders > raw\wwi\orders\file001.csv (via High Watermark)

4. Slowly Changing Dimension Type 2
    * raw\wwi\customers\file001.csv > curated\wwi\customers\file001.parquet (delta)

5. Incremental load Fact table
    * raw\wwi\oreders\file001.csv > curated\wwi\orders\file001.parquet (delta)

6. Logical Data Warehouse
    * Create Serverless SQL Database
    * Create Serverless SQL View

8. Power BI
    * Import Mode
    * Incremental Refresh