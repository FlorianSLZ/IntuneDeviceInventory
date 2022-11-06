function ConvertTo-IDINotes{
    
    <#
    .SYNOPSIS
        Converts non IDI created Notes to IDI compatible JSON with custom PropertyName

    .DESCRIPTION
        Converts non IDI created Notes to IDI compatible JSON with custom PropertyName
        
    .PARAMETER DeviceId
        Array of the device to set/update

    .PARAMETER PropertyName
        Property Name of the notes content

    .PARAMETER All
        Switch to run command for all devices

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Array of the device to converte the notes for")]
        [ValidateNotNullOrEmpty()]
        [array]$DeviceId,

        [parameter(Mandatory = $true, HelpMessage = "Property Name of the notes content")]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyName,

        [parameter(Mandatory = $false, HelpMessage = "Convert Notes from all Devices")]
        [ValidateNotNullOrEmpty()]
        [switch]$All

    )
    try{
        if($All){
            Write-Verbose "Read all Intune Devices and run *ConvertTo-IDINotes -IDIDevice `$_* ..."
            Get-noneIDIDevice -All | ForEach-Object{ ConvertTo-IDINotes -DeviceId $_.id -PropertyName $PropertyName }
                
        }else{
            Write-Verbose "Read notes for $DeviceId"
            $Notes = $null
            $Resource = "deviceManagement/managedDevices('$DeviceId')"
            $properties = 'notes'
            $uri = "https://graph.microsoft.com/beta/$($Resource)?select=$properties"
            $Notes = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).notes
    
            if($Notes){
                try{
                    $IDINoteCheck = $null
                    $IDINoteCheck = $($Notes | ConvertFrom-Json -ErrorAction SilentlyContinue)
                }catch{}
                
                if($IDINoteCheck){
                    Write-Warning "Device already compatible with IDI: $DeviceId"

                }else{
                    Write-Verbose "Convert notes to JSON with PropertyName $PropertyName"
                    $NoteObj = @(
                        [pscustomobject]@{$PropertyName="$Notes"}
                    )
                    $NoteObj = $NoteObj | Convertto-Json
        
                    Write-Verbose "Update notes on Intune Device: $DeviceId"
                    $Json = @{ "notes" = "$NoteObj" } 
                    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$DeviceId')"
        
                    Invoke-MSGraphRequest -Url $uri -HttpMethod PATCH -Content $Json

                }

            }else{Write-Verbose "Device $DeviceId has no notes."}
        }
    }catch{
        Write-Error "Error while processing notes: $DeviceId `n$_"
    }

}
