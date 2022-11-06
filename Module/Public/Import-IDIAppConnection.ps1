function Import-IDIAppConnection {
    <#
    .SYNOPSIS
        Get the App Connection details

    .DESCRIPTION
        Get the App Connection details
        
    .PARAMETER ClientId
        AppID for connection with MSGraph

    .PARAMETER TenantId
        TenantId for connection with MSGraph

    .PARAMETER ClientSecret
        ClientSecret for connection with MSGraph

    .PARAMETER Path
        Path where the App Connection details are stored

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "App Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$env:LocalAppData\IntuneDeviceInventory\AppConnection",

        [parameter(Mandatory = $false, HelpMessage = "App Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [switch]$All,

        [parameter(Mandatory = $false, HelpMessage = "Select one connection to import from -All")]
        [ValidateNotNullOrEmpty()]
        [switch]$Select,

        [parameter(Mandatory = $false, HelpMessage = "Connect with the selected connection")]
        [ValidateNotNullOrEmpty()]
        [bool]$Connect = $true,

        [parameter(Mandatory = $false, HelpMessage = "TenantId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId
    )

    if($All){
        Write-Verbose "Retriving all connections from: $Path"
        $Connections_all = (Get-ChildItem $Path | Where-Object{$_.Name -like "*.connection"}).BaseName
        return $Connections_all

    }elseif($Select){
        Write-Verbose "Open GridView to select one connection"
        $Tenant2connect = Import-IDIAppConnection -All | Out-GridView -OutputMode Single
        if($Connect -eq $true){
            Import-IDIAppConnection -TenantId $Tenant2connect 
        }else{
            Import-IDIAppConnection -TenantId $Tenant2connect -Connect $false
        }

    }elseif($TenantId){
        Write-Verbose "Import connection details for $TenantId"
        $Connections_selected = Import-Clixml -Path "$Path\$TenantId.connection"

        # inverte SecureString
        $ClientSecret_SS = ConvertTo-SecureString $Connections_selected.ClientSecret
        $ClientSecret_BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientSecret_ss)
        $Connections_selected.ClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ClientSecret_BSTR)

        if($Connect -eq $true){
            Connect-IDI -ClientId $Connections_selected.ClientId -TenantId $Connections_selected.TenantId -ClientSecret $Connections_selected.ClientSecret
        }else{
            return $Connections_selected
        }
        
    }else{
        Write-Warning "No parameter specified"
    }
}