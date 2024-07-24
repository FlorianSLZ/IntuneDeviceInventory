function Invoke-PagingRequest {

    <#
    .SYNOPSIS
        Invoke Graph API reguest with paging

    .DESCRIPTION
        Invoke Graph API reguest with paging
        
    .PARAMETER URI
        Graph API uri

    .PARAMETER Method
        Graph API methode


    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Array of the device to trigger an Intune Device sync")]
        [ValidateNotNullOrEmpty()]
        [string]$URI,

        [parameter(Mandatory = $true, HelpMessage = "Get Intune Devices within a specific group")]
        [ValidateNotNullOrEmpty()]
        [string]$Method

    )

    $GraphResponse = Invoke-MgGraphRequest -Method $Method -Uri $uri

    $GraphResponseCollection = $GraphResponse.value 
    $UserNextLink = $GraphResponse."@odata.nextLink"


    while($UserNextLink -ne $null){

        $GraphResponse = (Invoke-MgGraphRequest -Uri $UserNextLink -Method $Method)
        $UserNextLink = $GraphResponse."@odata.nextLink"
        $GraphResponseCollection += $GraphResponse.value

    }

    return $GraphResponseCollection
   
}