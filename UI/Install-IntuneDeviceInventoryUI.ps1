<#
Version: 1.0
Author: Florian Salzman (scloud.work) / Jannik Reinhard (jannikreinhard.com)
Script: Install_IntuneDeviceInventoryUI
Description:
Installation of the intune device inventory
Release notes:
1.0 :
- Init
#>

#   Program variables
$ProgramPath = "$env:LOCALAPPDATA\IntuneDeviceInventory"

#############################################################################################################
#   Program files
#############################################################################################################

try{
    #   Copy Files & Folders
    Write-Host "Copying / updating program files..."
    New-Item $ProgramPath -type Directory -Force | Out-Null
    Copy-Item $($(Split-Path $MyInvocation.MyCommand.Path) + "\*") $ProgramPath -Force -Recurse
    Get-Childitem -Recurse $ProgramPath | Unblock-file
    Write-Host "Program files completed" -ForegroundColor green

    #   Create Startmenu shortcut
    Write-Host "Creating / updating startmenu shortcut..."
    Copy-Item "$ProgramPath\libaries\IntuneDeviceInventory.lnk" "$env:appdata\Microsoft\Windows\Start Menu\Programs\IntuneDeviceInventory.lnk" -Force -Recurse
    Write-Host "Startmenu item completed" -ForegroundColor green

}catch{$_}

# Enter to exit
Write-Host "Installation completed!" -ForegroundColor green
Read-Host "Press [Enter] to close"