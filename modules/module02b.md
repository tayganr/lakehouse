# Module 02B - Incremental Load Dimension (SCD Type 2)

[< Previous Module](../modules/module02a.md) - **[Home](../README.md)** - [Next Module >](../modules/module03.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Post deployment scripts executed
- [x] Module 1A complete
- [x] Module 2A complete

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally load data from our raw layer (CSV), into our curated layer (Delta Lake) as a SCD Type 2 dimension table.

## :dart: Objectives

* Create a pipeline that will incrementally load data as new files arrive.

## 1. Pipeline (initialLoad)

1. Navigate to the **Integrate** hub
2. Click the **[+]** icon to add a new resource and click **Pipeline**
3. Rename the pipeline to `pipelineDimIncrementalLoad`
4. Under **Parameters**, click **New**
5. Set the name of the parameter to `fileName`
6. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas
7. Rename the activity `incrementalLoad`
8. Switch to the **Settings** tab
9. Next to the **Data flow** property, click **New**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 2. Data flow (Source - rawCustomer)

1. Enable **Data flow debug**
2. Rename the data flow `incrementalLoad`
3. Under **Parameters**, click **New**
4. Rename **parameter1** to `fileName`
5. Click **Add Source**
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
21. Under **Data flow parameters**, set the **fileName** property to an existing CSV file that resides within `01-raw > wwi > customers` (e.g. `20220101000000000.csv`). Note: The string must be wrapped in single quotes.
22. Click **Save**
23. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 3. Data flow (Source - dimCustomer)

1. Click **Add Source**
2. Rename the **Output stream name** to `dimCustomer`
3. Set the **Source type** to **Inline**
4. Set the **Inline dataset type** to **Delta**
5. Set the **Linked Service** to the Synapse Workspace Default Storage.
6. Switch to the **Source options** tab
7. Click the **Browse** icon
8. Navigate to `03-curated > customers` and click **OK**
9. Switch to the **Projection** tab
10. Click **Import schema**
11. Click **Import**
12. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 4. Data flow (Filter - activeCustomers)

1. Click the **[+]** icon to the right of `dimCustomer`, under **Row modifier** select **Filter**
2. Rename the **Output stream name** to `activeCustomers`
3. Set the **Filter on** property to `IsActive == 1`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 5. Data flow (Derived column - addHashDim)

1. Click the **[+]** icon to the right of `activeCustomers`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `addHashDim`
3. Under the **Columns**, set the **Column** to `Hash` and the **Expression** to `md5(CustomerID,CustomerAddress)`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 6. Data flow (Aggregate - maxSurrogateKey)

1. Click the **[+]** icon to the right of `activeCustomers`, under **Multiple inputs/outputs** select **New branch**
2. Click the **[+]** icon to the right of `activeCustomers` (new branch), under **Schema modifier** select **Aggregate**
3. Rename the **Output stream name** to `maxSurrogateKey`
4. Switch to **Aggregates**
5. Set the **Column** to `MaxCustomerKey` and the **Expression** to `max(SurrogateKey)`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 7. Data flow (Exists - existingRecords)

1. Click the **[+]** icon to the right of `rawCustomer`, under **Multiple inputs/outputs** select **Exists**
2. Rename the **Output stream name** to `existingRecords`
3. Set the **Right stream** to `activeCustomers`
4. Set the **Exist type** to **Exists**
5. Under **Exists conditions**, set the **Left** and **Right** to `CustomerID`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 8. Data flow (Exists - newRecords)

1. Click the **[+]** icon to the right of `rawCustomer`, under **Multiple inputs/outputs** select **New branch**
2. Click the **[+]** icon to the right of `rawCustomer` (new branch), under **Multiple inputs/outputs** select **Exists**
3. Rename the **Output stream name** to `newRecords`
4. Set the **Right stream** to `activeCustomers`
5. Set the **Exist type** to **Doesn't exist**
5. Under **Exists conditions**, set the **Left** and **Right** to `CustomerID`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 9. Data flow (Derived column - addHash)

1. Click the **[+]** icon to the right of `existingRecords`, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `addHash`
3. Under the **Columns**, set the **Column** to `Hash` and the **Expression** to `md5(columns())`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 10. Data flow (Exists - changedRecords)

1. Click the **[+]** icon to the right of `addHash`, under **Multiple inputs/outputs** select **Exists**
2. Rename the **Output stream name** to `changedRecords`
3. Set the **Right stream** to `addHashDim`
4. Set the **Exist type** to **Doesn't exist**
5. Under **Exists conditions**, set the **Left** and **Right** to `Hash`
6. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 11. Data flow (Union - unionNewActive)

1. Click the **[+]** icon to the right of `changedRecords`, under **Multiple inputs/outputs** select **Union**
2. Rename the **Output stream name** to `unionNewActive`
3. Under **Union with**, set the **Streams** to `newRecords`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 12. Data flow (Alter row - markAsInsert)

1. Click the **[+]** icon to the right of `unionNewActive`, under **Row modifier** select **Alter Row**
2. Rename the **Output stream name** to `markAsInsert`
3. Under **Alter row conditions**, set the condition to **Insert If** and the expression as `true()`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 13. Data flow (Surrogate key - addTempKey)

1. Click the **[+]** icon to the right of `markAsInsert`, under **Schema modifier** select **Surrogate Key**
2. Rename the **Output stream name** to `addTempKey`
3. Set the **Key column** to `TempKey`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## :tada: Summary

TBC.

[Continue >](../modules/module03.md)