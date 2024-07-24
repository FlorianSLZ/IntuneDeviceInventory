function Invoke-IDIDeviceDefenderScan {

        <#
        .SYNOPSIS
            Trigger Defender Scan for Intune device(s)
    
        .DESCRIPTION
            Trigger Defender Scan for Intune device(s)
            
        .PARAMETER IDIDevice
            Array of the device to trigger a Defender Scan
    
        .PARAMETER Group
            Trigger Defender Scan for Intune Devices within a specific group
    
        .PARAMETER User
            Trigger Defender Scan for Intune Devices from a specific user (UPN)
    
        .PARAMETER deviceName
            Trigger Defender Scan for Intune Devices by name
    
        .PARAMETER id
            Trigger Defender Scan for Intune Devices by id (deviceID)
    
        .PARAMETER azureADDeviceId
            Trigger Defender Scan for Intune Device by azureADDeviceId
    
        .PARAMETER All
            Trigger Defender Scan for all Intune Devices
    
        .PARAMETER Grid
            Switch to select Intune Devices to trigger a Defender Scan out of a GridView
    
        #>
    
        param (
            [parameter(Mandatory = $false, HelpMessage = "Array of the device to trigger a Defender Scan")]
            [ValidateNotNullOrEmpty()]
            [array]$IDIDevice,
    
            [parameter(Mandatory = $false, HelpMessage = "Trigger Defender Scan for Intune Devices within a specific group")]
            [ValidateNotNullOrEmpty()]
            [string]$Group,
    
            [parameter(Mandatory = $false, HelpMessage = "Trigger Defender Scan for Intune Devices from a specific user (UPN)")]
            [ValidateNotNullOrEmpty()]
            [string]$User,
    
            [parameter(Mandatory = $false, HelpMessage = "Trigger Defender Scan for Intune Devices by Device Name")]
            [ValidateNotNullOrEmpty()]
            [string]$deviceName,
    
            [parameter(Mandatory = $false, HelpMessage = "Trigger Defender Scan for Intune Devices by id")]
            [ValidateNotNullOrEmpty()]
            [string]$id,
    
            [parameter(Mandatory = $false, HelpMessage = "Trigger Defender Scan for Intune Devices by azureADDeviceId")]
            [ValidateNotNullOrEmpty()]
            [string]$azureADDeviceId,
    
            [parameter(Mandatory = $false, HelpMessage = "Trigger Defender Scan for all Intune Devices")]
            [ValidateNotNullOrEmpty()]
            [switch]$All,
    
            [parameter(Mandatory = $false, HelpMessage = "Switch to select Intune Devices to trigger a Defender Scan out of a GridView")]
            [ValidateNotNullOrEmpty()]
            [switch]$Grid
    
        )
    
        
        if($All){
            if($global:IDIDevices_all){$global:IDIDevices_all | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}}
            else{Get-noneIDIDevice -All | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}}
            
        }elseif($Group){
            Get-noneIDIDevice -Group "$Group" | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}
            
        }elseif($User){
            Get-noneIDIDevice -User "$User" | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}
            
        }elseif($deviceName){
            Get-noneIDIDevice -deviceName "$deviceName" | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}
            
        }elseif($id){
            Get-noneIDIDevice -id "$id" | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}
            
        }elseif($azureADDeviceId){
            Get-noneIDIDevice -azureADDeviceId "$azureADDeviceId" | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}
            
        }elseif($Grid){
            if($global:IDIDevices_all){
                $Devices2Sync = $global:IDIDevices_all | Out-GridView -Title "Please select your devices" -OutputMode Multiple
                $Devices2Sync | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}
            }
            else{Get-noneIDIDevice -Grid | ForEach-Object{ Invoke-IDIDeviceDefenderScan -IDIDevice $_}}
            
        }elseif($IDIDevice){
            Write-Verbose "Trigger Defender Scan for device with id: $($IDIDevice.id) ..."
            $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($IDIDevice.id)')/windowsDefenderScan"
            Invoke-MgGraphRequest -Uri $uri -Method POST
        }else{
            Write-Warning "No device or scope for Invoke-IDIDeviceDefenderScan specified."
        }
    }
