<#
.SYNOPSIS
Hadeling IDI
.DESCRIPTION
Handling of IDI
.NOTES
  Author: Jannik Reinhard
#>

function Get-IDIAuthenticated{
    $IntuneDeviceInventory = Get-InstalledModule -Name "IntuneDeviceInventory" -ErrorAction SilentlyContinue
    try{
        if(-not ($IntuneDeviceInventory)){
            Install-Module -Name IntuneDeviceInventory -Scope CurrentUser -Confirm:$false -Force
        }
    }catch{
        Write-Error "Failed to install Intune Device Inventory from Powershell gallery: $_"
        return $false
    }

    try {
        Connect-IDI
    }
    catch {
        Write-Error "Failed to authenticate on Graph: $_"
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
                if($item.Name -eq '*'){
                    $item.Name = 'New Attribute'
                    $item.Value  = 'Add a value'
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