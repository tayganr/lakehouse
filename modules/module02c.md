# Module 02C - Automation using Triggers

[< Previous Module](../modules/module02b.md) - **[Home](../README.md)** - [Next Module >](../modules/module03.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1A (Linked Service, Integration Datasets)
- [x] Module 2A complete
- [x] Module 2B complete

## :loudspeaker: Introduction

In this module, we will automate ingestion and loading of Order data using triggers.

## :dart: Objectives

- Periodically copy changes from source using a Tumbling Window trigger.
- On the arrival of new files in the data lake, incrementally load the fact table using a Storage Event trigger.

## 1. Trigger (Tumbling Window)

1. Navigate to the **Integrate** hub

    ![ALT](../images/module02c/001.png)

2. Open the pipeline `O1 - pipelineIncrementalCopyWatermark`

    ![ALT](../images/module02c/002.png)

3. Click **Add trigger** and select **New/Edit**

    ![ALT](../images/module02c/003.png)

4. Open the **Choose trigger...** drop-down menu and click **New**

    ![ALT](../images/module02c/004.png)

5. Rename the trigger to `triggerTumblingWindow5mOrders`

    ![ALT](../images/module02c/005.png)

6. Set the **Type** to **Tumbling window**

    ![ALT](../images/module02c/006.png)

7. Set the **Recurrence** to **5 minutes**

    ![ALT](../images/module02c/007.png)

8. Click **OK**

    ![ALT](../images/module02c/008.png)

9. Click **OK**

    ![ALT](../images/module02c/009.png)

10. Click **Publish all**

    ![ALT](../images/module02c/010.png)

11. Click **Publish**

    ![ALT](../images/module02c/011.png)

<div align="right"><a href="#module-02c---automation-using-triggers">↥ back to top</a></div>

## 2. Trigger (Storage Event)

1. Open the pipeline `O2 - pipelineFactIncrementalLoad`

    ![ALT](../images/module02c/012.png)

2. Click **Add trigger** and select **New/Edit**

    ![ALT](../images/module02c/013.png)

3. Open the **Choose trigger...** drop-down menu and click **New**

    ![ALT](../images/module02c/014.png)

4. Rename the trigger to `triggerStorageEventOrders`

    ![ALT](../images/module02c/015.png)

5. Set the **Type** to **Storage events**

    ![ALT](../images/module02c/016.png)

6. Provide the **Azure storage account** details
    - **Azure subscription** to the Azure subscription that contains your Azure Data Lake Storage Gen2 account
    - **Storage account name** to the Azure Data Lake Storage Gen2 account name
    - **Container name** via the drop-down menu to `01-raw`

    ![ALT](../images/module02c/017.png)

7. Set the **Blob path begins** with to `wwi/orders`

    ![ALT](../images/module02c/018.png)

8. Set the **Blob path ends with** to `.csv`

    ![ALT](../images/module02c/019.png)

9. Set the **Event** to `Blob created`

    ![ALT](../images/module02c/020.png)

10. Click **Continue**

    ![ALT](../images/module02c/021.png)

11. Click **Continue**

    ![ALT](../images/module02c/022.png)

12. Copy and paste the code snippet to set the **Trigger Run Parameter** (fileName) and click **OK**

```javascript
@trigger().outputs.body.fileName
```

![ALT](../images/module02c/023.png)

13. Click **Publish all**

    ![ALT](../images/module02c/024.png)

14. Click **Publish**

    ![ALT](../images/module02c/025.png)

<div align="right"><a href="#module-02c---automation-using-triggers">↥ back to top</a></div>

## 3. Load Additional Data into dbo.Orders

1. Navigate to the **SQL database**

    ![ALT](../images/module02c/026.png)

2. Click **Query editor**

    ![ALT](../images/module02c/027.png)

3. Click **Continue us <your_alias>@<your_domain>.com**

    ![ALT](../images/module02c/028.png)

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

![ALT](../images/module02c/029.png)

<div align="right"><a href="#module-02c---automation-using-triggers">↥ back to top</a></div>

## 4. Monitor

1. Navigate to the **Monitor** hub

    ![ALT](../images/module02c/030.png)

2. Under **Integration**, click **Pipeline runs**

    ![ALT](../images/module02c/031.png)

3. Set the **Pipeline name** filter to `O1 - pipelineIncrementalCopyWatermark`

    ![ALT](../images/module02c/032.png)

4. Periodically click **Refresh** until the next instance of the pipeline is triggered to run from the Tumbling Window trigger

    ![ALT](../images/module02c/033.png)

5. Once successful, change the **Pipeline name** filter to `O2 - pipelineFactIncrementalLoad`

    ![ALT](../images/module02c/034.png)

6. Periodically click **Refresh** until you observe a successful instance

    ![ALT](../images/module02c/035.png)

<div align="right"><a href="#module-02c---automation-using-triggers">↥ back to top</a></div>

## 5. Query Delta Lake

1. Navigate to the **Data** hub

    ![ALT](../images/module02c/036.png)

2. Browse the data lake folder structure to `03-curated > wwi > orders`, right-click one of the **parquet** files, and select **New SQL Script > Select TOP 100 rows**

    ![ALT](../images/module02c/037.png)

3. Modify the **OPENROWSET** function to remove the file name from the **BULK** path, change the **FORMAT** to **DELTA**, and click **Run**

    ![ALT](../images/module02c/038.png)

<div align="right"><a href="#module-02c---automation-using-triggers">↥ back to top</a></div>

## :tada: Summary

You have successfully automated the execution of the Order pipelines using triggers.

[Continue >](../modules/module03.md)
