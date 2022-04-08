# Module 01B - Incremental Copy to Raw (via Watermark)

[< Previous Module](../modules/module01a.md) - **[Home](../README.md)** - [Next Module >](../modules/module02.md)

## :thinking: Prerequisites

* Lab environment deployed
* Post deployment scripts executed
* Module 1A (Linked Service, Integration Datasets)
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
4. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas
5. Rename the activity `getOldWatermark`
6. Switch to the **Settings** tab
7. Set the **Source dataset** to **AzureSqlTable**
8. Set the Dataset property **schema** to `dbo`
9. Set the Dataset property **table** to `watermark`
10. Set the **Use query** property to **Query**
11. Click inside the **Query** text and copy and paste the code snippet
```sql
SELECT * FROM Watermark WHERE TableName = 'dbo.Orders'
```
12. Click **Preview data** to confirm the query is valid

<div align="right"><a href="#module-01b---incremental-copy-to-raw-via-watermark">↥ back to top</a></div>

## 3. Pipeline (Lookup - getNewWatermark)

1. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas
2. Rename the activity `getNewWatermark`
3. Switch to the **Settings** tab
4. Set the **Source dataset** to **AzureSqlTable**
5. Set the Dataset property **schema** to `dbo`
6. Set the Dataset property **table** to `Orders`
7. Set the **Use query** property to **Query**
8. Click inside the **Query** text and copy and paste the code snippet
```sql
SELECT MAX(LastModifiedDateTime) as NewWatermarkValue FROM dbo.Orders
```
12. Click **Preview data** to confirm the query is valid

<div align="right"><a href="#module-01b---incremental-copy-to-raw-via-watermark">↥ back to top</a></div>

## 4. Pipeline (Copy data)

1. Within Activities, search for `Copy`, and drag the **Copy data activity** onto the canvas
2. Rename the activity `incrementalCopy`
3. Click and drag on the green button from each **Lookup** activity to establish a connection to the **Copy data** activity
4. Switch to the **Source** tab
5. Set the **Source dataset** to **AzureSqlTable**
6. Under **Dataset properties**, set the **schema** to `dbo`
7. Under **Dataset properties**, set the **table** to `Orders`
8. Set **Use query** to **Query**
9. Click inside the **Query** text input and click **Add dynamic content**
10. Copy and paste the code snippet
```
SELECT * FROM dbo.Orders WHERE LastModifiedDateTime > '@{activity('getOldWatermark').output.firstRow.Watermark}' and LastModifiedDateTime <= '@{activity('getNewWatermark').output.firstRow.NewWatermarkValue}'
```
11. Click **OK**
12. Switch to the **Sink** tab
13. Set the **Source dataset** to **AdlsRawDelimitedText**
14. Under **Dataset properties**, set the **folderPath** to `wwi/orders`
15. Under **Dataset properties**, click inside the **fileName** text input and click **Add dynamic content**
16. Copy and paste the code snippet
```
@concat(formatDateTime(pipeline().TriggerTime,'yyyyMMddHHmmssfff'),'.csv')
```

<div align="right"><a href="#module-01b---incremental-copy-to-raw-via-watermark">↥ back to top</a></div>

## 5. Pipeline (Stored procedure)

1. Within Activities, search for `Stored`, and drag the **Stored procedure activity** onto the canvas
2. Rename the activity `updateWatermark`
3. Click and drag on the green button from the **Copy data** activity to establish a connection to the **Stored procedure** activity
4. Switch to the **Settings** tab
5. Set the **Linked service** to **AzureSqlDatabase**
6. Set the Stored procedure name to `sp_update_watermark`
7. Under **Stored procedure parameters**, click **Import**
8. Click inside the **LastModifiedTime** value text input and click **Add dynamic content**
9. Copy and paste the code snippet
```
@{activity('getNewWatermark').output.firstRow.NewWatermarkValue}
```
10. Click inside the **TableName** value text input and click **Add dynamic content**
11. Copy and paste the code snippet
```
@{activity('getOldWatermark').output.firstRow.TableName}
```
12. Click **Publish all**
13. Click **Publish**
14. Click **Debug**

<div align="right"><a href="#module-01b---incremental-copy-to-raw-via-watermark">↥ back to top</a></div>

## :tada: Summary

ABC.

[Continue >](../modules/module02.md)