function Get-noneIDIReference{
    <#
    .SYNOPSIS
        Get ReferenceDevice to determine custom fields. 

    .DESCRIPTION
        Get ReferenceDevice to determine custom fields.

    #>

    if(!$global:ReferenceDevice){
        Write-Verbose "Get first managed Devices as reference from Intune..."
        $uri = 'https://graph.microsoft.com/beta/deviceManagement/managedDevices?$top=1'
        $global:ReferenceDevice = (Invoke-MgGraphRequest -Method GET -Url $uri).value | Select-Object -First 1
    }
    return $global:ReferenceDevice
}