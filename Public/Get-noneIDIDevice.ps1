function Get-noneIDIDevice{
    <#
    .SYNOPSIS
        Get Intune Device(s)

    .DESCRIPTION
        Get Intune Device(s)

    .PARAMETER ScopeTag
        Get Intune Devices with specific scope tag

    .PARAMETER Group
        Get Intune Devices within a specific group

    .PARAMETER User
        Get Intune Devices from a specific user (UPN)

    .PARAMETER deviceName
        Get Intune Devices by name

    .PARAMETER id
        Get Intune Devices by id (deviceID)

    .PARAMETER azureADDeviceId
        Get Intune Device by azureADDeviceId

    .PARAMETER All
        Get all Intune Devices

    .PARAMETER Grid
        Switch to select Intune Devices out of a GridView

    #>

    param (
        #[parameter(Mandatory = $false, HelpMessage = "Get Intune Devices with specific scope tag")]
        #[ValidateNotNullOrEmpty()]
        #[string]$ScopeTag,

        [parameter(Mandatory = $false, HelpMessage = "Get Intune Devices within a specific group")]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [parameter(Mandatory = $false, HelpMessage = "Get Intune Devices from a specific primary user (UPN)")]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [parameter(Mandatory = $false, HelpMessage = "Get Intune Devices by Device Name")]
        [ValidateNotNullOrEmpty()]
        [string]$deviceName,

        [parameter(Mandatory = $false, HelpMessage = "Get Intune Devices by id")]
        [ValidateNotNullOrEmpty()]
        [string]$id,

        [parameter(Mandatory = $false, HelpMessage = "Get Intune Devices by azureADDeviceId")]
        [ValidateNotNullOrEmpty()]
        [string]$azureADDeviceId,

        [parameter(Mandatory = $false, HelpMessage = "Get all Intune Devices")]
        [ValidateNotNullOrEmpty()]
        [switch]$All,

        [parameter(Mandatory = $false, HelpMessage = "Switch to select Intune Devices out of a GridView")]
        [ValidateNotNullOrEmpty()]
        [switch]$Grid

    )

    # Set script variable for error action preference
    $ErrorActionPreference = "Stop"

    # Colection Variable
    $IntuneDevices = @()

    if($All){
        Write-Verbose "Get all managed Devices from Intune..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
        $Method = "GET"
        $IntuneDevices = (Invoke-PagingRequest -URI $uri -Method $Method)
    
    }elseif($ScopeTag){
        # tbd
        Write-Warning "Parameter -ScopeTag is in the making, please use anotherone in the meantime"

    }elseif($Group){
        Write-Verbose "Get group ID for $Group ..."
        $uri = "https://graph.microsoft.com/beta/groups?`$filter=displayName%20eq%20'$Group'"
        $GroupID = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).value.id
        
        Write-Verbose "Get group members for ID: $GroupID ..."
        $uri = "https://graph.microsoft.com/beta/groups('$GroupID')/transitiveMembers"
        $Method = "GET"
        $GroupMembersID = (Invoke-PagingRequest -URI $uri -Method $Method).deviceId
        
        Write-Verbose "Call function with -azureADDeviceId ($($GroupMembersID.count) members found)..."
        foreach($AADDID in $GroupMembersID){
            if($AADDID){  $IntuneDevices += Get-noneIDIDevice -azureADDeviceId $AADDID    }
        }
        
    }elseif($User){
        Write-Verbose "Get managed Intune Devices where user is: $User ..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=userPrincipalName%20eq%20'$User'"     
        $IntuneDevices = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).value
    }elseif($deviceName){
        Write-Verbose "Get managed Device from Intune with name: $deviceName ..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=deviceName%20eq%20'$deviceName'"     
        $IntuneDevices = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).value
        
    }elseif($id){
        Write-Verbose "Get managed Device from Intune by id: $id ..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$id')"
        $IntuneDevices = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop)

    }elseif($azureADDeviceId){
        Write-Verbose "Get managed Device from Intune by azureADDeviceId: $azureADDeviceId ..."
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=azureADDeviceId%20eq%20'$azureADDeviceId'"     
        $IntuneDevices = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).value

    }elseif($Grid){
        $IntuneDevices = Get-noneIDIDevice -All | Out-GridView -Title "Please select your devices" -OutputMode Multiple
    }else{
        Write-Warning "No Parameter specified for Get-noneIDIDevice"
    }

    if(!$IntuneDevices){Write-Warning "No device was found with the specified search criteria."}
    return $IntuneDevices

}
