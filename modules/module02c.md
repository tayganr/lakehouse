# Module 02C - Automation using Triggers

[< Previous Module](../modules/module02b.md) - **[Home](../README.md)** - [Next Module >](../modules/module03.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Post deployment steps complete
- [x] Module 1A (Linked Service, Integration Datasets)
- [x] Module 2A complete
- [x] Module 2B complete

## :loudspeaker: Introduction

In this module, we will automate ingestion and loading of Order data using triggers.

## :dart: Objectives

* Periodically copy changes from source using a Tumbling Window trigger.
* On the arrival of new files in the data lake, incrementally load the fact table using a Storage Event trigger.

## 1. Trigger (Tumbling Window)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Integrate** hub
3. Open the pipeline `O1 - pipelineIncrementalCopyWatermark`
4. Click **Add trigger**
2. Click **New/Edit**
3. Click **Choose trigger...**
4. Click **New**
5. Rename the trigger to `triggerTumblingWindow5mOrders`
6. Set the **Type** to **Tumbling window**
7. Set the **Recurrence** to **5 minutes**
8. Click **OK**
9. Click **Publish all**
10. Click **Publish**

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 2. Trigger (Storage Event)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Integrate** hub
3. Open the pipeline `O2 - pipelineFactIncrementalLoad`
4. Click **Add trigger**
5. Click **New/Edit**
6. Click **Choose trigger...**
7. Click **New**
8. Rename the trigger to `triggerStorageEventOrders`
9. Set the **Type** to **Storage events**
10. Set the **Azure subscription** to the Azure subscription that contains your Azure Data Lake Storage Gen2 account
11. Set the **Storage account name** to the Azure Data Lake Storage Gen2 account name
12. Set the **Container name** via the drop-down menu to `01-raw`
13. Set the **Blob path begins** with to `wwi/orders`
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

## 3. Load Additional Data into dbo.Orders

1. Navigate to the **SQL database**
2. Click **Query editor**
3. Click **Continue us <your_alias>@<your_domain>.com**
4. Copy and paste the code snippets below and click **Run**
```sql
INSERT INTO dbo.Orders (CustomerID, Quantity)
VALUES
    (1,13),
    (2,72),
    (5,52),
    (7,28);
SELECT * FROM [dbo].[Orders];
```

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 4. Monitor

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Monitor** hub
3. Under **Integration**, click **Pipeline runs**
4. Set the **Pipeline name** filter to `O1 - pipelineIncrementalCopyWatermark`
5. Periodically click **Refresh** until the next instance of the pipeline is triggered to run from the Tumbling Window trigger
6. Once successful, change the **Pipeline name** filter to `O2 - pipelineFactIncrementalLoad`
7. Periodically click **Refresh** until you observe a successful instance

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 5. Query Delta Lake

1. Navigate to the **Data** hub
2. Browse the data lake folder structure to `03-curated > wwi > orders`
3. Right-click one of the **parquet** files, select **New SQL Script > Select TOP 100 rows**
4. Modify the **OPENROWSET** function to remove the file name from the **BULK** path
5. Change the **FORMAT** to **DELTA**
6. Click **Run**

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## :tada: Summary

You have successfully automated the execution of the Order pipelines using triggers.

[Continue >](../modules/module03.md)