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
        $id = $IDIDevice.id
        $Notesonly = $($IDIDevice[0] | Convertto-Json) | Convertfrom-Json
        $RefProperties = (Get-noneIDIReference).PSObject.Properties.Name
        foreach($Property in $RefProperties){
            $Notesonly[0].PSObject.Properties.Remove("$Property")
        } 
        Write-Verbose "Update Device $id"
        Write-Verbose "  Properties: $($Notesonly.PSObject.Properties.Name)"

        #Update the notes of the device
        $Note_json = $Notesonly | Convertto-Json
        $Json = @{ "notes" = "$Note_json" } 
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$id')"

        $MSGraphRequest =  Invoke-MSGraphRequest -Url $uri -HttpMethod PATCH -Content $Json
        Write-Verbose "$MSGraphRequest"
    }
}
