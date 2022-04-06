# Data Lakehouse Workshop

The data lakehouse is an open data architecture that combines the best of data warehouses and data lakes on one platform. This is made possible due to innovations with key technologies such as Delta Lake, so that capabilities previously isolated to the Data Warehouse can now be replicated within the Data Lake.

## :thinking: Prerequisites

* An [Azure account](https://azure.microsoft.com/en-us/free/) with an active subscription. Note: If you don't have access to an Azure subscription, you may be able to start with a [free account](https://www.azure.com/free).
* You must have the necessary privileges within your Azure subscription to create resources, perform role assignments, register resource providers (if required), etc.

## :test_tube: Lab Environment Setup
* [Lab Environment](./modules/module00.md)
* [Post Deployment](./modules/moduleXX.md)

## :books: Learning Modules

1. [TitleA](./modules/module01.md)
2. [TitleB](./modules/module02.md)
3. [TitleC](./modules/module03.md)

<div align="right"><a href="#data-lakehouse-workshop">↥ back to top</a></div>

## :link: Workshop URL

[aka.ms/lakehouselab](https://aka.ms/lakehouselab)


    
3. Incremental copy from an Azure SQL Database to Azure Data Lake Storage Gen2
    * dbo.Customers > raw\wwi\customers\file001.csv (via CDC)
    * dbo.Orders > raw\wwi\orders\file001.csv (via High Watermark)

4. Slowly Changing Dimension Type 2
    * raw\wwi\customers\file001.csv > curated\wwi\customers\file001.parquet (delta)

5. Incremental load Fact table
    * raw\wwi\orders\file001.csv > curated\wwi\orders\file001.parquet (delta)

6. Logical Data Warehouse
    * Create Serverless SQL Database
    * Create Serverless SQL View

8. Power BI
    * Import Mode
    * Incremental Refresh