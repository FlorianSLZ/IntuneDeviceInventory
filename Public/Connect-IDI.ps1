function Connect-IDI {
    <#
    .SYNOPSIS
        Connect to the MSGraph

    .DESCRIPTION
        Connect to the MSGraph
        
    .PARAMETER AppID
        AppID for connection with MSGraph

    .PARAMETER AppSecret
        App Secret for connection with MSGraph

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "AppID for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$AppID,

        [parameter(Mandatory = $false, HelpMessage = "App Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$AppSecret
    )

    if($AppID -and $AppSecret){
        Write-Error "tbd... please use Connect-IDI without parameters"
    }else{
        Connect-MSGraph
        Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet
        Connect-MSGraph -Quiet
    } 
}