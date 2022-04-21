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

* Create a Power BI report
* Connect to the Serverless SQL endpoint
* Consume data from the logical data warehouse
* Publish the Power BI report

## 1. Connect Power BI to Azure Synapse Analytics

1. Open Power BI Desktop
2. Click **Get data**
3. Search `Synapse`, select **Azure Synapse Analytics SQL**, and click **Connect**
4. Open the [Azure Portal](https://portal.azure.com), navigate to the **Synapse Workspace** resource, and copy the **Serverless SQL endpoint**
5. Return to Power BI Desktop, paste the Serverless SQL endpoint within the **Server** property, set **Data connectivity mode** to **Import**, and click **OK**
6. Expand the `ldw` database, select `wwi.customers` and `wwi.orders`, and click **Load**
7. Switch to the **Model** view and create a relationship between the `SurrogateKey` in `wwi.Customers` and the `CustomerKey` in `wwi.Orders`
8. Revert back to the **Report** view

## 2. Data Visualization #1: Table

1. From the **Visualizations** pane, click the **Table** icon
2. From the **Fields** pane, select `OrderID`, `CustomerID`, `CustomerAddress`, and `Quantity`
3. Within the **Visualizations** pane, under **Values**, right-click on `OrderID` and select **Don't summarize**
4. Within the **Visualizations** pane, under **Values**, right-click on `CustomerID` and select **Don't summarize**
5. Within the **Visualizations** pane, switch to the **Format visual** sub-pane, click the **General** tab, and enable **Title**
6. Set the **Title** to `Orders`

<div align="right"><a href="#module-04---data-visualization-with-power-bi">↥ back to top</a></div>

## 3. Data Visualization #2: Chart

1. From the **Visualizations** pane, click the **Stacked bar chart** icon
2. From the **Fields** pane, select `CustomerAddress` and `Quantity`
3. Within the **Visualizations** pane, switch to the **Format visual** sub-pane
4. Expand the **Y-axis** and set the **Max area width** to `50%`
5. Set **Data labels** to `ON`
6. Expand the **X-axis**, turn the **Title** `Off`, then turn the **X-axis** `Off`

<div align="right"><a href="#module-04---data-visualization-with-power-bi">↥ back to top</a></div>

## 4. Save and Publish

1. Under **Home**, click **Publish**
2. When prompted to save changes, click **Save**. Note: You may be prompted to set a Sensitivity Label prior to being able to save.
3. Provide the Power BI report a file name and click **Save**
4. Select `My workspace` and click **Select**
5. Once published, click the hyperlink to open the report in Power BI

<div align="right"><a href="#module-04---data-visualization-with-power-bi">↥ back to top</a></div>

## :tada: Summary

You have successfully created a Power BI report, consuming data from the data lakehouse using Azure Synapse Analytics.
