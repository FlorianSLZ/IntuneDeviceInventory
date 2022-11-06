function Add-IDIProperty{
    
    <#
    .SYNOPSIS
        Add a new property to the device collection. 

    .DESCRIPTION
        Add a new property to the device collection. 

    .PARAMETER PropertyName
        Specify the name of the new property. (Will be stored in the devices notes field)

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the name of the new property.")]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyName
    )

    if($ObjNotes.PSObject.Properties.Name -contains $PropertyName){ 
        Write-Warning "Property already present"
    }
    else{
        $global:IDIDevices_all | Add-Member -NotePropertyName $PropertyName -NotePropertyValue $null
    }
}