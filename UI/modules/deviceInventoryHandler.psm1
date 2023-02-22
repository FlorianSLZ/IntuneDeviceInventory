<#
Version: 1.0
Author: Florian Salzman (scloud.work) / Jannik Reinhard (jannikreinhard.com)
Script: deviceInventoryHandler
Description:
Handel the intune devie inventory functions
Release notes:
1.0 :
- Init
#>

function Install-IdiModule{
    $IntuneDeviceInventory = Get-InstalledModule -Name "IntuneDeviceInventory" -ErrorAction SilentlyContinue
    try{
        if(-not ($IntuneDeviceInventory)){
        Install-Module -Name IntuneDeviceInventory -Scope CurrentUser -Confirm:$false -Force
        }
    }catch{
        Write-Error "Failed to install Intune Device Inventory from Powershell gallery: $_"
        return $false
    }
    return $true
}
function Get-AllDevices{
    try{
        return Get-IDIDevice -All
    }catch{
        Write-Error "Failed to get all devices: $_"
        return $false
    }
}

function Get-RefresDevices{
    $global:allDevices = Get-AllDevices
    $allDevicesGrid = Add-DevicesToGridObject -devices $global:allDevices
    Add-DevicesToGrid -devices $allDevicesGrid
}

function Get-RefreshSingleDevice($Device){
    $index = $global:allDevices.id.IndexOf($Device.id)
    $global:allDevices[$index] = $Device
    $allDevicesGrid = Add-DevicesToGridObject -devices $global:allDevices
    Add-DevicesToGrid -devices $allDevicesGrid
}


function Add-DevicesToGridObject {
    param (
        [Parameter(Mandatory = $true)] $devices
    )
    $managedDevicesGridObjects = @()

    $referenceObject = (Get-noneIDIReference).PSObject.Properties.Name
    $devices | ForEach-Object {
        try{
            $customInventory = @(($_ | Select-Object -Property * -ExcludeProperty $referenceObject).PSObject.Properties | Select-Object -Property Value, Name)
            foreach($item in $customInventory){
                $item | Add-Member -MemberType NoteProperty -Name "Changed" -Value $null
                $item | Add-Member -MemberType NoteProperty -Name "UpdateAttribute" -Value $false
                $item | Add-Member -MemberType NoteProperty -Name "InitValue" -Value $item.Value
                $item | Add-Member -MemberType NoteProperty -Name "InitName" -Value $item.Name

                if($item.Name -eq '*'){
                    $item.Name = 'New Attribute'
                    $item.InitName  = $item.Name
                    $item.Value  = 'Add a value'
                    $item.InitValue  = $item.Value
                    $item.Changed  = '(*)'
                }
            }
        }catch{}

        $param = [PSCustomObject]@{
          Id                    = $_.id
          AzureAdId             = $_.azureActiveDirectoryDeviceId
          DeviceName            = $_.deviceName
          DeviceManagedBy       = if($_.managementAgent -eq 'MDM'){'Intune'}else{$_.managementType}
          DeviceOwnership       = switch ($_.ownerType) {company {'Corporate'}  personal{'Personal'} Default {$_.ownerType}}
          DeviceCompliance      = if($_.complianceState -eq 'noncompliant'){'Not Compliant'}else{'Compliant'}
          DeviceOS              = switch ($_.deviceType) {windowsRT {'Windows'}  macMDM{'macOS'} Default {$_.deviceType}}
          DeviceOSVersion       = $_.osVersion
          DeviceLastCheckin     = $_.lastSyncDateTime
          DevicePrimaryUser     = $_.userPrincipalName
          CustomInventory       = $customInventory
          Details               = ($_ | Select-Object -Property $referenceObject)
        }
        $managedDevicesGridObjects += $param
    }
    return $managedDevicesGridObjects
}