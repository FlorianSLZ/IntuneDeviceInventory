<#
Version: 1.0
Author: Florian Salzman (scloud.work) / Jannik Reinhard (jannikreinhard.com)
Script: deviceInventoryHandler
Description:
Utility functions
Release notes:
1.0 :
- Init
#>
function Import-Dlls {
  #Load dll
  try {
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				              | out-null
    [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				              | out-null
    [System.Reflection.Assembly]::LoadFrom("$global:Path\libaries\MahApps.Metro.dll")       				| out-null
    [System.Reflection.Assembly]::LoadFrom("$global:Path\libaries\ControlzEx.dll")                  | out-null  
    [System.Reflection.Assembly]::LoadFrom("$global:Path\libaries\SimpleDialogs.dll")               | out-null
    #[System.Reflection.Assembly]::LoadFrom("$global:Path\libaries\LoadingIndicators.WPF.dll")       | out-null   
  
  }
  catch {
    Write-Error "Loading from dll's was not sucessfull: $_"
    return $false
  }
  return $true
}

function Add-TempFolder {
  if (-not (Test-Path "$global:Path\.tmp")) {
    New-Item "$global:Path\.tmp" -Itemtype Directory
  }
  return $true
}


function Add-XamlEvent{
  param(
    [Parameter(Mandatory = $true)]  
    $object,
    [Parameter(Mandatory = $true)]
    $event,
    [Parameter(Mandatory = $true)]
    $scriptBlock
  )

  try {
      if($object)
      {
          $object."$event"($scriptBlock)
      }
      else 
      {
          $global:txtSplashText.Text = "Event  $($object.Name) loaded successfully"

      }
  }
  catch 
  {
      Write-Error "Failed load event $($object.Name). Error:" $_.Exception
  }
}


########################################################################################
########################################### UI  ########################################
########################################################################################
function New-XamlScreen{
  param (
      [Parameter(Mandatory = $true)]
      [String]$xamlPath
  )
  $inputXML = Get-Content $xamlPath
  [xml]$xaml = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
  $reader = (New-Object System.Xml.XmlNodeReader $xaml)

  try {
      $form = [Windows.Markup.XamlReader]::Load( $reader )
  }
  catch {
      Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
  }
  return @($form, $xaml)
}

function Get-DecodeBase64Image {
  param (
      [Parameter(Mandatory = $true)]
      [String]$imageBase64
  )
  # Parameter help description
  $objBitmapImage = New-Object System.Windows.Media.Imaging.BitmapImage
  $objBitmapImage.BeginInit()
  $objBitmapImage.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($imageBase64)
  $objBitmapImage.EndInit()
  $objBitmapImage.Freeze()
  return $objBitmapImage
}