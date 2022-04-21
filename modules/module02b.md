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
2. Under **Pipelines**, click on the ellipsis **[...]** icon to the right of the Customers folder and select **New pipeline**
3. Rename the pipeline to `O2 - pipelineFactIncrementalLoad`
4. Under **Parameters**, click **New**
5. Set the name of the parameter to `fileName`
6. Within Activities, search for `Data flow`, and drag the **Data flow activity** onto the canvas
7. Rename the activity `incrementalLoadFact`
8. Switch to the **Settings** tab
9. Next to the **Data flow** property, click **New**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 2. Heading 2

1. ABC
2. ABC
3. ABC

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## :tada: Summary

ABC.

[Continue >](../modules/module03.md)