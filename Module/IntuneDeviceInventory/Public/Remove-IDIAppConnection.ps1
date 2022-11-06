function Remove-IDIAppConnection {
    <#
    .SYNOPSIS
        Save the App Connection details

    .DESCRIPTION
        Save the App Connection details
        
    .PARAMETER All
        Switch to delete all App connections

    .PARAMETER TenantId
        TenantId for connection with MSGraph

    .PARAMETER Path
        Path where the App connections are stored

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "TenantId of the App connection")]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId = "*",

        [parameter(Mandatory = $false, HelpMessage = "Switch to delete all App connections")]
        [ValidateNotNullOrEmpty()]
        [switch]$All,

        [parameter(Mandatory = $false, HelpMessage = "Path where the App connections are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$env:LocalAppData\IntuneDeviceInventory\AppConnection\$TenantId.connection"
    )

    if($All){
        Write-Verbose "Removing all App connections: $Path"
        Remove-Item -Path "$Path" -Force
    }else{
        Write-Verbose "Removing App connection: $Path"
        Remove-Item -Path "$Path" -Force
    }
}