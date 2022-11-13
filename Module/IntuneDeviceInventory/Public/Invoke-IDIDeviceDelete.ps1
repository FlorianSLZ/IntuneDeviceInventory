function Invoke-IDIDeviceDelete {

    <#
    .SYNOPSIS
        Delete Intune devices (single or bulk)

    .DESCRIPTION
        Delete Intune devices (single or bulk)
    
    .PARAMETER IDIDevice
        Array of the device to trigger

    .PARAMETER Group
        Trigger Intune Devices within a specific group

    .PARAMETER User
        Trigger Intune Devices from a specific user (UPN)

    .PARAMETER deviceName
        Trigger Intune Devices by name

    .PARAMETER id
        Trigger Intune Devices by id (deviceID)

    .PARAMETER azureADDeviceId
        Trigger Intune Device by azureADDeviceId

    .PARAMETER All
        Trigger all Intune Devices

    .PARAMETER Grid
        Switch to select Intune Devices out of a GridView

    .PARAMETER Force
        Retire without asking for each device

    #>

    param (

        [parameter(Mandatory = $false, HelpMessage = "Array of the device to trigger")]
        [ValidateNotNullOrEmpty()]
        [array]$IDIDevice,

        [parameter(Mandatory = $false, HelpMessage = "Trigger Intune Devices within a specific group")]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [parameter(Mandatory = $false, HelpMessage = "Trigger Intune Devices from a specific primary user (UPN)")]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [parameter(Mandatory = $false, HelpMessage = "Trigger Intune Devices by Device Name")]
        [ValidateNotNullOrEmpty()]
        [string]$deviceName,

        [parameter(Mandatory = $false, HelpMessage = "Trigger Intune Devices by id")]
        [ValidateNotNullOrEmpty()]
        [string]$id,

        [parameter(Mandatory = $false, HelpMessage = "Trigger Intune Devices by azureADDeviceId")]
        [ValidateNotNullOrEmpty()]
        [string]$azureADDeviceId,

        [parameter(Mandatory = $false, HelpMessage = "Trigger all Intune Devices")]
        [ValidateNotNullOrEmpty()]
        [switch]$All,

        [parameter(Mandatory = $false, HelpMessage = "Switch to select Intune Devices out of a GridView")]
        [ValidateNotNullOrEmpty()]
        [switch]$Grid,

        [parameter(Mandatory = $false, HelpMessage = "Delete without asking for each device")]
        [ValidateNotNullOrEmpty()]
        [switch]$Force

    )

    
    if($All){
        if($global:IDIDevices_all){$global:IDIDevices_all | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}}
        else{Get-noneIDIDevice -All | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}}
        
    }elseif($Group){
        Get-noneIDIDevice -Group "$Group" | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}
        
    }elseif($User){
        Get-noneIDIDevice -User "$User" | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}
        
    }elseif($deviceName){
        Get-noneIDIDevice -deviceName "$deviceName" | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}
        
    }elseif($id){
        Get-noneIDIDevice -id "$id" | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}
        
    }elseif($azureADDeviceId){
        Get-noneIDIDevice -azureADDeviceId "$azureADDeviceId" | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}
        
    }elseif($Grid){
        if($global:IDIDevices_all){
            $Devices2Sync = $global:IDIDevices_all | Out-GridView -Title "Please select your devices" -OutputMode Multiple
            $Devices2Sync | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}
        }
        else{Get-noneIDIDevice -Grid | ForEach-Object{ Invoke-IDIDeviceDelete -IDIDevice $_}}
        
    }elseif($IDIDevice){

        if(!$Force){
            $RunMajor = Read-Host "Are you sure you want to delete Device $($IDIDevice.id) (Y/N)"
            if($RunMajor -ne "Y"){break}
        }

        Write-Verbose "Deleting device with id: $($IDIDevice.id) ..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($IDIDevice.id)')"
        Invoke-MSGraphRequest -Url $uri -HttpMethod DELETE
    }else{
        Write-Warning "No device or scope for Invoke-IDIDeviceDelete specified."
    }
}
