function Start-IDI{
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

    # Check Connection / Connect
    Connect-IDI

    $global:IDIDevices_all = Get-IDIDevice -All
    
    if($outFile){
        $global:IDIDevices_all | Convertto-Json | Out-File $IDIDevices_json
        if($openJSON){explorer $IDIDevices_json}
    }
}