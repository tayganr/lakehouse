# How to Register a Resource Provider

[< Previous Module](./azurepass.md) - **[Home](./README.md)** - [Next Module >](./modules/module00.md)

## :stopwatch: Estimated Duration

10 minutes

## :thinking: Prerequisites

* An Azure subscription

## :loudspeaker: Introduction

TBC

## Initialize Cloud Shell

1. In the Azure Portal, click the **Cloud Shell** icon.
1. Set the **Subscription** to target Azure Subscription (e.g. `Azure Pass - Sponsorship`).
1. Click **Create storage**

    ![ALT](./images/providers/001.png)


## Initialize Cloud Shell

1. Hover your mouse over the code snippet below and click **Copy** button.

```powershell
$uri = "https://raw.githubusercontent.com/tayganr/lakehouse/main/template/lakehouselab.ps1"
Invoke-WebRequest $uri -OutFile "preDeploymentScript.ps1"
./preDeploymentScript.ps1
Write-Host "You can now close Cloud Shell"
```

2. Right-click within Cloud Shell, and click **Paste**.

![ALT](./images/providers/002.png)

3. d

## :tada: Summary

You have successfully registered all the required resource providers.

[Continue >](./modules/module00.md)
