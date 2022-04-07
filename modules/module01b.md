# Module 01B - Incremental Copy to Raw (via Watermark)

[< Previous Module](../modules/module01a.md) - **[Home](../README.md)** - [Next Module >](../modules/module02.md)

## :thinking: Prerequisites

* Lab environment deployed
* Post deployment scripts executed
* Module 1A (Linked Service, Integration Dataset)
* Access to the Azure Synapse Analytics workspace

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally copy data from an OLTP source (Azure SQL Database), leveraging a watermark value to isolate changes. The data will be copied to the raw layer of our Azure Data Lake Storage Gen2 account.

## :dart: Objectives

* Prepare source system to store and update a watermark value
* Create a Pipeline
* Copy data changes to the data lake

## 1. Source Environment (dbo.Orders)
1. Navigate to the **SQL database**
2. Click **Query editor**
3. Click **Continue us <your_alias>@<your_domain>.com**
4. To create the source table, copy and paste the code snippet below and click **Run**
```sql
CREATE TABLE Orders (
    OrderID int IDENTITY(1,1) PRIMARY KEY,
    CustomerID int FOREIGN KEY REFERENCES Customers(CustomerID),
    Quantity int NOT NULL,
    OrderDateTime DATETIME default CURRENT_TIMESTAMP,
    LastModifiedDateTime DATETIME default CURRENT_TIMESTAMP
);
INSERT INTO dbo.Orders (CustomerID, Quantity)
VALUES
    (1,38),
    (2,27),
    (3,16),
    (1,52);
```
5. To create a SQL trigger that will automatically update the LastModifiedDateTime colum on UPDATE, copy and paste the code snippet below and click **Run** 
```sql
CREATE TRIGGER trg_orders_update_modified
ON dbo.Orders
AFTER UPDATE 
AS
    UPDATE dbo.Orders
    SET LastModifiedDateTime = CURRENT_TIMESTAMP
    FROM Inserted i
    WHERE dbo.Orders.OrderID = i.OrderID;
```
6. To initialise the watermark table, copy and paste the code snippet below and click **Run**
```sql
CREATE TABLE Watermark (
    TableName varchar(255),
    Watermark DATETIME
);
INSERT INTO dbo.Watermark
VALUES
('dbo.Orders', '1/1/2022 12:00:00 AM');
```
7. To enable the ability to programmatically update the watermark value via a stored procedure, copy and paste the code snippet below and click **Run**
```sql
CREATE PROCEDURE sp_update_watermark @LastModifiedtime datetime, @TableName varchar(50)
AS
    UPDATE Watermark
    SET [Watermark] = @LastModifiedtime
    WHERE [TableName] = @TableName;
```

<div align="right"><a href="#module-01b---incremental-copy-to-raw-via-watermark">↥ back to top</a></div>

## 2. Pipeline (Lookup - getOldWatermark)

1. Navigate to the **Integrate** hub
2. Click the **[+]** icon to add a new resource and click **Pipeline**
3. Rename the pipeline to `pipelineIncrementalCopyWatermark`

<div align="right"><a href="#module-01b---incremental-copy-to-raw-via-watermark">↥ back to top</a></div>

## :tada: Summary

ABC.

[Continue >](../modules/module02.md)