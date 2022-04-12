# Module 02A - Initial Load Dimension

[< Previous Module](../modules/module01b.md) - **[Home](../README.md)** - [Next Module >](../modules/module02b.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Post deployment scripts executed
- [x] Module 1A complete

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to load data from our raw layer (CSV), into our curated layer (Delta Lake).

## :dart: Objectives

* Create a pipeline that will perform the initial load.

## 1. Pipeline (initialLoad)

1. Navigate to the **Integrate** hub
2. Under **Pipelines**, click on the ellipsis **[...]** icon to the right of the **Customers** folder and select **New pipeline**
3. Rename the pipeline to `C2 - pipelineDimInitialLoad`
4. Within Activities, search for `Get Metadata`, and drag the **Get Metadata activity** onto the canvas
5. Rename the activity `getFiles`
6. Switch to the **Settings** tab
7. Set the **Source dataset** to **AdlsRawDelimitedText**
8. Set the Dataset property **folderPath** to `wwi/customers`
9. Set the Dataset property **fileName** to `/`
10. Next to the **Field list** property, click **New**
11. Open the **Argument** drop-down menu and select **Child items**
12. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas
13. Click and drag on the green button on the previous **Get Metadata** activity (`getFiles`) to establish a connection to the **Data flow** activity
14. Rename the activity `initialLoad`
15. Switch to the **Settings** tab
16. Next to the **Data flow** drop-down menu, click **New**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 2. Data flow (Source - rawCustomer)

1. Enable **Data flow debug**
2. Rename the data flow `dataFlowDimInitialLoad` and click **OK**
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
19. Click **Import schema**. Note: You may need to wait for the Data flow debug session to be ready before the button will become clickable.
20. Click **Import**
21. Under **Data flow parameters**, set the **fileName** property to an existing CSV file that resides within `01-raw > wwi > customers`.
    * Tip: In a new window, open the Azure Portal, navigate to the storage account, and use the Storage Browser to find an existing file.
    * Note: The string must be wrapped in single quotes.
22. Click **Save**
23. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 2. Data flow (Surrogate Key)

1. Click the **[+]** icon to add a new step, under **Schema modifier** select **Surrogate Key**
2. Rename the **Output stream name** to `surrogateKey`
3. Set the **Key column** to `SurrogateKey`
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 3. Data flow (Derived Column)

1. Click the **[+]** icon to add a new step, under **Schema modifier** select **Derived Column**
2. Rename the **Output stream name** to `derivedColumnsSCD`
3. Under **Columns**, set the first **Column** to `IsActive` and the **Expression** to `1`
4. Click **Add** and select **Add column**
5. Set the second **Column** to `ValidFrom` and the **Expression** to `currentTimestamp()`
6. Click **Add** and select **Add column**
7. Set the third **Column** to `ValidTo` and the **Expression** to `toTimestamp('9999-12-31 00:00:00')`
8. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 4. Data flow (Select)

1. Click the **[+]** icon to add a new step, under **Schema modifier** select **Select**
2. Rename the **Output stream name** to `reorderColumns`
3. Under **Input columns**, click and drag the **SurrogateKey** column to be in the first position
4. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 5. Data flow (Sink)

1. Click the **[+]** icon to add a new step, under **Destination** select **Sink**
2. Rename the **Output stream name** to `curatedCustomer`
3. Set the **Sink type** to **Inline**
4. Set the **Inline dataset type** to **Delta**
5. Set the **Linked Service** to the Synapse Workspace Default Storage.
6. Switch to the **Settings** tab
7. Click the **Browse** icon
8. Navigate to `03-curated` and click **OK**
9. Click inside the **Folder path** text input and set the value to `wwi/customers`
10. Set the **Compression type** to **snappy**
11. Set the **Table action** to **Truncate**
12. Switch to the **Data preview** tab and click **Refresh**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 6. Pipeline (initialLoad)

1. Navigate back to the **pipeline**, click to focus on the **Data flow** step
2. Switch to the **Parameters** tab
3. Under **Data flow parameters**, click the **value** field for the **fileName** parameter, and select **Pipeline expression**
4. Copy and paste the code snippet
```
@activity('getFiles').output.childItems[0].name
```
5. Click **OK**
6. Click **Publish all**
7. Click **Publish**
8. Click **Debug**
9. Click **OK**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## 7. Query Delta Lake

1. Navigate to the **Data** hub
2. Browse the data lake folder structure to `03-curated > wwi > customers`
3. Right-click one of the **parquet** files, select **New SQL Script > Select TOP 100 rows**
4. Modify the **OPENROWSET** function to remove the file name from the **BULK** path
5. Change the **FORMAT** to **DELTA**
6. Click **Run**

<div align="right"><a href="#module-02a---initial-load-dimension">↥ back to top</a></div>

## :tada: Summary

You have successfully setup a pipeline to initialise the dimension table (Customer) in the Delta Lake format.

[Continue >](../modules/module02b.md)