# Module 02B - Incremental Load Fact

[< Previous Module](../modules/module02a.md) - **[Home](../README.md)** - [Next Module >](../modules/module02c.md)

## :stopwatch: Estimated Duration

20 minutes

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1A (Linked Service, Integration Datasets)
- [x] Module 2A complete

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally load data from our raw layer (CSV), into our curated layer (Delta Lake) where our fact table resides.

```mermaid
flowchart LR

param((fileName))
param-.->p

ds1[(Data Lake\nraw)]
ds2a[(Data Lake\ncurated)]
ds2b[(Data Lake\ncurated)]

ds1-."01-raw/wwi/orders/$fileName\nCSV".->df1
ds2b-."03-curated/wwi/customers\nDelta Lake".->df7
df6-."03-curated/wwi/orders\nDelta Lake".->ds2a

subgraph p["Pipeline (O2 - pipelineFactIncrementalLoad)"]
a1[Data flow\nincrementalLoadFact]
end

a1-.->df

subgraph df["Data flow (dataFlowFactIncrementalLoad)"]
df1[Source\nrawOrders]
df2[Lookup\nlookupDimCustomer]
df3[Select\nselectFactColumns]
df4[Derived column\ncheckForEarlyFacts]
df5[Alter row\nmarkAsUpsert]
df6[Sink\nsinkOrders]
df7[Source\ndimCustomer]
df8[Filter\nactiveCustomers]
df1-->df2
df2-->df3
df3-->df4
df4-->df5
df5-->df6
df7-->df8
df8-->df2
end

```

## :dart: Objectives

- Create a pipeline that will incrementally load data as new files arrive.

## Table of Contents

1. [Pipeline (pipelineFactIncrementalLoad)](#1-Pipeline-pipelineFactIncrementalLoad)
2. [Data flow (Source - rawOrders)](#2-Data-flow-Source---rawOrders)
3. [Data flow (Source - dimCustomer)](#3-Data-flow-Source---dimCustomer)
4. [Data flow (Filter - activeCustomers)](#4-Data-flow-Filter---activeCustomers)
5. [Data flow (Lookup - lookupDimCustomer)](#5-Data-flow-Lookup---lookupDimCustomer)
6. [Data flow (Select - selectFactColumns)](#6-Data-flow-Select---selectFactColumns)
7. [Data flow (Derived column - checkForEarlyFacts)](#7-Data-flow-Derived-column---checkForEarlyFacts)
8. [Data flow (Alter row - markAsUpsert)](#8-Data-flow-Alter-row---markAsUpsert)
9. [Data flow (Sink - sinkOrders)](#9-Data-flow-Sink---sinkOrders)
10. [Pipeline (pipelineFactIncrementalLoad)](#10-Pipeline-pipelineFactIncrementalLoad)
11. [Debug Pipeline](#11-Debug-Pipeline)

## 1. Pipeline (pipelineFactIncrementalLoad)

In this step, we are going to create a new pipeline `O2 - pipelineFactIncrementalLoad` that will include a **Data flow** activity to incrementally load data from `raw` into our fact table within the `curated` layer.

1. Navigate to the **Integrate** hub

    ![ALT](../images/module02b/001.png)

2. Under **Pipelines**, click on the ellipsis **[...]** icon to the right of the `Orders` folder and select **New pipeline**

    ![ALT](../images/module02b/002.png)

3. Rename the pipeline to `O2 - pipelineFactIncrementalLoad`

    ![ALT](../images/module02b/003.png)

4. Under **Parameters**, click **New**

    ![ALT](../images/module02b/004.png)

5. Set the name of the parameter to `fileName`

    ![ALT](../images/module02b/005.png)

6. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas

    ![ALT](../images/module02b/006.png)

7. Rename the activity `incrementalLoadFact`

    ![ALT](../images/module02b/007.png)

8. Switch to the **Settings** tab

    ![ALT](../images/module02b/008.png)

9. Next to the **Data flow** property, click **New**

    ![ALT](../images/module02b/009.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 2. Data flow (Source - rawOrders)

In this step, we start with a **source** transformation that will reference a delimited text file (CSV) in the raw layer of our data lake. The data flow will include a file name parameter, this will allow the pipeline to dynamically pass a file name at runtime.

1. Enable **Data flow debug**

    ![ALT](../images/module02b/010.png)

2. Rename the data flow `dataFlowFactIncrementalLoad`

    ![ALT](../images/module02b/011.png)

3. Under **Parameters**, click **New**

    ![ALT](../images/module02b/012.png)

4. Rename **parameter1** to `fileName`

    ![ALT](../images/module02b/013.png)

5. Within the data flow canvas, click **Add Source** and select **Add source**

    ![ALT](../images/module02b/014.png)

6. Rename the **Output stream name** to `rawOrders`

    ![ALT](../images/module02b/015.png)

7. Set the **Source type** to **Inline**

    ![ALT](../images/module02b/016.png)

8. Set the **Inline dataset type** to **DelimitedText**

    ![ALT](../images/module02b/017.png)

9. Set the **Linked Service** to the **Synapse Workspace Default Storage**

    ![ALT](../images/module02b/018.png)

10. Switch to the **Source options** tab and click the **Browse** icon

    ![ALT](../images/module02b/019.png)

11. Navigate to `01-raw > wwi > orders` and click **OK**

    ![ALT](../images/module02b/020.png)

12. Click inside the **File name** text input and click **Add dynamic content**

    ![ALT](../images/module02b/021.png)

13. Under **Expression elements** click **Parameters**, select **fileName**, and click **Save and finish**

    ![ALT](../images/module02b/022.png)

14. Enable **First row as header**

    ![ALT](../images/module02b/023.png)

15. Switch to the **Projection** tab and click **Import schema**

    ![ALT](../images/module02b/024.png)

16. Click **Import**

    ![ALT](../images/module02b/025.png)

17. Under **Data flow parameters**, set the **fileName** property to an existing CSV file that resides within `01-raw > wwi > orders`, and click **Save**
    - Tip: In a new window, open the Azure Portal, navigate to the storage account, and use the Storage Browser to find an existing file.
    - Note: The string must be wrapped in single quotes.

    ![ALT](../images/module02b/026.png)

18. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/027.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 3. Data flow (Source - dimCustomer)

In this step, we will add a second **source** transformation that will reference the existing Customer dimension table (Delta Lake) in the curated layer of our data lake.

1. Within the data flow canvas, click **Add Source** and select **Add source**

    ![ALT](../images/module02b/028.png)

2. Rename the **Output stream name** to `dimCustomer`

    ![ALT](../images/module02b/029.png)

3. Set the **Source type** to **Inline**

    ![ALT](../images/module02b/030.png)

4. Set the **Inline dataset type** to **Delta**

    ![ALT](../images/module02b/031.png)

5. Set the **Linked Service** to the **Synapse Workspace Default Storage**

    ![ALT](../images/module02b/032.png)

6. Switch to the **Source options** tab and click the **Browse** icon

    ![ALT](../images/module02b/033.png)

7. Navigate to `03-curated > wwi > customers` and click **OK**

    ![ALT](../images/module02b/034.png)

8. Set the **Compression type** to **snappy**

    ![ALT](../images/module02b/035.png)

9. Switch to the **Projection** tab and click **Import schema**

    ![ALT](../images/module02b/036.png)

10. Click **Import**

    ![ALT](../images/module02b/037.png)

11. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/038.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 4. Data flow (Filter - activeCustomers)

In this step, we will **filter** the Customers dimension table to only include rows that are active. This is a necessary step as we will eventually **lookup** which customers are being referenced in the incoming orders data by their `CustomerID`.

1. Click the **[+]** icon to the right of `dimCustomer`, under **Row modifier** select **Filter**

    ![ALT](../images/module02b/039.png)

2. Rename the **Output stream name** to `activeCustomers`

    ![ALT](../images/module02b/040.png)

3. Set the **Filter on** property to `IsActive == 1`

    ![ALT](../images/module02b/041.png)

4. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/042.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 5. Data flow (Lookup - lookupDimCustomer)

The lookup transformation references data from a secondary stream, where there is a match, the step will append columns with the columns from the primary stream. In this step, we will lookup customer records from `activeCustomers` and append matched records with the orders data `rawOrders`.

1. Click the **[+]** icon to the right of `rawOrders`, under **Multiple inputs/outputs** select **Lookup**

    ![ALT](../images/module02b/043.png)

2. Rename the **Output stream name** to `lookupDimCustomer`

    ![ALT](../images/module02b/044.png)

3. Set the **Lookup stream** to `activeCustomers`

    ![ALT](../images/module02b/045.png)

4. Set the **Lookup conditions** to `CustomerID` on both the Left and Right

    ![ALT](../images/module02b/046.png)

5. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/047.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 6. Data flow (Select - selectFactColumns)

In this step, we will use a **select** transformation to drop all columns except `OrderId`, `CustomerSK`, and `Quantity`, reorder `CustomerSK` to the second position, and rename `CustomerSK` to `CustomerKey`.

1. Click the **[+]** icon to the right of `lookupDimCustomer`, under **Schema modifier** select **Select**

    ![ALT](../images/module02b/048.png)

2. Rename the **Output stream name** to `selectFactColumns`

    ![ALT](../images/module02b/049.png)

3. Under the Input columns, delete all columns except `OrderID`, `CustomerSK`, and `Quantity`

    ![ALT](../images/module02b/050.png)

4. On the left hand side of the `CustomerSK`, click and drag the column to the second position

    ![ALT](../images/module02b/051.png)

5. Rename `CustomerSK` to `CustomerKey`

    ![ALT](../images/module02b/052.png)

6. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/053.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 7. Data flow (Derived column - checkForEarlyFacts)

In this step, we are going to update an existing column `CustomerKey` and set it to 0 if the existing value is null.

1. Click the **[+]** icon to the right of `selectFactColumns`, under **Schema modifier** select **Derived Column**

    ![ALT](../images/module02b/054.png)

2. Rename the **Output stream name** to `checkForEarlyFacts`

    ![ALT](../images/module02b/055.png)

3. Under **Columns**, click the **Column** drop-down menu and select `CustomerKey`

    ![ALT](../images/module02b/056.png)

4. Copy and paste the code snippet into the **Expression**

    ```javascript
    iif(isNull(CustomerKey),toLong(0),CustomerKey)
    ```

    ![ALT](../images/module02b/057.png)

5. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/058.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 8. Data flow (Alter row - markAsUpsert)

In this step, we are going to mark all rows from the incoming stream with the **UPSERT** policy.

1. Click the **[+]** icon to the right of `checkForEarlyFacts`, under **Row modifier** select **Alter Row**

    ![ALT](../images/module02b/059.png)

2. Rename the **Output stream name** to `markAsUpsert`

    ![ALT](../images/module02b/060.png)

3. Under **Alter row conditions**, set the condition to **Upsert If** and the expression as `true()`

    ![ALT](../images/module02b/061.png)

4. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/062.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 9. Data flow (Sink - sinkOrders)

In this step, we will write the the results from the incoming stream to the destination Delta Lake table.

1. Click the **[+]** icon to the right of `markAsUpsert`, under **Destination** select **Sink**

    ![ALT](../images/module02b/063.png)

2. Rename the **Output stream name** to `sinkOrders`

    ![ALT](../images/module02b/064.png)

3. Set the **Sink type** to **Inline**

    ![ALT](../images/module02b/065.png)

4. Set the **Inline dataset type** to **Delta**

    ![ALT](../images/module02b/066.png)

5. Set the **Linked Service** to the **Synapse Workspace Default Storage**

    ![ALT](../images/module02b/067.png)

6. Switch to the **Settings** tab and click the **Browse** icon

    ![ALT](../images/module02b/068.png)

7. Navigate to `03-curated > wwi` and click **OK**

    ![ALT](../images/module02b/069.png)

8. Within the **Folder path** property, replace `wwi` with `wwi/orders`

    ![ALT](../images/module02b/070.png)

9. Set the **Compression type** to `snappy`

    ![ALT](../images/module02b/071.png)

10. Set the **Update method** to **Allow insert** and **Allow upsert**

    ![ALT](../images/module02b/072.png)

11. Set the **Key columns** to `OrderID`

    ![ALT](../images/module02b/073.png)

12. Switch to the **Data preview** tab and click **Refresh**

    ![ALT](../images/module02b/074.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 10. Pipeline (pipelineFactIncrementalLoad)

Update the Data Flow activity within the pipeline to pass the pipeline parameter `@pipeline().parameters.fileName` to the Data Flow parameter `fileName`.

1. Navigate back to the pipeline `O2 - pipelineFactIncrementalLoad`

    ![ALT](../images/module02b/075.png)

2. Click to focus on the **Data flow** activity and switch to the **Parameters** tab

    ![ALT](../images/module02b/076.png)

3. Under **Data flow parameters**, click inside the fileName **Value** and select **Pipeline expression**

    ![ALT](../images/module02b/077.png)

4. Copy and paste the code snippet and click **OK**

    ```javascript
    @pipeline().parameters.fileName
    ```

    ![ALT](../images/module02b/078.png)

5. Click **Publish all**

    ![ALT](../images/module02b/079.png)

6. Click **Publish**

    ![ALT](../images/module02b/080.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## 11. Debug Pipeline

To test that our pipeline is working correctly, we will trigger a manual run using the **Debug** capability.

1. Click **Debug**

    ![ALT](../images/module02b/081.png)

2. Set the **fileName** parameter value to the name of an existing CSV file and click **OK**

    ![ALT](../images/module02b/082.png)

3. Periodically click **Refresh** until the pipeline has succeeded

    ![ALT](../images/module02b/083.png)

4. Navigate to the **Data** hub, browse the data lake folder structure to `03-curated > wwi`, right-click the folder `orders`, and select **New SQL Script > Select TOP 100 rows**

    ![ALT](../images/module02b/084.png)

5. Set the **File type** to **Delta format** and click **Apply**

    ![ALT](../images/module02b/085.png)

6. Click **Run**

    ![ALT](../images/module02b/086.png)

<div align="right"><a href="#module-02b---incremental-load-fact">↥ back to top</a></div>

## :tada: Summary

You have successfully setup a pipeline to incrementally load the fact table (Orders) using the Delta Lake format.

## :white_check_mark: Results

Azure Synapse Analytics

- [x] 1 x Pipeline (O2 - pipelineFactIncrementalLoad)
- [x] 1 x Data flow (dataFlowFactIncrementalLoad)

Azure Data Lake Storage Gen2

- [x] 1 x Delta log file (03-curated/wwi/orders/_delta_log)
- [x] 2 x Parquet files (03-curated/wwi/orders)

[Continue >](../modules/module02c.md)
