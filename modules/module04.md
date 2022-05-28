# Module 04 - Data Visualization with Power BI

[< Previous Module](../modules/module03.md) - **[Home](../README.md)**

## :thinking: Prerequisites

- [x] Lab environment deployed
- [x] Module 1D complete
- [x] Module 2C complete
- [x] Module 3 complete
- [x] [Power BI Desktop](https://aka.ms/pbiSingleInstaller)

## :loudspeaker: Introduction

In this module, we will develop and publish a Power BI report based on data from our logical data warehouse.

## :dart: Objectives

- Create a Power BI report
- Connect to the Serverless SQL endpoint
- Consume data from the logical data warehouse
- Publish the Power BI report

## Table of Contents

1. Connect Power BI to Azure Synapse Analytics
2. Data Visualization #1: Table
3. Data Visualization #2: Chart
4. Save and Publish

## 1. Connect Power BI to Azure Synapse Analytics

1. Open Power BI Desktop

    ![ALT](../images/module04/001.png)

2. Click **Get data**

    ![ALT](../images/module04/002.png)

3. Search `Synapse`, select **Azure Synapse Analytics SQL**, and click **Connect**

    ![ALT](../images/module04/003.png)

4. Open the [Azure Portal](https://portal.azure.com), navigate to the **Synapse Workspace** resource, and copy the **Serverless SQL endpoint**

    ![ALT](../images/module04/004.png)

5. Return to Power BI Desktop, paste the Serverless SQL endpoint within the **Server** property, set **Data connectivity mode** to **Import**, and click **OK**

    ![ALT](../images/module04/005.png)

6. Sign-in with your **Microsoft account** and click **Connect**

    ![ALT](../images/module04/006.png)

7. Expand the `ldw` database, select `wwi.customers` and `wwi.orders`, and click **Load**

    ![ALT](../images/module04/007.png)

8. Switch to the **Model** view and create a relationship between the `CustomerSK` in `wwi.Customers` and the `CustomerKey` in `wwi.Orders`

    ![ALT](../images/module04/008.png)

9. Revert back to the **Report** view

    ![ALT](../images/module04/009.png)

## 2. Data Visualization #1: Table

1. From the **Visualizations** pane, click the **Table** icon

    ![ALT](../images/module04/010.png)

2. From the **Fields** pane, select `OrderID`, `CustomerID`, `CustomerAddress`, and `Quantity`

    ![ALT](../images/module04/011.png)

3. Within the **Visualizations** pane, under **Values**, right-click on `OrderID` and select **Don't summarize**

    ![ALT](../images/module04/012.png)

4. Within the **Visualizations** pane, under **Values**, right-click on `CustomerID` and select **Don't summarize**

    ![ALT](../images/module04/013.png)

5. Within the **Visualizations** pane, switch to the **Format visual** sub-pane, click the **General** tab, enable **Title**, and set the **Title** to `Orders`

    ![ALT](../images/module04/014.png)

<div align="right"><a href="#module-04---data-visualization-with-power-bi">↥ back to top</a></div>

## 3. Data Visualization #2: Chart

1. From the **Visualizations** pane, click the **Stacked bar chart** icon

    ![ALT](../images/module04/015.png)

2. From the **Fields** pane, select `CustomerAddress` and `Quantity`

    ![ALT](../images/module04/016.png)

3. Within the **Visualizations** pane, switch to the **Format visual** sub-pane, expand the **Y-axis** and set the **Max area width** to `50%`

    ![ALT](../images/module04/017.png)

4. Set **Data labels** to `ON`

    ![ALT](../images/module04/018.png)

5. Expand the **X-axis**, turn the **Title** `Off`, then turn the **X-axis** `Off`

    ![ALT](../images/module04/019.png)

<div align="right"><a href="#module-04---data-visualization-with-power-bi">↥ back to top</a></div>

## 4. Save and Publish

1. Under **Home**, click **Publish**

    ![ALT](../images/module04/020.png)

2. When prompted to save changes, click **Save**. Note: You may be prompted to set a Sensitivity Label prior to being able to save.

    ![ALT](../images/module04/021.png)

3. Provide the Power BI report a file name (e.g. `Data Lakehouse Workshop`) and click **Save**

    ![ALT](../images/module04/024.png)

4. Select `My workspace` and click **Select**

    ![ALT](../images/module04/022.png)

5. Once published, click the hyperlink to open the report in Power BI

    ![ALT](../images/module04/023.png)

<div align="right"><a href="#module-04---data-visualization-with-power-bi">↥ back to top</a></div>

## :tada: Summary

You have successfully created a Power BI report, consuming data from the data lakehouse using Azure Synapse Analytics.
