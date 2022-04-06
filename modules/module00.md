# Module 00 - Lab Environment Setup

**[Home](../README.md)** - [Next Module >](../modules/module01.md)

## :thinking: Prerequisites

* An [Azure account](https://azure.microsoft.com/en-us/free/) with an active subscription.
* Owner permissions within a Resource Group to create resources and manage role assignments.
* The subscription must have the following resource providers registered.
    * Microsoft.Authorization
    * Microsoft.EventGrid
    * Microsoft.Sql
    * Microsoft.Storage
    * Microsoft.Synapse

## :loudspeaker: Introduction

In order to follow along with the lab exercises, we need to provision a set of resources.

## :test_tube: Lab Environment Setup

1. Right-click or `Ctrl + click` the button below to open the Azure Portal in a new window.

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftayganr%2Flakehouse%2Fmain%2Ftemplate%2Fazuredeploy.json)

2. Beneath the **Resource group** field, click **Create new** and provide a unique name (e.g. `lakehouse-rg`), select a valid location (e.g. `West Europe`), and then click **Review + create**.

3. Once the validation has passed, click **Create**.

4. The deployment should take approximately 5 minutes to complete. Once you see the message **Your deployment is complete**, click **Go to resource group**.

## :tada: Summary

By successfully deploying the lab template, you have the Azure resources needed to follow along with the learning exercises.

[Continue >](../modules/module01.md)