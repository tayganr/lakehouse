# Module 01A - Incremental Copy to Raw (via CDC)

[< Previous Module](../modules/moduleXX.md) - **[Home](../README.md)** - [Next Module >](../modules/module01b.md)

## :thinking: Prerequisites

* Lab environment deployed
* Post deployment scripts executed
* Access to the Azure Synapse Analytics workspace

## :loudspeaker: Introduction

In this module, we will setup a Synapse Pipeline to incrementally copy data from an OLTP source (Azure SQL Database), leveraging Change Data Capture technology to isolate changes. The data will be copied to the raw layer of our Azure Data Lake Storage Gen2 account.

## :dart: Objectives

* Synapse Pipeline
* Tumbling Window Trigger

## Artifacts

* Linked Service - Azure SQL Database
* Integration Dataset - Azure SQL Database
* Integration Dataset - Azure Data Lake Storage Gen2 
* Pipeline
    * Lookup
    * If Condition (Copy)

## 1. Linked Service

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Manage** hub
3. Click **Linked services**
4. Click **New**
5. Search SQL, select Azure SQL Database, and click **Continue**
6. Select the Azure SQL Database by selecting the **Azure subscription**, **Server name** and **Database name**
7. Set the **Authentication** type to `SQL authentication`
8. Copy and paste the **User name**
```
sqladmin
```
9. Copy and paste the **Password**
```
sqlPassword!
```
10. Click **Test connection**
11. Click **Create**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 2. Heading 2

1. ABC
2. ABC
3. ABC

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## :tada: Summary

ABC.

[Continue >](../modules/module01b.md)