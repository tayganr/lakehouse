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

<div align="right"><a href="#module-02b---incremental-load-dimension-scd-type-2">↥ back to top</a></div>

## :tada: Summary

TBC.

[Continue >](../modules/module03.md)