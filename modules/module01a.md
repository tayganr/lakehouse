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

## 1. Linked Service (Azure SQL Database)

1. Open Azure Synapse Analytics workspace
2. Navigate to the **Manage** hub
3. Click **Linked services**
4. Click **New**
5. Search `SQL`, select **Azure SQL Database**, and click **Continue**
6. Select the target Azure SQL Database by selecting the **Azure subscription**, **Server name** and **Database name**
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

## 2. Integration Dataset (Azure SQL Database - Table)

1. Navigate to the **Data** hub
2. Switch to the **Linked** tab
3. Click the **[+]** icon to add a new resource and click **Integration dataset**
4. Search `SQL`, select **Azure SQL Database**, and click **Continue** 
5. Select the Linked service `AzureSqlDatabase`
6. Click **OK**
7. Switch the the **Parameters** tab
8. Click **New**
9. Set the Name to `schema`
10. Click **New**
11. Set the Name to `table`
12. Switch to the **Connection** tab
13. Click **Edit**
14. Click inside the first text input for **Table** and click **Add dynamic content**
15. Under **Parameters**, click `schema`
16. Click **OK**
17. Click inside the second text input for **Table** and click **Add dynamic content**
18. Under **Parameters**, click `table`
19. Click **OK**
20. Click **Publish all**
21. Click **Publish**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 3. Integration Dataset (Azure Data Lake Storage Gen2 - Raw)

1. Navigate to the **Data** hub
2. Switch to the **Linked** tab
3. Click the **[+]** icon to add a new resource and click **Integration dataset**
4. Search `Data Lake`, select **Azure Data Lake Storage Gen2**, and click **Continue** 
5. Select **DelimitedText** and click **Continue**
6. Rename the integration dataset to `AdlsRawDelimitedText`
7. Select the Azure Synapse Analytics workspace default storage **Linked service**
8. Click the **browse** icon
9. Select `01-raw`
10. Click **OK**
11. Select **First row as header**
12. Click **OK**
13. Switch to the **Parameters** tab
14. Click **New**
15. Set the Name to `folderPath`
16. Click **New**
17. Set the Name to `fileName`
18. Switch to the **Connection** tab
19. Click inside the `Directory` text input and click **Add dynamic content**
20. Under **Parameters**, click `folderPath`
21. Click **OK**
22. Click inside the `File` text input and click **Add dynamic content**
23. Under **Parameters**, click `fileName`
24. Click **OK**
25. Click **Publish all**
26. Click **Publish**

<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## 4. Pipeline (Copy SQL to ADLS)

1. Navigate to the **Integrate** hub
2. Click the **[+]** icon to add a new resource and click **Pipeline**
3. Within Activities, search for `Lookup`, and drag the **Lookup activity** onto the canvas
4. Rename the activity `GetChangeCount`
5. Switch to the **Settings** tab
6. Set the **Source dataset** to **AzureSqlTable**
7. Set the Dataset property **schema** to `cdc`
8. Set the Dataset property **table** to `dbo_Customers_CT`
9. Set the **Use query** property to **Query**
10. Click inside the **Query** text input and click **Add dynamic content** 
11. Copy and paste the code snippet
```
@concat('DECLARE @begin_time datetime, @end_time datetime, @from_lsn binary(10), @to_lsn binary(10); 
SET @begin_time = ''',pipeline().parameters.triggerStartTime,''';
SET @end_time = ''',pipeline().parameters.triggerEndTime,''';
SET @from_lsn = sys.fn_cdc_map_time_to_lsn(''smallest greater than or equal'', @begin_time);
SET @to_lsn = sys.fn_cdc_map_time_to_lsn(''largest less than'', @end_time);
IF (@from_lsn IS NOT NULL AND @to_lsn IS NOT NULL AND @from_lsn < @to_lsn)
SELECT count(1) changecount FROM cdc.fn_cdc_get_net_changes_dbo_Customers(@from_lsn, @to_lsn, ''all'')
ELSE SELECT 0 changecount')
```
12. Click **OK**


<div align="right"><a href="#module-01---tbd">↥ back to top</a></div>

## :tada: Summary

ABC.

[Continue >](../modules/module01b.md)