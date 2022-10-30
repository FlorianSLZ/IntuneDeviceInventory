function Invoke-IDIDeviceRestart {

    <#
    .SYNOPSIS
        Trigger device restart in Intune

    .DESCRIPTION
        Trigger device restart in Intune
        
    .PARAMETER IDIDevice
        Array of the device to restart

    .PARAMETER Group
        Restart Intune Devices within a specific group

    .PARAMETER User
        Restart Intune Devices from a specific user (UPN)

    .PARAMETER deviceName
        Restart Intune Devices by name

    .PARAMETER id
        Restart Intune Devices by id (deviceID)

    .PARAMETER azureADDeviceId
        Restart Intune Device by azureADDeviceId

    .PARAMETER All
        Restart all Intune Devices

    .PARAMETER Grid
        Switch to select Intune Devices to restart out of a GridView

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Array of the device to trigger an restart")]
        [ValidateNotNullOrEmpty()]
        [array]$IDIDevice,

        [parameter(Mandatory = $false, HelpMessage = "Restart Intune Devices within a specific group")]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [parameter(Mandatory = $false, HelpMessage = "Restart Intune Devices from a specific user (UPN)")]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [parameter(Mandatory = $false, HelpMessage = "Restart Intune Devices by Device Name")]
        [ValidateNotNullOrEmpty()]
        [string]$deviceName,

        [parameter(Mandatory = $false, HelpMessage = "Restart Intune Devices by id")]
        [ValidateNotNullOrEmpty()]
        [string]$id,

        [parameter(Mandatory = $false, HelpMessage = "Restart Intune Devices by azureADDeviceId")]
        [ValidateNotNullOrEmpty()]
        [string]$azureADDeviceId,

        [parameter(Mandatory = $false, HelpMessage = "Restart all Intune Devices")]
        [ValidateNotNullOrEmpty()]
        [switch]$All,

        [parameter(Mandatory = $false, HelpMessage = "Switch to select Intune Devices to restart out of a GridView")]
        [ValidateNotNullOrEmpty()]
        [switch]$Grid

    )

    
    if($All){
        if($global:IDIDevices_all){$global:IDIDevices_all | ForEach-Object{ Invoke-IDIDevice -IDIDevice $_}}
        else{Get-noneIDIDevice -All | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}}
        
    }elseif($Group){
        Get-noneIDIDevice -Group "$Group" | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}
        
    }elseif($User){
        Get-noneIDIDevice -User "$User" | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}
        
    }elseif($deviceName){
        Get-noneIDIDevice -deviceName "$deviceName" | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}
        
    }elseif($id){
        Get-noneIDIDevice -id "$id" | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}
        
    }elseif($azureADDeviceId){
        Get-noneIDIDevice -azureADDeviceId "$azureADDeviceId" | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}
        
    }elseif($Grid){
        if($global:IDIDevices_all){
            $Devices2Sync = $global:IDIDevices_all | Out-GridView -Title "Please select your devices" -OutputMode Multiple
            $Devices2Sync | ForEach-Object{ Invoke-IDIDevice -IDIDevice $_}
        }
        else{Get-noneIDIDevice -Grid | ForEach-Object{ Invoke-IDIDeviceRestart -IDIDevice $_}}
        
    }elseif($IDIDevice){
        Write-Verbose "Trigger restart for device with id: $($IDIDevice.id) ..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($IDIDevice.id)')/microsoft.graph.rebootNow"
        Invoke-MSGraphRequest -Url $uri -HttpMethod POST
    }else{
        Write-Warning "No device or scope for Invoke-IDIDeviceRestart specified."
    }
}