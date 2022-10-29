function Sync-IDIDevice {

    <#
    .SYNOPSIS
        Trigger device Sync in Intune

    .DESCRIPTION
        Trigger device Sync in Intune
        
    .PARAMETER IDIDevice
        Array of the device to set/update

    .PARAMETER all
        Switch to run command for all devices

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Array of the device to trigger an Intune sync")]
        [ValidateNotNullOrEmpty()]
        [array]$IDIDevice,

        [parameter(Mandatory = $false, HelpMessage = "Switch to run command for all devices")]
        [ValidateNotNullOrEmpty()]
        [switch]$all

    )
    
    if($all){
        Test-4IDIDevices
        $global:IDIDevices_all | ForEach-Object{ Sync-IDIDevice -IDIDevice $_} 
    }elseif(!$IDIDevice){
        Write-Warning "No device specified."
    }else{
        # trigger device sync
        $Note_json = $Notesonly | Convertto-Json
        $Json = @{ "notes" = "$Note_json" } 
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($IDIDevice.id)')/syncDevice"

        $MSGraphRequest =  Invoke-MSGraphRequest -Url $uri -HttpMethod POST -Content $Json
        Write-Verbose "$MSGraphRequest"
    }
}