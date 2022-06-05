# Module 02A - Incremental Copy to Raw (using High Watermark)

[< Previous Module](../modules/module01d.md) - **[Home](../README.md)** - [Next Module >](../modules/module02b.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1A (Linked Service, Integration Datasets)

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally copy data from an OLTP source (Azure SQL Database), leveraging a watermark value to isolate changes. The data will be copied to the raw layer of our Azure Data Lake Storage Gen2 account.

## :dart: Objectives

- Prepare source system to store and update a watermark value
- Create a Pipeline
- Copy data changes to the data lake

## Table of Contents

1. [Source Environment (dbo.Orders)](#1-Source-Environment-dboOrders)
2. [Pipeline (Lookup - getOldWatermark)](#2-Pipeline-Lookup---getOldWatermark)
3. [Pipeline (Lookup - getNewWatermark)](#3-Pipeline-Lookup---getNewWatermark)
4. [Pipeline (Lookup - getChangeCount)](#4-Pipeline-Lookup---getChangeCount)
5. [Pipeline (If Condition)](#5-Pipeline-If-Condition)
6. [Pipeline (Copy data)](#6-Pipeline-Copy-data)
7. [Pipeline (Stored procedure)](#7-Pipeline-Stored-procedure)

## 1. Source Environment (dbo.Orders)

1. Navigate to the **SQL database**

    ![ALT](../images/module02a/001.png)

2. Click **Query editor**

    ![ALT](../images/module02a/002.png)

3. Click **Continue us <your_alias>@<your_domain>.com**

    ![ALT](../images/module02a/003.png)

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

    ![ALT](../images/module02a/004.png)

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

    ![ALT](../images/module02a/005.png)

6. To initialize the watermark table, copy and paste the code snippet below and click **Run**

    ```sql
    CREATE TABLE Watermark (
        TableName varchar(255),
        Watermark DATETIME
    );
    INSERT INTO dbo.Watermark
    VALUES
    ('dbo.Orders', '1/1/2022 12:00:00 AM');
    ```

    ![ALT](../images/module02a/006.png)

7. To enable the ability to programmatically update the watermark value via a stored procedure, copy and paste the code snippet below and click **Run**

    ```sql
    CREATE PROCEDURE sp_update_watermark @LastModifiedDateTime datetime, @TableName varchar(50)
    AS
        UPDATE Watermark
        SET [Watermark] = @LastModifiedDateTime
        WHERE [TableName] = @TableName;
    ```

    ![ALT](../images/module02a/007.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## 2. Pipeline (Lookup - getOldWatermark)

1. Navigate to the **Synapse workspace**

    ![ALT](../images/module02a/008.png)

2. Open **Synapse Studio**

    ![ALT](../images/module02a/009.png)

3. Navigate to the **Integrate** hub

    ![ALT](../images/module02a/010.png)

4. On the right hand side of **Pipelines**, click the **[...]** ellipsis icon and select **New folder**

    ![ALT](../images/module02a/011.png)

5. Name the folder `Orders` and click **Create**

    ![ALT](../images/module02a/012.png)

6. On the right hand side of the **Orders** folder, click the **[...]** ellipsis icon and select **New pipeline**

    ![ALT](../images/module02a/013.png)

7. Rename the pipeline to `O1 - pipelineIncrementalCopyWatermark`

    ![ALT](../images/module02a/014.png)

8. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas

    ![ALT](../images/module02a/015.png)

9. Rename the activity `getOldWatermark`

    ![ALT](../images/module02a/016.png)

10. Switch to the **Settings** tab and set the **Source dataset** to **AzureSqlTable**

    ![ALT](../images/module02a/017.png)

11. Set the Dataset property **schema** to `dbo`

    ![ALT](../images/module02a/018.png)

12. Set the Dataset property **table** to `Watermark`

    ![ALT](../images/module02a/019.png)

13. Set the **Use query** property to **Query**, click inside the **Query** text, and copy and paste the code snippet

    ```sql
    SELECT * FROM Watermark WHERE TableName = 'dbo.Orders'
    ```

    ![ALT](../images/module02a/020.png)

14. Click **Preview data** to confirm the query is valid

    ![ALT](../images/module02a/021.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## 3. Pipeline (Lookup - getNewWatermark)

1. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas

    ![ALT](../images/module02a/022.png)

2. Rename the activity `getNewWatermark`

    ![ALT](../images/module02a/023.png)

3. Switch to the **Settings** tab and set the **Source dataset** to **AzureSqlTable**

    ![ALT](../images/module02a/024.png)

4. Set the Dataset property **schema** to `dbo`

    ![ALT](../images/module02a/025.png)

5. Set the Dataset property **table** to `Orders`

    ![ALT](../images/module02a/026.png)

6. Set the **Use query** property to **Query**, click inside the **Query** text, and copy and paste the code snippet

    ```sql
    SELECT MAX(LastModifiedDateTime) as NewWatermarkValue FROM dbo.Orders
    ```

    ![ALT](../images/module02a/027.png)

7. Click **Preview data** to confirm the query is valid

    ![ALT](../images/module02a/028.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## 4. Pipeline (Lookup - getChangeCount)

1. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas

    ![ALT](../images/module02a/029.png)

2. Rename the activity `getChangeCount`

    ![ALT](../images/module02a/030.png)

3. Click and drag on the green button from each **Lookup** activity (`getOldWatermark` and `getNewWatermark`) to establish a connection to the new **Lookup** activity (`getChangeCount`)

    ![ALT](../images/module02a/031.png)

4. Switch to the **Settings** tab and set the **Source dataset** to **AzureSqlTable**

    ![ALT](../images/module02a/032.png)

5. Set the Dataset property **schema** to `dbo`

    ![ALT](../images/module02a/033.png)

6. Set the Dataset property **table** to `Orders`

    ![ALT](../images/module02a/034.png)

7. Set the **Use query** property to **Query**, click inside the **Query** text, and copy and paste the code snippet

    ```sql
    SELECT COUNT(*) as changecount FROM dbo.Orders WHERE LastModifiedDateTime > '@{activity('getOldWatermark').output.firstRow.Watermark}' and LastModifiedDateTime <= '@{activity('getNewWatermark').output.firstRow.NewWatermarkValue}'
    ```

    ![ALT](../images/module02a/035.png)

8. Click **Debug**

    ![ALT](../images/module02a/036.png)

9. Once the pipeline has finished running, under **Output**, hover your mouse over the `getChangeCount` activity and click the **Output** icon. You should see a `changecount` property with a value of `4`.

    ![ALT](../images/module02a/037.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## 5. Pipeline (If Condition)

1. Within Activities, search for `If`, and drag the **If condition activity** onto the canvas

    ![ALT](../images/module02a/038.png)

2. Rename the activity `hasChangedRows`

    ![ALT](../images/module02a/039.png)

3. Click and drag on the green button on the previous **Lookup** activity (`getChangeCount`) to establish a connection to the **If Condition** activity

    ![ALT](../images/module02a/040.png)

4. Switch to the **Activities** tab, click inside the **Expression** text input, and click **Add dynamic content**

    ![ALT](../images/module02a/041.png)

5. Copy and paste the code snippet and click **OK**

    ```javascript
    @greater(int(activity('getChangeCount').output.firstRow.changecount),0)
    ```

    ![ALT](../images/module02a/042.png)

6. Within the **True** case, click the **pencil** icon

    ![ALT](../images/module02a/043.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## 6. Pipeline (Copy data)

1. Within Activities, search for `Copy`, and drag the **Copy data activity** onto the canvas

    ![ALT](../images/module02a/044.png)

2. Rename the activity `incrementalCopy`

    ![ALT](../images/module02a/045.png)

3. Switch to the **Source** tab and set the **Source dataset** to **AzureSqlTable**

    ![ALT](../images/module02a/046.png)

4. Under **Dataset properties**, set the **schema** to `dbo`

    ![ALT](../images/module02a/047.png)

5. Under **Dataset properties**, set the **table** to `Orders`

    ![ALT](../images/module02a/048.png)

6. Set **Use query** to **Query**, click inside the **Query** text input, and click **Add dynamic content**

    ![ALT](../images/module02a/049.png)

7. Copy and paste the code snippet and click **OK**

    ```sql
    SELECT * FROM dbo.Orders WHERE LastModifiedDateTime > '@{activity('getOldWatermark').output.firstRow.Watermark}' and LastModifiedDateTime <= '@{activity('getNewWatermark').output.firstRow.NewWatermarkValue}'
    ```

    ![ALT](../images/module02a/050.png)

8. Switch to the **Sink** tab and set the **Source dataset** to **AdlsRawDelimitedText**

    ![ALT](../images/module02a/051.png)

9. Under **Dataset properties**, set the **folderPath** to `wwi/orders`

    ![ALT](../images/module02a/052.png)

10. Under **Dataset properties**, click inside the **fileName** text input and click **Add dynamic content**

    ![ALT](../images/module02a/053.png)

11. Copy and paste the code snippet and click **OK**

    ```javascript
    @concat(formatDateTime(pipeline().TriggerTime,'yyyyMMddHHmmssfff'),'.csv')
    ```

    ![ALT](../images/module02a/054.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## 7. Pipeline (Stored procedure)

1. Within Activities, search for `Stored`, and drag the **Stored procedure activity** onto the canvas

    ![ALT](../images/module02a/055.png)

2. Rename the activity `updateWatermark`

    ![ALT](../images/module02a/056.png)

3. Click and drag on the green button from the **Copy data** activity to establish a connection to the **Stored procedure** activity

    ![ALT](../images/module02a/057.png)

4. Switch to the **Settings** tab and set the **Linked service** to **AzureSqlDatabase**

    ![ALT](../images/module02a/058.png)

5. Set the Stored procedure name to `[dbo].[sp_update_watermark]`

    ![ALT](../images/module02a/059.png)

6. Under **Stored procedure parameters**, click **Import**

    ![ALT](../images/module02a/060.png)

7. Click inside the **LastModifiedDateTime** value text input and click **Add dynamic content**

    ![ALT](../images/module02a/061.png)

8. Copy and paste the code snippet and click **OK**

    ```javascript
    @{activity('getNewWatermark').output.firstRow.NewWatermarkValue}
    ```

    ![ALT](../images/module02a/062.png)

9. Click inside the **TableName** value text input and click **Add dynamic content**

    ![ALT](../images/module02a/063.png)

10. Copy and paste the code snippet and click **OK**

    ```javascript
    @{activity('getOldWatermark').output.firstRow.TableName}
    ```

    ![ALT](../images/module02a/064.png)

11. Click **Publish all**

    ![ALT](../images/module02a/065.png)

12. Click **Publish**

    ![ALT](../images/module02a/066.png)

13. Navigate back to the pipeline and click **Debug**

    ![ALT](../images/module02a/067.png)

14. Periodically click **Refresh** until all the activities within the pipeline have succeeded

    ![ALT](../images/module02a/068.png)

15. Navigate to the **Data** hub, browse the data lake folder structure under the **Linked tab** to `01-raw/wwi/orders`, right-click the newest CSV file and select **New SQL Script > Select TOP 100 rows**

    ![ALT](../images/module02a/069.png)

16. Modify the SQL statement to include `HEADER_ROW = TRUE` within the OPENROWSET function and click **Run**

    ![ALT](../images/module02a/070.png)

<div align="right"><a href="#module-02a---incremental-copy-to-raw-using-high-watermark">↥ back to top</a></div>

## :tada: Summary

You have successfully setup a pipeline that can check for changes in the source system by referencing the last high waterman, and copy those changes to the raw layer within your data lake.

[Continue >](../modules/module02b.md)
