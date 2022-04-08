# Module 02 - Incremental Load Dimension (SCD Type 2)

[< Previous Module](../modules/module01b.md) - **[Home](../README.md)** - [Next Module >](../modules/module03.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Post deployment scripts executed
- [x] Module 1A complete

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally load data from our raw layer (CSV), into our curated layer (Delta Lake) as a SCD Type 2 dimension table.

## :dart: Objectives

* Create a pipeline that will perform the initial load.
* Create a pipeline that will incrementally load data as new files arrive.

## 1. Pipeline (initialLoad)

1. Navigate to the **Integrate** hub
2. Click the **[+]** icon to add a new resource and click **Pipeline**
3. Rename the pipeline to `pipelineDimInitialLoad`
4. Within Activities, search for `Get Metadata`, and drag the **Get Metadata activity** onto the canvas
5. Rename the activity `getFiles`
6. Switch to the **Settings** tab
7. Set the **Source dataset** to **AdlsRawDelimitedText**
8. Set the Dataset property **folderPath** to `wwi/customers`
9. Set the Dataset property **fileName** to `/`
10. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas
11. Rename the activity `initialLoad`
12. Click **New**

<div align="right"><a href="#module-02---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## 2. Data flow (Source - rawCustomer)

1. Enabel **Data flow debug**
2. Rename the data flow `dataFlowDimInitialLoad` and click **OK**
3. Under **Parameters**, click **New**
4. Rename **parameter1** to `fileName`
5. Click **Add Source**
6. Rename the source **Output stream name** to `rawCustomer`
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

<div align="right"><a href="#module-02---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## :tada: Summary

ABC.

[Continue >](../modules/module03.md)