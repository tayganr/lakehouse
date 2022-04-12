# Module 00 - Post Deployment

 [< Previous Module](../modules/module00.md) - **[Home](../README.md)** - [Next Module >](../modules/module01a.md)

## :thinking: Prerequisites

* Access to the Azure Portal.

## :loudspeaker: Introduction

Now that the Azure resources are deployed, we can proceed to prepare the demo environment.

## 1. Set Azure AD admin

The following steps will elevate your account as an Azure AD administrator of the logical SQL Server hosting the Azure SQL Database.

1. Navigate to the **SQL server**
2. Select **Azure Active Directory**
3. Click **Set admin**
4. Search for your account, select your account, click **Select** 
5. Click **Save**

## 2. RBAC Role Assignment (Storage Account > Contributor)

This role assignment is required to ensure that your account has sufficient permissions (Owner or Contributor) to setup Synapse Pipelines that can be triggered from file events (e.g. Blob Created, Blob Updated).

1. Navigate to the **Storage account**
2. Select **Access Control (IAM)**
3. Click **Add role assignment**
4. Select `Contributor` and click **Next**
5. Click **Select members**
6. Search for your account, select your account, click **Select** 
7. Click **Review + assign**
8. Click **Review + assign**

## 3. RBAC Role Assignment (Storage Account > Storage Blob Data Reader)

This role assignment is required to read files from the data lake using Azure Synapse Analytics built-in serverless SQL technology.

1. Navigate to the **Storage account**
2. Select **Access Control (IAM)**
3. Click **Add role assignment**
4. Select `Storage Blob Data Reader` and click **Next**
5. Click **Select members**
6. Search for your account, select your account, click **Select** 
7. Click **Review + assign**
8. Click **Review + assign**

## :tada: Summary

You have successfully executed the post deployment script.

[Continue >](../modules/module01a.md)