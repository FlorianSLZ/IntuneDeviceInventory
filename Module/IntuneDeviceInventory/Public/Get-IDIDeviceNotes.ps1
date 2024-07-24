function Get-IDIDeviceNotes{
    <#
    .SYNOPSIS
        Get Intune Device and compile notes (json) into the output

    .DESCRIPTION
        Get Intune Device and compile notes (json) into the output

    .PARAMETER IDIDevice
        Array of the device to get the notes from

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Array of the device to get the notes from")]
        [ValidateNotNullOrEmpty()]
        [array]$IDIDevice
    
    )

    # Get notes field
    $Notes = @()
    $Resource = "deviceManagement/managedDevices('$($IDIDevice.id)')"
    $properties = 'notes'
    $uri = "https://graph.microsoft.com/beta/$($Resource)?select=$properties"
    $Notes = (Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop).notes

    if($Notes){
        try{
            $Notes = $Notes | Convertfrom-Json

            # add Properties to main collection & this client
            foreach($property in $Notes[0].PSObject.Properties){
                if($global:IDIDevices_all){
                    if (-not ($global:IDIDevices_all | Get-Member -Name $property.Name)){
                        $global:IDIDevices_all | Add-Member -NotePropertyName $property.Name -NotePropertyValue $null
                    }
                }
                
                $IDIDevice | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value -Force

            }
        }catch{
            Write-Error "Notes of $($IDIDevice.id) are not compatible with the IntuneDeviceInventory. `nRun the following command to convert them:`nConvertTo-IDINotes -DeviceId $($IDIDevice.id)"
        }
        
    }
    return $IDIDevice

}