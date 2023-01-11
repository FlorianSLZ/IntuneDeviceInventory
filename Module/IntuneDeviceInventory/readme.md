|Florian Salzmann|[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)|
|----------------|-------------------------------|
|**Jannik Reinhard**|[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/jannik_reinhard)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/jannik-r/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://jannikreinhard.com/)|

# IntuneDeviceInventory (IDI)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneDeviceInventory)

This module was created to have the ability to add more pieces of information to a Microsoft Intune device object. 
In addition, there are some functions to bulk initiate Intune commands like a Sync for devices. 


## Installing the module from PSGallery

The IntuneWin32App module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/IntuneDeviceInventory). Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name IntuneDeviceInventory
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be different in your case*
```PowerShell
Import-Module -Name "C:\GitHub\IntuneDeviceInventory\Module\IntuneDeviceInventory" -Verbose -Force
```

## Module dependencies

IntuneDeviceInventory module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Intune

# Functions / Examples

Here are all functions and some examples to start with:

- Add-IDIProperty
- Backup-IDI
- Connect-IDI
- ConvertTo-IDINotes
- Get-IDIDevice
- Get-IDIDeviceNotes
- Get-noneIDIDevice
- Get-noneIDIReference
- Import-IDIAppConnection
- Invoke-IDIDeviceBitLockerRotation
- Invoke-IDIDeviceDefenderScan
- Invoke-IDIDeviceDefenderSignatures
- Invoke-IDIDeviceDelete
- Invoke-IDIDeviceRestart
- Invoke-IDIDeviceRetire
- Invoke-IDIDeviceSync
- Invoke-IDIDeviceWipe
- Invoke-PagingRequest
- New-IDIApp
- Remove-IDIAppConnection
- Restore-IDI
- Save-IDIAppConnection
- Set-IDIDevice
- Set-IDIDeviceNotes
- Start-IDI
- Test-4IDIDevices

## Authentication
Before using any of the functions within this module that interacts with Graph API, ensure you are authenticated. 

### User Authentication
With this command, you'll be connected to the Graph API and be able to use all commands
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
### Get Devices

```PowerShell
# Get all devices with notes
Get-IDIDevice -All

# Get all devices without notes
Get-noneIDIDevice -All
```

### Adding a Prperty

```PowerShell
Add-IDIProperty -PropertyName "Monitor"
```

### Managing a Device

```PowerShell
# Select the device
$Device2edit = $IDIDevices_all | Out-GridView -OutputMode Single

# Set Device Property
$Device2edit.Monitor = 'Samsung Odyssey G9'

# Update Device in Intune with changes
Set-IDIDevice -IDIDevice $Device2edit
```

### Converting none IDI notes

If you already have any notes filed up, you can convert them into "IDI-notes", so that they are compatible with all the commands and the custom fields. 
```PowerShell
# Convert notes of a single device
ConvertTo-IDINotes -DeviceId 892582d8-xxxx-xxxx-xxxx-afe0ada8b8d2 -PropertyName "purchase date"

# Convert all notes
## if notes from a device are already compatible, they won't be processed
ConvertTo-IDINotes -All -PropertyName "purchase date"
```
## Backup & Restore
If you have a lot of infos in your custom field fore sure you wat to bakup them. 
The Backup is stored in a JSON file. 
The Backup&Restore functiuonality also works in a Tenant to Teannt migration.

```PowerShell
# Backup current configuration (if no path is specified, it will be stored in the users temp)
Backup-IDI

# Restore previosly backuped configuration (same tenant)
Restore-IDI -Path "C:\...\backup.json"

# Restore to a new tenant, devices will match by serialnumber
Restore-IDI -Path "C:\...\backup.json" -serial
```

## Bulk commands

With the bulk commands (starting with Invoke-) you chan easily perform INtune bulk actions for selected devices. 

### Sync all devices

```PowerShell
Invoke-IDIDeviceSync -All
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

### Trigger Wipe for device name

```PowerShell
Invoke-IDIDeviceWipe -deviceName 'dev-w10-01'

# or to wipe witout asking
Invoke-IDIDeviceWipe -deviceName 'dev-w10-01' -Force
```

## Azure AD Applications
With Azure AD Applications you have the possibility to access all features without a user login. 
You will need either a Global Administrator or Application Administrator to register the app in Azure. 

Permissions for the application:
- DeviceManagementManagedDevices.PrivilegedOperations.All
- DeviceManagementManagedDevices.ReadWrite.All
- Group.Read.All
- GroupMember.Read.All
- Organization.Read.All
- User.Read.All

### Creating a Azure AD Applications
For creating a new App or secret you can use **New-IDIApp**. The only thing you have to do after the creation process is to give admin consent for the permissions. 
*The consent is only needed when creating a new app, not when adding a client secret*
```PowerShell
# Creates a new App and shows connection details
# login required
New-IDIApp

# Creates a new App and saves the details encrypted in the users AppData:
#   ("C:\Users\%username%\AppData\Local\IntuneDeviceInventory\AppConnection\TenantId.connection")
New-IDIApp -Save

# Creates a new App and saves the details encrypted in the users AppData
# -Force creates a new secret if the app already exists
New-IDIApp -Save -Force
```

![New-IDIApp](https://scloud.work/wp-content/uploads/2022/11/IDI_New-IDIApp.png)
![Admin consent](https://scloud.work/wp-content/uploads/2022/11/IDI_Grant-admin-consent.png)


### manually save Azure AD Applications details
If you already have an app/secret you can save the connection details manually:
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