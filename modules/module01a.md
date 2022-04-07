# Module 01A - Incremental Copy to Raw (via CDC)

[< Previous Module](../modules/moduleXX.md) - **[Home](../README.md)** - [Next Module >](../modules/module01b.md)

## :thinking: Prerequisites

* Lab environment deployed
* Post deployment scripts executed
* Access to the Azure Synapse Analytics workspace

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally copy data from an OLTP source (Azure SQL Database), leveraging Change Data Capture technology to isolate changes. The data will be copied to the raw layer of our Azure Data Lake Storage Gen2 account.

## :dart: Objectives

* Enable Change Data Capture
* Create a Pipeline
* Trigger Pipeline based on a Tumbling Window
* Copy data changes to the data lake

## 1. Source Environment (dbo.Customers)
1. Navigate to the **SQL database**
2. Click **Query editor**
3. Click **Continue us <your_alias>@<your_domain>.com**
4. To create the source table, copy and paste the code snippet below and click **Run**
```sql
CREATE TABLE Customers (
    CustomerID int IDENTITY(1,1) PRIMARY KEY,
    CustomerAddress varchar(255) NOT NULL
);
```
5. To enable change data capture on the source table, copy and paste the code snippet below and click **Run**
```sql
EXEC sys.sp_cdc_enable_db;
EXEC sys.sp_cdc_enable_table  
    @source_schema = N'dbo',  
    @source_name   = N'Customers',  
    @role_name     = NULL,
    @supports_net_changes = 1;
```
6. To load the source table with data, copy and paste the code snippet below and click **Run**
```sql
INSERT INTO dbo.Customers (CustomerAddress)
VALUES
    ('82 Margate Drive, Sheffield S4 8FQ'),
    ('135 High Barns, Ely, CB7 4RH'),
    ('39 Queen Annes Drive, Bedale, DL8 2EL');
```

## 2. Linked Service (Azure SQL Database)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Manage** hub
3. Click **Linked services**
4. Click **New**
5. Search `SQL`, select **Azure SQL Database**, and click **Continue**
6. Select the target Azure SQL Database by selecting the **Azure subscription**, **Server name** and **Database name**
7. Set the **Authentication** type to `SQL authentication`
8. Copy and paste the **User name**
```
sqladmin
```
9. Copy and paste the **Password**
```
sqlPassword!
```
10. Click **Test connection**
11. Click **Create**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 3. Integration Dataset (Azure SQL Database - Table)

1. Navigate to the **Data** hub
2. Switch to the **Linked** tab
3. Click the **[+]** icon to add a new resource and click **Integration dataset**
4. Search `SQL`, select **Azure SQL Database**, and click **Continue** 
5. Select the Linked service `AzureSqlDatabase`
6. Click **OK**
7. Switch the the **Parameters** tab
8. Click **New**
9. Set the Name to `schema`
10. Click **New**
11. Set the Name to `table`
12. Switch to the **Connection** tab
13. Click **Edit**
14. Click inside the first text input for **Table** and click **Add dynamic content**
15. Under **Parameters**, click `schema`
16. Click **OK**
17. Click inside the second text input for **Table** and click **Add dynamic content**
18. Under **Parameters**, click `table`
19. Click **OK**
20. Click **Publish all**
21. Click **Publish**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 4. Integration Dataset (Azure Data Lake Storage Gen2 - Raw)

1. Navigate to the **Data** hub
2. Switch to the **Linked** tab
3. Click the **[+]** icon to add a new resource and click **Integration dataset**
4. Search `Data Lake`, select **Azure Data Lake Storage Gen2**, and click **Continue** 
5. Select **DelimitedText** and click **Continue**
6. Rename the integration dataset to `AdlsRawDelimitedText`
7. Select the Azure Synapse Analytics workspace default storage **Linked service**
8. Click the **browse** icon
9. Select `01-raw`
10. Click **OK**
11. Select **First row as header**
12. Click **OK**
13. Switch to the **Parameters** tab
14. Click **New**
15. Set the Name to `folderPath`
16. Click **New**
17. Set the Name to `fileName`
18. Switch to the **Connection** tab
19. Click inside the `Directory` text input and click **Add dynamic content**
20. Under **Parameters**, click `folderPath`
21. Click **OK**
22. Click inside the `File` text input and click **Add dynamic content**
23. Under **Parameters**, click `fileName`
24. Click **OK**
25. Click **Publish all**
26. Click **Publish**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 5. Pipeline (Lookup)

1. Navigate to the **Integrate** hub
2. Click the **[+]** icon to add a new resource and click **Pipeline**
3. Rename the pipeline to `pipelineIncrementalCopyCDC`
4. Under **Parameters** click **New**
5. Set the Name to `triggerStartTime`
6. Click **New**
7. Set the Name to `triggerEndTime`
3. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas
4. Rename the activity `GetChangeCount`
5. Switch to the **Settings** tab
6. Set the **Source dataset** to **AzureSqlTable**
7. Set the Dataset property **schema** to `cdc`
8. Set the Dataset property **table** to `dbo_Customers_CT`
9. Set the **Use query** property to **Query**
10. Click inside the **Query** text input and click **Add dynamic content** 
11. Copy and paste the code snippet
```
@concat('DECLARE @begin_time datetime, @end_time datetime, @from_lsn binary(10), @to_lsn binary(10); 
SET @begin_time = ''',pipeline().parameters.triggerStartTime,''';
SET @end_time = ''',pipeline().parameters.triggerEndTime,''';
SET @from_lsn = sys.fn_cdc_map_time_to_lsn(''smallest greater than or equal'', @begin_time);
SET @to_lsn = sys.fn_cdc_map_time_to_lsn(''largest less than'', @end_time);
IF (@from_lsn IS NOT NULL AND @to_lsn IS NOT NULL AND @from_lsn < @to_lsn)
SELECT count(1) changecount FROM cdc.fn_cdc_get_net_changes_dbo_Customers(@from_lsn, @to_lsn, ''all'')
ELSE SELECT 0 changecount')
```
12. Click **OK**
13. Click **Preview data**
14. Provide a value for **triggerStartTime** that is a date before today (e.g. `2022-01-01`)
15. Provide a value for **triggerEndTime** that is a data in the future (e.g. `2022-12-31`)
16. Click **OK**
17. You should see a changecount of 3, close the Preview data window
18. Click **Publish all**
19. Click **Publish**

## 6. Pipeline (If Condition, Copy data)

1. Within Activities, search for `If`, and drag the **If Condition activity** onto the canvas
2. Click and drag on the green button from the **Lookup** to the **If Condition** to establish a connection
3. Rename the **If Condition** activity to `HasChangedRows`
4. Switch to the **Activities** tab
5. Click inside the **Expression** text input and click **Add dynamic content**
6. Copy and paste the code snippet
```
@greater(int(activity('GetChangeCount').output.firstRow.changecount),0)
```
7. Click **OK**
8. Within the **True** case, click the **pencil** icon
9. Within Activities, search for `Copy`, and drag the **Copy data** activity onto the canvas
10. Rename the **Copy** activity to `copyIncrementalData`
11. Switch to the **Source** tab
12. Set **Source dataset** to **AzureSqlTable**
13. Under **Dataset properties**, set the **schema** to `cdc`
14. Under **Dataset properties**, set the **table** to `dbo_Customers_CT`
15. Set **Use query** to **Query**
16. Click inside the **Query** text input and click **Add dynamic content** 
17. Copy and paste the code snippet
```
@concat('DECLARE @begin_time datetime, @end_time datetime, @from_lsn binary(10), @to_lsn binary(10); 
SET @begin_time = ''',pipeline().parameters.triggerStartTime,''';
SET @end_time = ''',pipeline().parameters.triggerEndTime,''';
SET @from_lsn = sys.fn_cdc_map_time_to_lsn(''smallest greater than or equal'', @begin_time);
SET @to_lsn = sys.fn_cdc_map_time_to_lsn(''largest less than'', @end_time);
SELECT CustomerID, CustomerAddress FROM cdc.fn_cdc_get_net_changes_dbo_Customers(@from_lsn, @to_lsn, ''all'')')
```
18. Switch to the **Sink** tab
19. Set **Sink dataset** to **AdlsRawDelimitedText**
20. Under **Dataset properties**, set the **folderPath** to `wwi/customers`
21. Under **Dataset properties**, click inside the **fileName** text input and click **Add dynamic content**
22. Copy and paste the code snippet
```
@concat(formatDateTime(pipeline().parameters.triggerStartTime,'yyyyMMddHHmmssfff'),'.csv')
```
22. Navigate back up to the pipeline and click **Publish all**
23. Click **Publish**
24. Click **Debug**
25. Provide a value for **triggerStartTime** that is a date before today (e.g. `2022-01-01`)
26. Provide a value for **triggerEndTime** that is a data in the future (e.g. `2022-12-31`)
27. Click **OK**
28. When the pipeline run is complete, under the **Output** tab, click the **Details** icon of the Copy data activity to confirm that three rows have been written to the data lake.
29. You can also navigate to the **Data** hub, browse the data lake folder structure under the **Linked tab** to `01-raw/wwi/customers`, right-click the CSV file and select **New SQL Script > Select TOP 100 rows**
30. Modify the SQL statement to include `HEADER_ROW = TRUE` within the OPENROWSET function and click **Run**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 7. Trigger (Tumbling Window)

1. Navigate back to the pipeline and click **Add trigger**
2. Click **New/Edit**
3. Click **Choose trigger...**
4. Click **New**
5. Rename the trigger to `triggerTumblingWindow5m`
6. Set the **Type** to **Tumbling window**
7. Set the **Recurrence** to **5 minutes**
8. Click **OK**
9. Copy and paste the snippet below for **triggerStartTime**
```
@formatDateTime(trigger().outputs.windowStartTime,'yyyy-MM-dd HH:mm:ss.fff')
```
10. Copy and paste the snippet below for **triggerEndTime**
```
@formatDateTime(trigger().outputs.windowEndTime,'yyyy-MM-dd HH:mm:ss.fff')
```
11. Click **OK**
12. Click **Publish all**
13. Click **Publish**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 8. Load Additional Data into dbo.Customers

1. Navigate to the **SQL database**
2. Click **Query editor**
3. Click **Continue us <your_alias>@<your_domain>.com**
4. Copy and paste the code snippets below and click **Run**
```sql
UPDATE dbo.Customers SET CustomerAddress = 'Guyzance Cottage, Guyzance NE65 9AF' WHERE CustomerID = 3;
INSERT INTO dbo.Customers (CustomerAddress)
VALUES
    ('322 Fernhill, Mountain Ash, CF45 3EN'),
    ('381 Southborough Lane, Bromley, BR2 8BQ');
SELECT * FROM [dbo].[Customers];
```
5. Make note of the current time

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 9. Monitor Pipeline

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Monitor** hub
3. Under **Integration**, click **Pipeline runs**
4. Monitor the triggered pipeline runs until an instance runs AFTER the additional data was loaded
5. Once a successful instance has been observed, navigate to the **Data** hub, browse the data lake folder structure under the **Linked tab** to `01-raw/wwi/customers`, right-click the newest CSV file and select **New SQL Script > Select TOP 100 rows**
6. Modify the SQL statement to include `HEADER_ROW = TRUE` within the OPENROWSET function and click **Run**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## :tada: Summary

You have successfully setup a recurring pipeline that will periodically check for changes in the source system and copy those changes to the raw layer within your data lake.

[Continue >](../modules/module01b.md)