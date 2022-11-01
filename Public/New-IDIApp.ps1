function New-IDIApp {
    <#
    .SYNOPSIS
        Create App regestration for Graph API access

    .DESCRIPTION
        Create App regestration for Graph API access
        
    .PARAMETER AppName
        AppID for connection with MSGraph

    .PARAMETER Save
        App Secret for connection with MSGraph

    #>

    param(
        [parameter(Mandatory = $false, HelpMessage = "The friendly name of the app registration")]
        [ValidateNotNullOrEmpty()]
        [String]$AppName = "IntuneDeviceInventory",

        [parameter(Mandatory = $false, HelpMessage = "If used, app credentials will be saved (Save-IDIAppConnection)")]
        [ValidateNotNullOrEmpty()]
        [switch]$Save,

        [parameter(Mandatory = $false, HelpMessage = "Forces new Key if app exists")]
        [ValidateNotNullOrEmpty()]
        [switch]$Force,

        [parameter(Mandatory = $false, HelpMessage = "App Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    Write-Verbose "Checking / installing AzureAD Module ..."
    try{  
        if (!$(Get-Module -ListAvailable -Name "AzureAD*" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing Module: AzureAD"
            Install-Module "AzureAD" -Scope CurrentUser -Force
        }

    }catch{
        Write-Error $_
        break
    }

    $AADConnection = Connect-AzureAD

    if(!($AADApp_obj = Get-AzureADApplication -Filter "DisplayName eq '$($AppName)'"  -ErrorAction SilentlyContinue)){
        $AADApp_obj = New-AzureADApplication -DisplayName $AppName -AvailableToOtherTenants $false
        Write-Verbose $AADApp_obj 

        # Add Permissions
        # Get current: (Get-AzureADApplication -Filter "DisplayName eq '$($AppName)'").RequiredResourceAccess | ConvertTo-Json -Depth 3
        Write-Verbose "Permissions will be set, Admin consent still required"
    $Permissions = '
{
    "ResourceAppId":  "00000003-0000-0000-c000-000000000000",
    "ResourceAccess":  [
                            {
                                "Id":  "5b567255-7703-4780-807c-7be8301ae99b",
                                "Type":  "Role"
                            },
                            {
                                "Id":  "5b07b0dd-2377-4e44-a38d-703f09a0dc3c",
                                "Type":  "Role"
                            },
                            {
                                "Id":  "243333ab-4d21-40cb-a475-36241daa0842",
                                "Type":  "Role"
                            },
                            {
                                "Id":  "98830695-27a2-44f7-8c18-0c3ebc9698f6",
                                "Type":  "Role"
                            }
                        ]
}
' | ConvertFrom-Json
    
        Set-AzureADApplication -ObjectId $AADApp_obj.ObjectId -RequiredResourceAccess $Permissions
        Write-Warning "Permission set, please open the app in AzureAD and provide a admin consent"
        Write-Output "App URL: https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/$($AADApp_obj.AppId)"

    }elseif($Force){
        Write-Verbose "A App with the Name $AppName aready exists. A new key will be createt"
    }else{
        Write-Warning "A App with the Name $AppName aready exists. Use -Force to create new key"
        break
    }
    


    $AADApp_creds = New-AzureADApplicationPasswordCredential -CustomKeyIdentifier PrimarySecret -ObjectId $AADApp_obj.ObjectId -EndDate ((Get-Date).AddYears(2))
    # Creat Connection Infos
    $AADApp_connection = New-Object psobject -Property @{
        TenantId = $AADConnection.TenantDomain; 
        ClientId = $AADApp_obj.AppId;
        ClientSecret = $AADApp_creds.Value
    }

    if($Save){
        Write-Verbose "Save Credential object"
        if(!$Path){$Path = "$env:LocalAppData\IntuneDeviceInventory\AppConnection\$($AADConnection.TenantDomain).connection"}
        Save-IDIAppConnection -TenantId $AADApp_connection.TenantId -ClientId $AADApp_connection.ClientId -ClientSecret $AADApp_connection.ClientSecret -Path $Path
    }
    Write-Verbose "Those are your credential details, please save them."
    Write-Verbose $AADApp_connection
    return $AADApp_connection

}
