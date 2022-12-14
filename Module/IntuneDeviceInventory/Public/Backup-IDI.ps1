function Backup-IDI{
    
    <#
    .SYNOPSIS
        Backup all custom fields (Notes) including the device id an serialnumber

    .DESCRIPTION
        Set/Update device with changed properties (Notes field)

    .PARAMETER Path
        Path where the backup will be stored

    .PARAMETER open
        Switch to open the folder where the backup is stored

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Path where the backup will be stored")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$env:temp\IntuneDeviceInventory\IntuneDeviceInventory-$(Get-Date -Format yyyy-MM-dd).json",

        [parameter(Mandatory = $false, HelpMessage = "Switch to open the folder where the backup is stored")]
        [ValidateNotNullOrEmpty()]
        [switch]$open

    )

    try{
        $Backup = @()
        Write-Verbose "Reading all devices"
        $AllDevices = Get-IDIDevice -All
    
        foreach($Device in $AllDevices){
    
            Write-Verbose "Backup Config from Device: $($Device.id)"
            $Device_backup = $($Device[0] | Convertto-Json) | Convertfrom-Json
            $RefProperties = (Get-noneIDIReference).PSObject.Properties.Name
            foreach($Property in $RefProperties){
                if(($Property -ne "id") -and ($Property -ne "serialNumber")){
                    $Device_backup[0].PSObject.Properties.Remove("$Property")
                }
            } 
            $Backup += $Device_backup    
        }
    
        # Creat backup file
        Write-Verbose "Create Backup at: $Path"
        New-Item -Path $Path -Force | Out-Null
        $Backup | ConvertTo-Json | Out-File $Path -Encoding utf8 -Force

        Write-Host "Backup completet:" -ForegroundColor Green
        Write-Host $Path
    
        if($open){
            Invoke-Item $(Split-Path -Path $Path)
        }

    }catch{
        Write-Error $_
    }

}
