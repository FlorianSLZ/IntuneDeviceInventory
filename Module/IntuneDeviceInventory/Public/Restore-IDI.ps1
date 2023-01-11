function Restore-IDI{
    
    <#
    .SYNOPSIS
        Restore custom fields (Notes)

    .DESCRIPTION
        Restore custom fields (Notes)
        Assigment possible by id (Intune) or serialnumber

    .PARAMETER Path
        Path where the backup is stored

    .PARAMETER serial
        Switch to restore by serialnumber (default is id)

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Path where the backup is stored")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [parameter(Mandatory = $false, HelpMessage = "Switch to restore by serialnumber (default is id)")]
        [ValidateNotNullOrEmpty()]
        [switch]$serial

    )

    try{
        if(Test-Path -Path $Path){
            Write-Verbose "Reading Backup from: $Path"
            $BackupJson = Get-Content $Path
            $Backup = $BackupJson | ConvertFrom-Json

            foreach($Device in $Backup){
                if($serial){
                    Write-Verbose "Get managed Device from Intune by SerialNumber: $($Device.serialNumber) ..."
                    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=serialNumber%20eq%20'$($Device.serialNumber)'"
                    $Device.id = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).value.id
                }

                if($Device.id){
                    Write-Verbose "Restore IDI / Notes for: $($Device.id)"
                    $Notesonly = $($Device[0] | Convertto-Json) | Convertfrom-Json
                    $Notesonly[0].PSObject.Properties.Remove("id")
                    $Notesonly[0].PSObject.Properties.Remove("serialNumber")
    
                    Write-Verbose "  Properties: $($Notesonly.PSObject.Properties.Name)"
                
                    # Update the notes of the device
                    $Note_json = $Notesonly | Convertto-Json
                    $Json = @{ "notes" = "$Note_json" } 
                    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($Device.id)')"
    
                    Invoke-MSGraphRequest -Url $uri -HttpMethod PATCH -Content $Json
                }else{
                    Write-Warning "Device ID for SerialNumber not found: $($Device.serialNumber)"
                }


            }

        }else{
            Write-Error "File does not exist: $Path"
        }
    }catch{
        Write-Error $_
    }
}
