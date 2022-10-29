[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)

# IntuneDeviceInventory (PowerShell Module)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneDeviceInventory)

This module was created to have the ablility to add more informations to a Microsoft Intune device object. 
In addition there are some funtions to bulk initiate Intune commands like a Sync for devices. 


## Installing the module from PSGallery
The IntuneWin32App module is published to the PowerShell Gallery. Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name IntuneDeviceInventory
```
## Module dependencies
IntuneDeviceInventory module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Intune

# Examples
Here are some examples to start with

## Authentication
Before using any of the functions within this module that interacts with Graph API, ensure that an authentication token is acquired using the following command:
```PowerShell
Connect-IDI
```

## Get all Devices (inc. custom fields)

```PowerShell
$All = Get-IDIDevices
```

## Adding a Prperty

```PowerShell
Add-IDIProperty -PropertyName "Monitor"
```

## Get a Singel device

```PowerShell
$Device2change = $All | Out-GridView -OutputMode Single
```

## Set Device Property

```PowerShell
$Device2change.Monitor = "Samsung Odyssey ARK"
```

## Update Device in Intune with changes

```PowerShell
Set-IDIDevice -IDIDevice $Device2change
```

## Sync all devices

```PowerShell
Sync-IDIDevice -all
```
