function Save-IDIAppConnection {
    <#
    .SYNOPSIS
        Save the App Connection details

    .DESCRIPTION
        Save the App Connection details
        
    .PARAMETER ClientId
        ClientID for connection with MSGraph

    .PARAMETER TenantId
        TenantId for connection with MSGraph

    .PARAMETER ClientSecret
        ClientSecret for connection with MSGraph

    .PARAMETER Path
        Path where the App Connection details will be saved

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "ClientId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [parameter(Mandatory = $true, HelpMessage = "TenantId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,

        [parameter(Mandatory = $true, HelpMessage = "Client Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,

        [parameter(Mandatory = $false, HelpMessage = "Path where the App connections are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$env:LocalAppData\IntuneDeviceInventory\AppConnection\$TenantId.connection"
    )


    Write-Verbose "Create and save connection details for $TenantId ..."
    # Creat Connection Infos
    $AADApp_connection = New-Object psobject -Property @{
        TenantId = $TenantId;
        ClientId = $ClientId;
        ClientSecret = $($ClientSecret | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)
    }

    New-Item -ItemType Directory -Path "$env:LocalAppData\IntuneDeviceInventory\AppConnection\" -Force | Out-Null
    Export-Clixml -InputObject $AADApp_connection -Path $Path -Force


}