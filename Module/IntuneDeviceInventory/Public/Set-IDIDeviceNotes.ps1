function Set-IDIDeviceNotes{
    
    <#
    .SYNOPSIS
        Set/Update device with changed properties (Notes field)

    .DESCRIPTION
        Set/Update device with changed properties (Notes field)
        
    .PARAMETER IDIDevice
        Array of the device to set/update

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Array of the device to set/update")]
        [ValidateNotNullOrEmpty()]
        [array]$IDIDevice

    )
    try{
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
    
        Invoke-MgGraphRequest -Uri $uri -Method PATCH -Body $Json

    }catch{
        Write-Error $_
    }

}
