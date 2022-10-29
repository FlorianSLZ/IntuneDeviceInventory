function Get-IDIDevices{
    <#
    .SYNOPSIS
        Get all Intune Devices and compile notes (json) into the output

    .DESCRIPTION
        Get all Intune Devices and compile notes (json) into the output

    .PARAMETER outFile
        Switch to create a JSON file after command completion

    .PARAMETER IDIDevices_json
        Path to the Output JSON

    .PARAMETER openJSON
        Switch to open the JSON file after creation

    .PARAMETER Force
        Switch to force overwrite of cached changes

    .PARAMETER Silent
        Switch to run the function silent, without any output

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Switch to create a JSON file after command completion")]
        [ValidateNotNullOrEmpty()]
        [switch]$outFile,

        [parameter(Mandatory = $false, HelpMessage = "Path to the Output JSON")]
        [ValidateNotNullOrEmpty()]
        [string]$IDIDevices_json = "$env:temp\IDIDevices.json",

        [parameter(Mandatory = $false, HelpMessage = "Switch to open the JSON file after creation")]
        [ValidateNotNullOrEmpty()]
        [switch]$openJSON,

        [parameter(Mandatory = $false, HelpMessage = "Switch to force overwrite of cached changes")]
        [ValidateNotNullOrEmpty()]
        [switch]$Force,

        [parameter(Mandatory = $false, HelpMessage = "Switch to run the function silent, without any output")]
        [ValidateNotNullOrEmpty()]
        [switch]$Silent

    )

    
    # Run again, will overrite
    if(!$Force){
        if($global:IDIDevices_all){
            if([System.Windows.Forms.MessageBox]::Show("Continue Task? (-Force)","All changes wil be overriten", "YesNo" , "Warning" , "Button1") -ne "Yes"){break}
        }
    }

    #   Reading all managed devices
    Write-Verbose "Get all managed Devices from Intune..."
    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
    $managedDevices = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop)

    Write-Verbose "Creating report..."
    $TotalItems = $managedDevices.value.Count
    $CurrentItem = 0
    $PercentComplete = 0

    $global:IDIDevices_all = @()
    foreach ($property in $($managedDevices.value | Select-Object -first 1).PSObject.Properties) { $global:IDIDevices_all | Add-Member -NotePropertyName $property.Name -NotePropertyValue $null }


    ForEach($ThisDevice in $managedDevices.value){
        Write-Progress -Activity "Creating report..." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
        $CurrentItem++
        $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)

        # Get notes field
        $Notes = $null
        $Resource = "deviceManagement/managedDevices('$($ThisDevice.id)')"
        $properties = 'notes'
        $uri = "https://graph.microsoft.com/beta/$($Resource)?select=$properties"
        $Notes = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).notes

        if($Notes){
            $Notes = $Notes | Convertfrom-Json

            # add Properties to main collection & this client
            foreach($property in $Notes[0].PSObject.Properties){
                $global:IDIDevices_all | Add-Member -NotePropertyName $property.Name -NotePropertyValue $null -ErrorAction SilentlyContinue
                $ThisDevice | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value
            }
        }
        $global:IDIDevices_all += $ThisDevice
    }

    
    if($outFile){
        $global:IDIDevices_all | Convertto-Json | Out-File $IDIDevices_json
        if($openJSON){explorer $IDIDevices_json}
    }
    
    if(!$silent){return $global:IDIDevices_all}
}