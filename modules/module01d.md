# Module 01D - Automation using Triggers

[< Previous Module](../modules/module01c.md) - **[Home](../README.md)** - [Next Module >](../modules/module02a.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1A complete
- [x] Module 1B complete
- [x] Module 1C complete

## :loudspeaker: Introduction

In this module, we will automate ingestion and loading of Customer data using triggers.

## :dart: Objectives

* Periodically copy changes from source using a Tumbling Window trigger.
* On the arrival of new files in the data lake, incrementally load the dimension table using a Storage Event trigger.

## 1. Trigger (Tumbling Window)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Integrate** hub
3. Open the pipeline `C1 - pipelineIncrementalCopyCDC`
4. Click **Add trigger**
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

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 2. Trigger (Storage Event)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Integrate** hub
3. Open the pipeline `C3 - pipelineDimIncrementalLoad`
4. Click **Add trigger**
5. Click **New/Edit**
6. Click **Choose trigger...**
7. Click **New**
8. Rename the trigger to `triggerStorageEvent`
9. Set the **Type** to **Storage events**
10. Set the **Azure subscription** to the Azure subscription that contains your Azure Data Lake Storage Gen2 account
11. Set the **Storage account name** to the Azure Data Lake Storage Gen2 account name
12. Set the **Container name** via the drop-down menu to `01-raw`
13. Set the **Blob path begins** with to `wwi/customers`
14. Set the **Blob path ends with** to `.csv`
15. Set the **Event** to `Blob created`
16. Click **Continue**
17. Click **Continue**
18. Copy and paste the code snippet to set the **Trigger Run Parameter** (fileName)
```
@trigger().outputs.body.fileName
```
19. Click OK
20. Click **Publish all**
21. Click **Publish**

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 3. Load Additional Data into dbo.Customers

1. Navigate to the **SQL database**
2. Click **Query editor**
3. Click **Continue us <your_alias>@<your_domain>.com**
4. Copy and paste the code snippets below and click **Run**
```sql
UPDATE dbo.Customers SET CustomerAddress = '34 Park Road, East London, E9 7RW' WHERE CustomerID = 5;
INSERT INTO dbo.Customers (CustomerAddress)
VALUES
    ('169 Manchester Road, Preston, PR35 8AQ'),
    ('52 Broadway, Plymouth, PL39 3PY');
SELECT * FROM [dbo].[Customers];
```

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 4. Monitor

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Monitor** hub
3. Under **Integration**, click **Pipeline runs**
4. Set the **Pipeline name** filter to `C1 - pipelineIncrementalCopyCDC`
5. Periodically click **Refresh** until the next instance of the pipeline is triggered to run from the Tumbling Window trigger
6. Once successful, change the **Pipeline name** filter to `C3 - pipelineDimIncrementalLoad`
7. Periodically click **Refresh** until you observe a successful instance

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 5. Query Delta Lake

1. Navigate to the **Data** hub
2. Browse the data lake folder structure to `03-curated > wwi > customers`
3. Right-click one of the **parquet** files, select **New SQL Script > Select TOP 100 rows**
4. Modify the **OPENROWSET** function to remove the file name from the **BULK** path
5. Change the **FORMAT** to **DELTA**
6. Click **Run**

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## :tada: Summary

You have automated the execution of the Customer pipelines using triggers.

[Continue >](../modules/module02a.md)