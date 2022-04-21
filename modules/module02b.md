# Module 02B - Incremental Load Fact

[< Previous Module](../modules/module02a.md) - **[Home](../README.md)** - [Next Module >](../modules/module02c.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1A (Linked Service, Integration Datasets)
- [x] Module 2A complete

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally load data from our raw layer (CSV), into our curated layer (Delta Lake) where our fact table resides.

## :dart: Objectives

* Create a pipeline that will incrementally load data as new files arrive.

## 1. Pipeline (pipelineFactIncrementalLoad)

1. Navigate to the **Integrate** hub
2. Under **Pipelines**, click on the ellipsis **[...]** icon to the right of the `Orders` folder and select **New pipeline**
3. Rename the pipeline to `O2 - pipelineFactIncrementalLoad`
4. Under **Parameters**, click **New**
5. Set the name of the parameter to `fileName`
6. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas
7. Rename the activity `incrementalLoadFact`
8. Switch to the **Settings** tab
9. Next to the **Data flow** property, click **New**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 2. Data flow (Source - rawOrders)

1. Enable **Data flow debug**
2. Rename the data flow `dataFlowFactIncrementalLoad`
3. Under **Parameters**, click **New**
4. Rename **parameter1** to `fileName`
5. Click **Add Source**
6. Rename the **Output stream name** to `rawOrders`
7. Set the **Source type** to **Inline**
8. Set the **Inline dataset type** to **DelimitedText**
9. Set the **Linked Service** to the Synapse Workspace Default Storage.
10. Switch to the **Source options** tab
11. Click the **Browse** icon
12. Navigate to `01-raw > wwi > orders` and click **OK**
13. Click inside the **File name** text input and click **Add dynamic content**
14. Under **Expression elements** click **Parameters**
15. Click **fileName**
16. Click **Save and finish**
17. Enable **First row as header**
18. Switch to the **Projection** tab
19. Click **Import schema**
20. Click **Import**
21. Under **Data flow parameters**, set the **fileName** property to an existing CSV file that resides within `01-raw > wwi > orders`.
    * Tip: In a new window, open the Azure Portal, navigate to the storage account, and use the Storage Browser to find an existing file.
    * Note: The string must be wrapped in single quotes.
22. Click **Save**
23. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 3. Data flow (Source - dimCustomer)

1. Click **Add Source**
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

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 4. Data flow (Filter - activeCustomers)

1. Click the **[+]** icon to the right of `dimCustomer`, under **Row modifier** select **Filter**
2. Rename the **Output stream name** to `activeCustomers`
3. Set the **Filter on** property to `IsActive == 1`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 5. Data flow (Lookup - addHashDim)

1. Click the **[+]** icon to the right of `rawOrders`, under **Multiple inputs/outputs** select **Lookup**
2. Rename the **Output stream name** to `lookupDimCustomer`
3. Set the **Lookup stream** to `activeCustomers`
4. Set the **Lookup conditions** to `CustomerID` on both the Left and Right
5. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 6. Data flow (Select - selectFactColumns)

1. Click the **[+]** icon to the right of `lookupDimCustomer`, under **Schema modifier** select **Select**
2. Rename the **Output stream name** to `selectFactColumns`
3. Under the Input columns, delete all columns except `OrderID`, `SurrogateKey`, and `Quantity`
4. On the left hand side of the `SurrogateKey`, click and drag the column to the second position
5. Rename `SurrogateKey` to `CustomerKey`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 7. Data flow (Derived column - checkForEarlyFacts)

1. Click the **[+]** icon to the right of `selectFactColumns`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `checkForEarlyFacts`
3. Under **Columns**, click the **Column** drop-down menu and select `CustomerKey`
4. Copy and paste the code snippet into the **Expression**
```
iif(isNull(CustomerKey),toLong(0),CustomerKey)
```
5. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 8. Data flow (Alter row - markAsUpsert)

1. Click the **[+]** icon to the right of `checkForEarlyFacts`, under **Row modifier** select **Alter Row**
2. Rename the **Output stream name** to `markAsUpsert`
3. Under **Alter row conditions**, set the condition to **Upsert If** and the expression as `true()`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 9. Data flow (Sink - sinkOrders)

1. Click the **[+]** icon to the right of `markAsUpsert`, under **Destination** select **Sink**
2. Rename the **Output stream name** to `sinkOrders`
3. Set the **Sink type** to **Inline**
4. Set the **Inline dataset type** to **Delta**
5. Set the **Linked Service** to the Synapse Workspace Default Storage.
6. Switch to the **Settings** tab
7. Click the **Browse** icon
8. Navigate to `03-curated > wwi` and click **OK**
9. Within the **Folder path** property, replace `wwi` with `wwi/orders`
10. Set the **Compression type** to `snappy`
11. Set the **Update method** to **Allow insert** and **Allow upsert**
12. Set the **Key columns** to `OrderID`
13. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 10. Pipeline (pipelineFactIncrementalLoad)

1. Navigate back to the pipeline `O2 - pipelineFactIncrementalLoad`
2. Click to focus on the **Data flow** activity and switch to the **Parameters** tab
3. Under **Data flow parameters**, click inside the fileName **Value** and select **Pipeline expression**
4. Copy and paste the code snippet
```
@pipeline().parameters.fileName
```
5. Click **OK**
6. Click **Publish all**
7. Click **Publish**

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 11. Debug Pipeline

1. Click **Debug**
2. Set the **fileName** parameter value to the name of an existing CSV file
3. Click **OK**
3. Under **Integration**, click **Pipeline runs**
4. Once a successful instance has been observed, navigate to the **Data** hub, browse the data lake folder structure under the **Linked tab** to `03-curated/wwi/orders`, right-click one of the parquet files and select **New SQL Script > Select TOP 100 rows**
5. Modify the **OPENROWSET** function to remove the file name from the **BULK** path
6. Change the **FORMAT** to **DELTA**
7. Click **Run**
    Note: You will notice there are six records in total (five active, one inactive). Try to alter the SQL query so that you only see active records sorted by CustomerID.

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## :tada: Summary

You have successfully setup a pipeline to incrementally load the fact table (Orders) using the Delta Lake format.

[Continue >](../modules/module02c.md)