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
        Write-Verbose "Graph connection via Entra App, Tenant: $TenantId"
        $ClientSecretCredential = New-Object System.Management.Automation.PSCredential ($ClientId, $(ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
        Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential

    }else{
        # Disconnect old session
        if($(Get-MgContext).AppName){   
            Write-Host "Kill old Graph Session"
            Disconnect-Graph    
        }

        Write-Verbose "Graph connection via user authentification"
        $MSGraph = Connect-MgGraph -Scopes "User.Read.All", "Device.Read.All", "DeviceManagementManagedDevices.ReadWrite.All", "DeviceManagementServiceConfig.ReadWrite.All", "GroupMember.ReadWrite.All" 
        Write-Verbose $MSGraph

    } 
}