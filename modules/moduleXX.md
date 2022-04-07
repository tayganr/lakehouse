# Module 00 - Post Deployment Script

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

## 2. SQL Scripts

The following SQL scripts will setup our source tables, enable change data capture, and prepare objects needed to facilitate watermark based ETL.

1. Navigate to the **SQL database**
2. Click **Query editor**
3. Click **Continue us <your_alias>@microsoft.com**
4. Copy and paste the code snippets below and click **Run**

    Snippet 1 of 4
    ```sql
    -- Tables
    CREATE TABLE Customers (
        CustomerID int IDENTITY(1,1) PRIMARY KEY,
        CustomerAddress varchar(255) NOT NULL
    );
    CREATE TABLE Orders (
        OrderID int IDENTITY(1,1) PRIMARY KEY,
        CustomerID int FOREIGN KEY REFERENCES Customers(CustomerID),
        Quantity int NOT NULL,
        OrderDateTime DATETIME default CURRENT_TIMESTAMP,
        LastModifiedDateTime DATETIME default CURRENT_TIMESTAMP
    );
    CREATE TABLE Watermark (
        TableName varchar(255),
        Watermark DATETIME
    );
    INSERT INTO dbo.Watermark
    VALUES
    ('dbo.Orders', '1/1/2022 12:00:00 AM');

    -- CDC
    EXEC sys.sp_cdc_enable_db;
    EXEC sys.sp_cdc_enable_table  
        @source_schema = N'dbo',  
        @source_name   = N'Customers',  
        @role_name     = NULL,
        @supports_net_changes = 1;

    -- Load Data
    INSERT INTO dbo.Customers (CustomerAddress)
    VALUES
        ('82 Margate Drive, Sheffield S4 8FQ'),
        ('135 High Barns, Ely, CB7 4RH'),
        ('39 Queen Annes Drive, Bedale, DL8 2EL');
    ```

    Snippet 2 of 4
    ```sql
    -- Trigger will fire whenever an UPDATE occurs on dbo.Orders to update LastModifiedDateTime
    CREATE TRIGGER trg_orders_update_modified
    ON dbo.Orders
    AFTER UPDATE 
    AS
        UPDATE dbo.Orders
        SET LastModifiedDateTime = CURRENT_TIMESTAMP
        FROM Inserted i
        WHERE dbo.Orders.OrderID = i.OrderID;
    ```

    Snippet 3 of 4
    ```sql
    -- Stored Procedure will be used by ETL to track high watermark
    CREATE PROCEDURE sp_update_watermark @LastModifiedtime datetime, @TableName varchar(50)
    AS
        UPDATE watermarktable
        SET [Watermark] = @LastModifiedtime
        WHERE [TableName] = @TableName;
    ```

    Snippet 4 of 4
    ```sql
    -- Load dbo.Orders now that LastModifiedDateTime trigger is available
    INSERT INTO dbo.Orders (CustomerID, Quantity)
    VALUES
        (1,38),
        (2,27),
        (3,16),
        (1,52);
    ```

5. Validate that dbo.Customers and dbo.Orders contain data by copying and pasting the code below.

    ```sql
    SELECT * FROM dbo.Customers
    ```

    ```sql
    SELECT * FROM dbo.Orders
    ```

## 3. RBAC Role Assignment (Contributor)

This role assignment is required to ensure that your account has sufficient permissions (Owner or Contributor) to setup Synapse Pipelines that can be triggered from file events (e.g. Blob Created, Blob Updated).

1. Navigate to the **Storage account**
2. Select **Access Control (IAM)**
3. Click **Add role assignment**
4. Select `Contributor` and click **Next**
5. Click **Select members**
6. Search for your account, select your account, click **Select** 
7. Click **Review + assign**
8. Click **Review + assign**

## 4. RBAC Role Assignment (Storage Blob Data Reader)

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