[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)

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
Import-Module -Name "C:\GitHub\IntuneDeviceInventory" -Verbose
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
- Invoke-IDIDeviceBitLockerRotation
- Invoke-IDIDeviceDefenderScan
- Invoke-IDIDeviceDefenderSignatures
- Invoke-IDIDeviceRestart
- Invoke-IDIDeviceSync
- Set-IDIDevice
- Set-IDIDeviceNotes
- Start-IDI
- Test-4IDIDevices

## Authentication
Before using any of the functions within this module that interacts with Graph API, ensure you are autheticated. 

### Simple Authentication
With this command you'll be connected to the Graph API and be able to use all commands
```PowerShell
Connect-IDI
```

### Authentication with Starting IDI
With this command you'll be connected to the Graph API and be able to use all commands. 
In addition all Devices will be in the global Variable '$global:IDIDevices_all' from where you chan edit each individual device. 
```PowerShell
Start-IDI
```

## Basic commands
### Get Devices (inc. custom fields)
```PowerShell
# Ge all devices
Get-IDIDevices -All


```

## Adding a Prperty
```PowerShell
Add-IDIProperty -PropertyName "Monitor"
```

## Managing a Device

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
