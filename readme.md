[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.
com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)

[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/jannik_reinhard)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/jannik-r/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://jannikreinhard.com/)

# IntuneDeviceInventory (IDI)

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneDeviceInventory)

This module was created to have the ablility to add more informations to a Microsoft Intune device object. 
In addition there are some funtions to bulk initiate Intune commands like a Sync for devices. 


## Installing the module from PSGallery

The IntuneWin32App module is published to the PowerShell Gallery. Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name IntuneDeviceInventory
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be diffent in your case*
```PowerShell
Import-Module -Name "C:\GitHub\IntuneDeviceInventory" -Verbose -Force
```

## Module dependencies

IntuneDeviceInventory module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Intune

# Functions / Examples

Here are all functions and some examples to start with

- Add-IDIProperty
- Connect-IDI
- Get-IDIDevice
- Get-IDIDeviceNotes
- Get-noneIDIReference
- Import-IDIAppConnection
- Invoke-IDIDeviceBitLockerRotation
- Invoke-IDIDeviceDefenderScan
- Invoke-IDIDeviceDefenderSignatures
- Invoke-IDIDeviceRestart
- Invoke-IDIDeviceSync
- Invoke-PagingRequest
- New-IDIApp
- Save-IDIAppConnection
- Set-IDIDevice
- Set-IDIDeviceNotes
- Start-IDI
- Test-4IDIDevices

## Authentication
Before using any of the functions within this module that interacts with Graph API, ensure you are autheticated. 

### User Authentication
With this command you'll be connected to the Graph API and be able to use all commands
```PowerShell
# Authentication as User
Connect-IDI

# Authentication via Azure App
Connect-IDI -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret

# Authentication with a saved Azure App
Import-IDIAppConnection -TenantId $TenantId -Connect
## Authentication with a saved Azure App (if you have multiple and want to select)
Import-IDIAppConnection -Select -Connect
```

## Basic commands
### Get Devices (inc. custom fields)

```PowerShell
# Ge all devices
Get-IDIDevices -All
```

### Adding a Prperty

```PowerShell
Add-IDIProperty -PropertyName "Monitor"
```

### Managing a Device

```PowerShell
# Select the devicre
$Device2edit = $IDIDevices_all | Out-GridView -OutputMode Single

# Set Device Property
$Device2edit.Monitor = 'Samsung Odyssey G9 49"'

# Update Device in Intune with changes
Set-IDIDevice -IDIDevice $Device2edit
```

## Bulk commands

With the bulk commands (starting with Invoke-) you chan easily perform INtune bulkactions for selected devices. 

### Sync all devices

```PowerShell
Invoke-IDIDeviceSync -all
```

### Reboot devices from group

```PowerShell
Invoke-IDIDeviceRestart -Group "DEV-WIN-Pilot" # replace DEV-WIN-Pilot with your group name
```

### Trigger Defender Scan for selected devices (GridView)

```PowerShell
Invoke-IDIDeviceDefenderScan -Grid
```

### Trigger Defender Signatures update for device name

```PowerShell
Invoke-IDIDeviceDefenderSignatures -deviceName 'dev-w11-01'
```
## Azure AD Applications
With Azure AD Applications you have the posibillity to access all features witout a user login. 
You will need either Global Administrator or Application Administrator to register the app in Azure. 

Permissions for the application:
- DeviceManagementManagedDevices.PrivilegedOperations.All
- DeviceManagementManagedDevices.ReadWrite.All
- Group.Read.All
- GroupMember.Read.All

### Creating a Azure AD Applications
For creating an new App or secret you can use **New-IDIApp**. The only thing you have to do after the creation process is to give a admin consent for the permissions. 
*The consent is only needed when creating a new app, not when addin a clientsecret*
```PowerShell
# Creates a new App and shows connection details
# login required
New-IDIApp

# Creates a new App and saves the details encrypted in the users AppData:
#   ("C:\Users\florian.salzmann\AppData\Local\IntuneDeviceInventory\AppConnection\TenantId.connection")
New-IDIApp -Save

# Creates a new App and saves the details encrypted in the users AppData
# -Force creates a new secret if the app already exists
New-IDIApp -Save -Force
```

![New-IDIApp](https://scloud.work/wp-content/uploads/2022/11/IDI_New-IDIApp.png)
![Admin consent](https://scloud.work/wp-content/uploads/2022/11/IDI_Grant-admin-consent.png)


### manually save Azure AD Applications details
If you already have an app/secret you can save the connection details manuelly:
```PowerShell
Save-IDIAppConnection -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret
```

### Get saved App connections

```PowerShell
# list all a saved Azure App connections
Import-IDIAppConnection -All

# Authentication with a saved Azure App
Import-IDIAppConnection -TenantId $TenantId

## Authentication with a saved Azure App (if you have multiple and want to select)
Import-IDIAppConnection -Select
```