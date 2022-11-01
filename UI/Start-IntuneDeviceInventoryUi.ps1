<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: Start-IntuneDeviceInventoryUi
Description:
Start IntuneDeviceInventoryUi
Release notes:
1.0 :
- Init
#> 
###########################################################################################################
############################################ Functions ####################################################
###########################################################################################################
function Get-MessageScreen {
    param (
        [Parameter(Mandatory = $true)]
        [String]$xamlPath
    )
    
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    Add-Type -AssemblyName PresentationFramework
    [xml]$xaml = Get-Content $xamlPath
    $global:messageScreen = ([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml)))
    $global:messageScreenTitle = $global:messageScreen.FindName("TextMessageHeader")
    $global:messageScreenText = $global:messageScreen.FindName("TextMessageBody")
    $global:button1 = $global:messageScreen.FindName("ButtonMessage1")
    $global:button2 = $global:messageScreen.FindName("ButtonMessage2")

    $global:messageScreenTitle.Text = "Initializing Device Troubleshooter"
    $global:messageScreenText.Text = "Starting Device Troubleshooter"
    [System.Windows.Forms.Application]::DoEvents()
    $global:messageScreen.Show() | Out-Null
    [System.Windows.Forms.Application]::DoEvents()
}

function Import-AllModules {
    foreach ($file in (Get-Item -path "$global:Path\modules\*.psm1")) {      
        $fileName = [IO.Path]::GetFileName($file) 
        if ($skipModules -contains $fileName) { Write-Warning "Module $fileName excluded"; continue; }
    
        $module = Import-Module $file -PassThru -Force -Global -ErrorAction SilentlyContinue
        if ($module) {
            Set-MessageScreenText -text "Module $($module.Name) loaded successfully"
        }
        else {
            Set-MessageScreenText -text "Failed to load module $file"
            return $false
        }
    }
    return $true
}

function Set-MessageScreenText {
    param (
        [Parameter(Mandatory = $true)]
        [String]$text,
        [String]$header
    )

    if ($header) { $global:messageScreenTitle.Text = $header }
    $global:messageScreenText.Text = $text
    [System.Windows.Forms.Application]::DoEvents()
}

function Exit-Error {
    param (
        [Parameter(Mandatory = $true)]
        [String]$text
    )

    Write-Error $text 
    $global:messageScreen.Hide()
    Exit
}

###########################################################################################################
############################################## Start ######################################################
###########################################################################################################
### Variables
# General
$global:ToolName = "Intune Device Inventory UI"
$global:Version = "0.1"
$global:Developer = "Florian Salzmann and Jannik Reinhard"
$global:Path = $PSScriptRoot
$global:selectedDeviceItem = $null

# Start Start Screen
Get-MessageScreen -xamlPath ("$global:Path\xaml\message.xaml")
Set-MessageScreenText -text "Starting $toolName" -header "Initializing $toolName"

# Load custom modules
Set-MessageScreenText -text "Load all required modules"
if (-not (Import-AllModules)) { Exit-Error -text "Error while loading the modules" }

# Load Dlls
Set-MessageScreenText -text "Load all required DLLs"
if (-not (Import-Dlls)) {
    Write-Warning "Unblock all dlls and restart the powershell seassion"
    Exit-Error -text "Error while loading the dlls. Exit the script"
}

# Create Temp folder
Set-MessageScreenText -text "Create temp folder if not exist"
$folder = Add-TempFolder

# Authenticate
Set-MessageScreenText -text "Try to authenticate on Graph"
if (-not (Get-IDIAuthenticated)) { Exit-Error -text "Failed to authenticate" }

# Init Ui
Set-MessageScreenText -text "Intit User Interface"
try{
    $returnMainForm = New-XamlScreen -xamlPath ("$global:Path\xaml\ui.xaml")
    $global:formMainForm = $returnMainForm[0]
    $xamlMainForm = $returnMainForm[1]
    $xamlMainForm.SelectNodes("//*[@Name]") | % {Set-Variable -Name "WPF$($_.Name)" -Value $formMainForm.FindName($_.Name)}
    $global:formMainForm.add_Loaded({
        $global:messageScreen.Hide()
        $global:formMainForm.Activate()
    })
}catch{
    Exit-Error -text "Failed to init UI"
}
New-UiInti

# Get all devices
Set-MessageScreenText -text "Get all devices"
$global:allDevices = Get-AllDevices
if ($global:allDevices -eq $false) { Exit-Error -text "Failed to get all devices" }

# Add Devices
Set-MessageScreenText -text "Add devices to grid"
$global:allDevicesGrid = Add-DevicesToGridObject -devices $global:allDevices
Add-DevicesToGrid -devices $global:allDevicesGrid


$global:formMainForm.ShowDialog() | out-null