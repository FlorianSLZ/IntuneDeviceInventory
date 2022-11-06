function Set-IDIDevice{
    
    <#
    .SYNOPSIS
        Set/Update device with changed properties (Notes field)

    .DESCRIPTION
        Set/Update device with changed properties (Notes field)
        
    .PARAMETER IDIDevice
        Array of the device to set/update

    .PARAMETER all
        Switch to run command for all devices

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Array of the device to set/update")]
        [ValidateNotNullOrEmpty()]
        [array]$IDIDevice,

        [parameter(Mandatory = $false, HelpMessage = "Switch to run command for all devices")]
        [ValidateNotNullOrEmpty()]
        [switch]$all

    )


    if($all){
        $global:IDIDevices_all | ForEach-Object{ Set-IDIDevice -IDIDevice $_} 
    }elseif(!$IDIDevice){
        Write-Warning "No device specified."
    }else{
        Set-IDIDeviceNotes -IDIDevice $IDIDevice
    }
}
