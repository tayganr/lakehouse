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

- Periodically copy changes from source using a Tumbling Window trigger.
- On the arrival of new files in the data lake, incrementally load the dimension table using a Storage Event trigger.

## 1. Trigger (Tumbling Window)

1. Navigate to the **Integrate** hub

    ![ALT](../images/module01d/001.png)

2. Open the pipeline `C1 - pipelineIncrementalCopyCDC`

    ![ALT](../images/module01d/002.png)

3. Click **Add trigger** and select **New/Edit**

    ![ALT](../images/module01d/003.png)

4. Open the **Choose trigger...** drop-down menu and click **New**

    ![ALT](../images/module01d/004.png)

5. Rename the trigger to `triggerTumblingWindow5m`

    ![ALT](../images/module01d/005.png)

6. Set the **Type** to **Tumbling window**

    ![ALT](../images/module01d/006.png)

7. Set the **Recurrence** to **5 minutes**

    ![ALT](../images/module01d/007.png)

8. Click **OK**

    ![ALT](../images/module01d/008.png)

9. Copy and paste the snippet below for **triggerStartTime**

```javascript
@formatDateTime(trigger().outputs.windowStartTime,'yyyy-MM-dd HH:mm:ss.fff')
```

![ALT](../images/module01d/009.png)

10. Copy and paste the snippet below for **triggerEndTime**

```javascript
@formatDateTime(trigger().outputs.windowEndTime,'yyyy-MM-dd HH:mm:ss.fff')
```

![ALT](../images/module01d/010.png)

11. Click **OK**

    ![ALT](../images/module01d/011.png)

12. Click **Publish all**

    ![ALT](../images/module01d/012.png)

13. Click **Publish**

    ![ALT](../images/module01d/013.png)

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 2. Trigger (Storage Event)

1. Navigate to the **Integrate** hub

    ![ALT](../images/module01d/014.png)

2. Open the pipeline `C3 - pipelineDimIncrementalLoad`

    ![ALT](../images/module01d/015.png)

3. Click **Add trigger** and select **New/Edit**

    ![ALT](../images/module01d/016.png)

4. Open the **Choose trigger...** drop-down menu and click **New**

    ![ALT](../images/module01d/017.png)

5. Rename the trigger to `triggerStorageEvent`

    ![ALT](../images/module01d/018.png)

6. Set the **Type** to **Storage events**

    ![ALT](../images/module01d/019.png)

7. Provide the **Azure storage account** details
    - **Azure subscription** to the Azure subscription that contains your Azure Data Lake Storage Gen2 account
    - **Storage account name** to the Azure Data Lake Storage Gen2 account name
    - **Container name** via the drop-down menu to `01-raw`

    ![ALT](../images/module01d/020.png)

8. Set the **Blob path begins** with to `wwi/customers`

    ![ALT](../images/module01d/021.png)

9. Set the **Blob path ends with** to `.csv`

    ![ALT](../images/module01d/022.png)

10. Set the **Event** to `Blob created`

    ![ALT](../images/module01d/023.png)

11. Click **Continue**

    ![ALT](../images/module01d/024.png)

12. Click **Continue**

    ![ALT](../images/module01d/025.png)

13. Copy and paste the code snippet to set the **Trigger Run Parameter** (fileName) and click **OK**

```javascript
@trigger().outputs.body.fileName
```

![ALT](../images/module01d/026.png)

14. Click **Publish all**

    ![ALT](../images/module01d/027.png)

15. Click **Publish**

    ![ALT](../images/module01d/028.png)

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 3. Load Additional Data into dbo.Customers

1. Navigate to the **SQL database**

    ![ALT](../images/module01d/029.png)

2. Click **Query editor**

    ![ALT](../images/module01d/030.png)

3. Click **Continue us <your_alias>@<your_domain>.com**

    ![ALT](../images/module01d/031.png)

4. Copy and paste the code snippets below and click **Run**

```sql
UPDATE dbo.Customers SET CustomerAddress = '34 Park Road, East London, E9 7RW' WHERE CustomerID = 5;
INSERT INTO dbo.Customers (CustomerAddress)
VALUES
    ('169 Manchester Road, Preston, PR35 8AQ'),
    ('52 Broadway, Plymouth, PL39 3PY');
SELECT * FROM [dbo].[Customers];
```

![ALT](../images/module01d/032.png)

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 4. Monitor

1. Navigate to the **Synapse workspace**

    ![ALT](../images/module01d/033.png)

2. Open **Synapse Studio**

    ![ALT](../images/module01d/034.png)

3. Navigate to the **Monitor** hub

    ![ALT](../images/module01d/035.png)

4. Under **Integration**, click **Pipeline runs**

    ![ALT](../images/module01d/036.png)

5. Set the **Pipeline name** filter to `C1 - pipelineIncrementalCopyCDC`

    ![ALT](../images/module01d/037.png)

6. Periodically click **Refresh** until the next instance of the pipeline is triggered to run from the Tumbling Window trigger

    ![ALT](../images/module01d/038.png)

7. Once successful, change the **Pipeline name** filter to `C3 - pipelineDimIncrementalLoad`

    ![ALT](../images/module01d/039.png)

8. Periodically click **Refresh** until you observe a successful instance

    ![ALT](../images/module01d/040.png)

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## 5. Query Delta Lake

1. Navigate to the **Data** hub

    ![ALT](../images/module01d/041.png)

2. Browse the data lake folder structure to `03-curated > wwi > customers`, right-click one of the **parquet** files, and select **New SQL Script > Select TOP 100 rows**

    ![ALT](../images/module01d/042.png)

3. Modify the **OPENROWSET** function to remove the file name from the **BULK** path, change the **FORMAT** to **DELTA** and click **Run**

    ![ALT](../images/module01d/043.png)

<div align="right"><a href="#module-01d---automation-using-triggers">↥ back to top</a></div>

## :tada: Summary

You have successfully automated the execution of the Customer pipelines using triggers.

[Continue >](../modules/module02a.md)