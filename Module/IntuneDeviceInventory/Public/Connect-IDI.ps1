function Connect-IDI {
    <#
    .SYNOPSIS
        Connect to the MSGraph

    .DESCRIPTION
        Connect to the MSGraph
        
    .PARAMETER ClientId
        AppID for connection with MSGraph

    .PARAMETER ClientSecret
        App Secret for connection with MSGraph

    .PARAMETER TenantId
        TenantId for connection with MSGraph

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "AppId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [parameter(Mandatory = $false, HelpMessage = "TenantId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,

        [parameter(Mandatory = $false, HelpMessage = "App Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret
    )

    if($ClientId -and $ClientSecret -and $TenantId){
        Write-Verbose "Graph connection via Azure App, Tenant: $TenantId"
        $authority = "https://login.windows.net/$TenantId"
        Update-MSGraphEnvironment -AppId $ClientId -Quiet
        Update-MSGraphEnvironment -AuthUrl $authority -Quiet
        Connect-MSGraph -ClientSecret $ClientSecret -Quiet
        Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet

    }else{
        Write-Verbose "Graph connection via user authentification"
        $MSGraph = Connect-MSGraph
        Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
        Write-Verbose $MSGraph
    } 
}