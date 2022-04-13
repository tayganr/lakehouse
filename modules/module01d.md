# Module 01D - Automation using Triggers

[< Previous Module](../modules/module01c.md) - **[Home](../README.md)** - [Next Module >](../modules/module02a.md)

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Post deployment scripts executed
- [x] Module 1A complete
- [x] Module 1B complete
- [x] Module 1C complete

## :loudspeaker: Introduction

In this module, we will automate ingestion and loading of Customer data using triggers.

## :dart: Objectives

* Periodically copy changes from source using a Tumbling Window trigger.
* On the arrival of new files in the data lake, incrementally load the dimension table using a Storage Event trigger.

## 1. Trigger (Storage event)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Integrate** hub
3. Open the pipeline `C1 - pipelineIncrementalCopyCDC`
4. Click **Add trigger**
5. Click **New/Edit**
6. Click **Choose trigger...**
7. Click **New**
8. Rename the trigger to `triggerStorageEvent`
9. Set the **Type** to **Storage events**
10. Set the **Azure subscription** to the Azure subscription that contains your Azure Data Lake Storage Gen2 account
11. Set the **Storage account name** to the Azure Data Lake Storage Gen2 account name
12. Set the **Container name** via the drop-down menu to `01-raw`
13. Set the **Blob path begins** with to `wwi/customers`
14. Set the **Blob path ends with** to `.csv`
15. Set the **Event** to `Blob created`
16. Click **Continue**
17. Click **Continue**
18. Set the **Trigger Run Parameter** (fileName) to `@trigger().outputs.body.fileName`
19. Click OK
20. Click **Publish all**
21. Click **Publish**

<div align="right"><a href="#module-01a---incremental-copy-to-raw-via-cdc">↥ back to top</a></div>

## :tada: Summary

You have automated the execution of the Customer pipelines using triggers.

[Continue >](../modules/module02a.md)