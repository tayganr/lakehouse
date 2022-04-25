# Module 01C - Dimension Table (Incremental Load, SCD Type 2)

[< Previous Module](../modules/module01b.md) - **[Home](../README.md)** - [Next Module >](../modules/module01d.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1A complete
- [x] Module 1B complete

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally load data from our raw layer (CSV), into our curated layer (Delta Lake) as a SCD Type 2 dimension table.

## :dart: Objectives

* Create a pipeline that will incrementally load data as new files arrive.

## 1. Pipeline (pipelineDimIncrementalLoad)

In this module, we will be creating a pipeline to incrementally load the Customers dimension table. The transformation logic will be encapsulated within a data flow and will follow an SCD Type 2 pattern, this is where a new record is added to the dimension table to cater for data changes.

1. Navigate to the **Integrate** hub
2. Under **Pipelines**, click on the ellipsis **[...]** icon to the right of the `Customers` folder and select **New pipeline**
3. Rename the pipeline to `C3 - pipelineDimIncrementalLoad`
4. Under **Parameters**, click **New**
5. Set the name of the parameter to `fileName`
6. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas
7. Rename the activity `incrementalLoad`
8. Switch to the **Settings** tab
9. Next to the **Data flow** property, click **New**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 2. Data flow (Source - rawCustomer)

In this step, we start with a source transformation that will reference a delimited text file (CSV) in the raw layer of our data lake. The data flow will include a file name parameter, this will allow the pipeline to dynamically pass a file name at runtime.

1. Enable **Data flow debug**
2. Rename the data flow `dataFlowDimIncrementalLoad`
3. Under **Parameters**, click **New**
4. Rename **parameter1** to `fileName`
5. Within the data flow canvas, click **Add Source** and select **Add source**
6. Rename the **Output stream name** to `rawCustomer`
7. Set the **Source type** to **Inline**
8. Set the **Inline dataset type** to **DelimitedText**
9. Set the **Linked Service** to the Synapse Workspace Default Storage.
10. Switch to the **Source options** tab
11. Click the **Browse** icon
12. Navigate to `01-raw > wwi > customers` and click **OK**
13. Click inside the **File name** text input and click **Add dynamic content**
14. Under **Expression elements** click **Parameters**
15. Click **fileName**
16. Click **Save and finish**
17. Enable **First row as header**
18. Switch to the **Projection** tab
19. Click **Import schema**
20. Click **Import**
21. Under **Data flow parameters**, set the **fileName** property to an existing CSV file that resides within `01-raw > wwi > customers`.
    * Tip #1: In a new window, open the Azure Portal, navigate to the storage account, and use the Storage Browser to find an existing file.
    * Tip #2: To see the effect of new data during development, select the second CSV file (with the latest timestamp).
    * Note: The string must be wrapped in single quotes.
22. Click **Save**
23. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 3. Data flow (Source - dimCustomer)

In this step, we will add a second source transformation that will reference the existing Customer dimesnion table (Delta Lake) in the curated layer of our data lake.

1. Within the data flow canvas, click **Add Source** and select **Add source**
2. Rename the **Output stream name** to `dimCustomer`
3. Set the **Source type** to **Inline**
4. Set the **Inline dataset type** to **Delta**
5. Set the **Linked Service** to the Synapse Workspace Default Storage.
6. Switch to the **Source options** tab
7. Click the **Browse** icon
8. Navigate to `03-curated > wwi > customers` and click **OK**
9. Set the **Compression type** to **snappy**
10. Switch to the **Projection** tab
11. Click **Import schema**
12. Click **Import**
13. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 4. Data flow (Filter - activeCustomers)

The Filter transformation allows row filtering based upon a condition. In this step, we will filter the Customers dimension table to only include rows that are active. This is a necessary step as we will eventually compare the new incoming data with the existing active data.

1. Click the **[+]** icon to the right of `dimCustomer`, under **Row modifier** select **Filter**
2. Rename the **Output stream name** to `activeCustomers`
3. Set the **Filter on** property to `IsActive == 1`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 5. Data flow (Derived column - addHashDim)

The Derived Column transformation allows us to generate new columns and/or modify existing columns. In this step, we are adding a new column called `Hash`. This column is calculated by calling the `md5` function against the same columns that exist in the source stream (i.e. excludes dimension columns such as `CustomerSK`, `IsActive`, `ValidFrom`, and `ValidTo`). The `md5` function returns a 32-character hex string which can be used to calculate a fingerprint for a row. This will be used later in the module to compare against a hash from the new data stream.

1. Click the **[+]** icon to the right of `activeCustomers`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `addHashDim`
3. Under the **Columns**, set the **Column** to `Hash` and the **Expression** to `md5(CustomerID,CustomerAddress)`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 6. Data flow (Aggregate - maxSurrogateKey)

1. Click the **[+]** icon to the right of `activeCustomers`, under **Multiple inputs/outputs** select **New branch**
2. Click the **[+]** icon to the right of `activeCustomers` (new branch), under **Schema modifier** select **Aggregate**
3. Rename the **Output stream name** to `maxSurrogateKey`
4. Switch to **Aggregates**
5. Set the **Column** to `MaxCustomerKey` and the **Expression** to `max(CustomerSK)`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 7. Data flow (Exists - existingRecords)

1. Click the **[+]** icon to the right of `rawCustomer`, under **Multiple inputs/outputs** select **Exists**
2. Rename the **Output stream name** to `existingRecords`
3. Set the **Right stream** to `activeCustomers`
4. Set the **Exist type** to **Exists**
5. Under **Exists conditions**, set the **Left** and **Right** to `CustomerID`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 8. Data flow (Exists - newRecords)

1. Click the **[+]** icon to the right of `rawCustomer`, under **Multiple inputs/outputs** select **New branch**
2. Click the **[+]** icon to the right of `rawCustomer` (new branch), under **Multiple inputs/outputs** select **Exists**
3. Rename the **Output stream name** to `newRecords`
4. Set the **Right stream** to `activeCustomers`
5. Set the **Exist type** to **Doesn't exist**
5. Under **Exists conditions**, set the **Left** and **Right** to `CustomerID`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 9. Data flow (Derived column - addHash)

1. Click the **[+]** icon to the right of `existingRecords`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `addHash`
3. Under the **Columns**, set the **Column** to `Hash` and the **Expression** to `md5(columns())`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 10. Data flow (Exists - changedRecords)

1. Click the **[+]** icon to the right of `addHash`, under **Multiple inputs/outputs** select **Exists**
2. Rename the **Output stream name** to `changedRecords`
3. Set the **Right stream** to `addHashDim`
4. Set the **Exist type** to **Doesn't exist**
5. Under **Exists conditions**, set the **Left** and **Right** to `Hash`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 11. Data flow (Union - unionNewActive)

1. Click the **[+]** icon to the right of `changedRecords`, under **Multiple inputs/outputs** select **Union**
2. Rename the **Output stream name** to `unionNewActive`
3. Under **Union with**, set the **Streams** to `newRecords`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 12. Data flow (Alter row - markAsInsert)

1. Click the **[+]** icon to the right of `unionNewActive`, under **Row modifier** select **Alter Row**
2. Rename the **Output stream name** to `markAsInsert`
3. Under **Alter row conditions**, set the condition to **Insert If** and the expression as `true()`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 13. Data flow (Surrogate key - addTempKey)

1. Click the **[+]** icon to the right of `markAsInsert`, under **Schema modifier** select **Surrogate Key**
2. Rename the **Output stream name** to `addTempKey`
3. Set the **Key column** to `TempKey`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 14. Data flow (Join - joinMaxSurrogateKey)

1. Click the **[+]** icon to the right of `addTempKey`, under **Multiple inputs/outputs** select **Join**
2. Rename the **Output stream name** to `joinMaxSurrogateKey`
3. Set the **Right stream** to `maxSurrogateKey`
4. Set the **Join type** to `Custom (cross)`
5. Set the **Condition** to `true()`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 15. Data flow (Derived column - scdColumns)

1. Click the **[+]** icon to the right of `joinMaxSurrogateKey`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `scdColumns`
3. Under **Columns**, set the first **Column** to `CustomerSK` and the **Expression** to `TempKey + MaxCustomerKey`
4. Click **Add** then select **Add column**
5. Under **Columns**, set the second **Column** to `IsActive` and the **Expression** to `1`
6. Click **Add** then select **Add column**
7. Under **Columns**, set the third **Column** to `ValidFrom` and the **Expression** to `toTimestamp(split($fileName,'.')[1], 'yyyyMMddHHmmssSSS')`
8. Click **Add** then select **Add column**
9. Under **Columns**, set the fourth **Column** to `ValidTo` and the **Expression** to `toTimestamp('9999-12-31 00:00:00')`
10. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 16. Data flow (Select - dropTempColumns)

1. Click the **[+]** icon to the right of `scdColumns`, under **Schema modifier** select **Select**
2. Rename the **Output stream name** to `dropTempColumns`
3. Under the Input columns, delete the `Hash`, `TempKey`, and `MaxCustomerKey` columns
4. On the left hand side of the `CustomerSK`, click and drag the column to the first position
5. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 17. Data flow (Exists - obsoleteRecords)

1. Click the **[+]** icon to the right of `addHashDim`, under **Multiple inputs/outputs** select **Exists**
2. Rename the **Output stream name** to `obsoleteRecords`
3. Set the **Right stream** to `changedRecords`
4. Set the **Exist type** to **Exists**
5. Under **Exists conditions**, set the **Left** and **Right** to `CustomerID`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 18. Data flow (Alter row - markAsUpdate)

1. Click the **[+]** icon to the right of `obsoleteRecords`, under **Row modifier** select **Alter Row**
2. Rename the **Output stream name** to `markAsUpdate`
3. Under **Alter row conditions**, set the condition to **Update If** and the expression as `true()`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 19. Data flow (Derived column - scdColumnsObsolete)

1. Click the **[+]** icon to the right of `markAsUpdate`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `scdColumnsObsolete`
3. Under **Columns**, set the first **Column** to `IsActive` and the **Expression** to `0`
4. Click **Add** then select **Add column**
5. Under **Columns**, set the second **Column** to `ValidTo` and the **Expression** to `toTimestamp(split($fileName,'.')[1], 'yyyyMMddHHmmssSSS')`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 20. Data flow (Select - dropTempColumns2)

1. Click the **[+]** icon to the right of `scdColumnsObsolete`, under **Schema modifier** select **Select**
2. Rename the **Output stream name** to `dropTempColumns2`
3. Under the Input columns, delete the `Hash` column
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 21. Data flow (Union - unionResults)

1. Click the **[+]** icon to the right of `dropTempColumns`, under **Multiple inputs/outputs** select **Union**
2. Rename the **Output stream name** to `unionResults`
3. Under **Union with**, set the **Streams** to `dropTempColumns2`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 22. Data flow (Sink - sinkCustomer)

1. Click the **[+]** icon to the right of `unionResults`, under **Destination** select **Sink**
2. Rename the **Output stream name** to `sinkCustomer`
3. Set the **Sink type** to **Inline**
4. Set the **Inline dataset type** to **Delta**
5. Set the **Linked Service** to the Synapse Workspace Default Storage.
6. Switch to the **Settings** tab
7. Click the **Browse** icon
8. Navigate to `03-curated > wwi > customers` and click **OK**
9. Set the **Compression type** to `snappy`
10. Set the **Update method** to **Allow insert** and **Allow upsert**
11. Set the **Key columns** to `CustomerSK`
12. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 23. Pipeline (pipelineDimIncrementalLoad)

1. Navigate back to the pipeline `C3 - pipelineDimIncrementalLoad`
2. Click to focus on the **Data flow** activity and switch to the **Parameters** tab
3. Under **Data flow parameters**, click inside the fileName **Value** and select **Pipeline expression**
4. Copy and paste the code snippet
```
@pipeline().parameters.fileName
```
5. Click **OK**
6. Click **Publish all**
7. Click **Publish**

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## 24. Debug Pipeline

1. Click **Debug**
2. Set the **fileName** parameter value to the name of the second CSV file (with the latest timestamp)
3. Click **OK**
3. Under **Integration**, click **Pipeline runs**
4. Once a successful instance has been observed, navigate to the **Data** hub, browse the data lake folder structure under the **Linked tab** to `03-curated/wwi/customers`, right-click one of the parquet files and select **New SQL Script > Select TOP 100 rows**
5. Modify the **OPENROWSET** function to remove the file name from the **BULK** path
6. Change the **FORMAT** to **DELTA**
7. Click **Run**
    Note: You will notice there are six records in total (five active, one inactive). Try to alter the SQL query so that you only see active records sorted by CustomerID.

<div align="right"><a href="#module-01c---dimension-table-incremental-load-scd-type-2">↥ back to top</a></div>

## :tada: Summary

You have successfully setup a pipeline to incrementally load the dimension table (Customer) following the SCD Type 2 pattern using the Delta Lake format.

[Continue >](../modules/module01d.md)