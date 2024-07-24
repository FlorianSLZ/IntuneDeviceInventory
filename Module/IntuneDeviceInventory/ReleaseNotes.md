# Release notes for IntuneDeviceInventory module

## 1.3.0
Moved away from Microsoft.Graph.Intune Module

## 1.2.0
Added Backup & Restore functions:
- Backup-IDI
- Restore-IDI

## 1.1.1
Minor fixes

## 1.1.0
Added *-Progress* to Get-IDIDevices to show the process of reading notes

Added Invoke functions with Major impact:
- Invoke-IDIDeviceWipe
- Invoke-IDIDeviceRetire
- Invoke-IDIDeviceDelete

## 1.0.1
- minor changes
- "-Verbose" optimization

## 1.0.0
This is the relese after testing and optimizing varios funtions. 

Added functions:
- ConvertTo-IDINotes

## 0.1.3
Added functions:
- Import-IDIAppConnection
- Invoke-PagingRequest
- New-IDIApp
- Save-IDIAppConnection

Improved funtions:
- Connect-IDI 
    - Support for Azure AD App authentification
- Get-IDIDevices
    - Support for 1000+ Devices

## 0.1.2
Added functions:
- Get-IDIDeviceNotes
- Invoke-IDIDeviceBitLockerRotation
- Invoke-IDIDeviceDefenderScan
- Invoke-IDIDeviceDefenderSignatures
- Invoke-IDIDeviceRestart
- Invoke-IDIDeviceSync (changed from Sync-IDIDevice)
- Set-IDIDeviceNotes
- Start-IDI

## 0.1.1
Fixes and performance optimisation

## 0.1.0
- Initial release, se README.md for documentation.