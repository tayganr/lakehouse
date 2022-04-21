# Module 02B - Incremental Load Fact

[< Previous Module](../modules/module02a.md) - **[Home](../README.md)** - [Next Module >](../modules/module03.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Post deployment steps complete
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

## :tada: Summary

ABC.

[Continue >](../modules/module03.md)