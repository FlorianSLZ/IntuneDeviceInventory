<#
Version: 1.0
Author: Florian Salzman (scloud.work) / Jannik Reinhard (jannikreinhard.com)
Script: authHandler
Description:
Handel the authentication for the intune devie inventory
Release notes:
1.0 :
- Init
#>


function Get-Authenticated {
  Open-AuthSelectionWindows
  if($global:AuthMethod -eq "User") {
    if (-not (Get-IDIAuthenticatedUser)) { Exit-Error -text "Failed to authenticate" }
  }elseif($global:AuthMethod -eq "Manual"){
    Open-AuthServicePrincipleDetails -Manual $true
    if (-not (Get-IDIAuthenticatedServicePrinciple -tenantId $global:AuthTenant -clientId $global:AuthAppId -clientSecret $global:AuthAppSecret)) { Exit-Error -text "Failed to authenticate" }
  }elseif($global:AuthMethod -eq "Auto"){
    if(test-path "$env:LocalAppData\IntuneDeviceInventory\AppConnection\*.connection" -pathtype leaf){
      Open-AuthServicePrincipleDetails -ConnectionSelection $true
    }else{
      $global:AuthTenant = (New-IDIApp -Save).TenantId
      Approve-ServicePrinciple
    }
    if (-not (Get-IDIAuthenticatedServicePrincipleAuto -tenantId $global:AuthTenant)) { Exit-Error -text "Failed to authenticate" }
  }
}

function Get-IDIAuthenticatedUser{
  try {
      Connect-IDI
  }
  catch {
      Write-Error "Failed to authenticate on Graph: $_"
      return $false
  }
  return $true
}

function Get-IDIAuthenticatedServicePrinciple{
  param (
    [parameter(Mandatory = $false)] [string]$tenantId,
    [parameter(Mandatory = $false)] [string]$clientId,
    [parameter(Mandatory = $false)] [string]$clientSecret
  )

  try {
    Connect-IDI -ClientId $clientId -TenantId $tenantId -ClientSecret $clientSecret
  }
  catch {
      Write-Error "Failed to authenticate on Graph: $_"
      return $false
  }
  return $true
}

function Get-IDIAuthenticatedServicePrincipleAuto{
  param (
    [parameter(Mandatory = $false)] [string]$tenantId
  )
  try {
    Import-IDIAppConnection -TenantId $tenantId -Connect $true
  }
  catch {
      Write-Error "Failed to authenticate on Graph: $_"
      return $false
  }
  return $true
}


function Open-AuthSelectionWindows {
  try{
    $returnMainForm = New-XamlScreen -xamlPath ("$global:Path\xaml\authSelection.xaml")
    $global:formAuth = $returnMainForm[0]
    $xamlFormAuth = $returnMainForm[1]
    $xamlFormAuth.SelectNodes("//*[@Name]") | % {Set-Variable -Name "WPFA$($_.Name)" -Value $formAuth.FindName($_.Name) -scope global} 
    $global:formAuth.add_Loaded({
        $global:messageScreen.Hide()
        $global:formAuth.Activate()
    })
  }catch{
      Exit-Error -text "Failed to init auth selection UI"
  }

  Add-XamlEvent -object $global:WPFAButtonMessage1 -event "Add_Click" -scriptBlock {
    if($global:WPFARbUser.IsChecked  ){$global:AuthMethod = "User"}
    if($global:WPFARbManual.IsChecked  ){$global:AuthMethod = "Manual"}
    if($global:WPFARbAuto.IsChecked  ){$global:AuthMethod = "Auto"}
    $global:formAuth.Hide()
  }
 $global:formAuth.ShowDialog() | out-null
}


function Open-AuthServicePrincipleDetails {
  param (
    [parameter(Mandatory = $false)] [bool]$manual,
    [parameter(Mandatory = $false)] [bool]$connectionSelection
  )

  try{
    $returnMainForm = New-XamlScreen -xamlPath ("$global:Path\xaml\authServicePrinciple.xaml")
    $global:formAuth = $returnMainForm[0]
    $xamlFormAuth = $returnMainForm[1]
    $xamlFormAuth.SelectNodes("//*[@Name]") | % {Set-Variable -Name "WPFAS$($_.Name)" -Value $formAuth.FindName($_.Name) -scope global}
    if($manual){
      $global:WPFASTxtTenantId.Visibility = "Visible"
      $global:WPFASTxtAppId.Visibility = "Visible"
      $global:WPFASTxtSecret.Visibility = "Visible"
      $global:WPFASLblTenantId.Visibility = "Visible"
      $global:WPFASLblAppId.Visibility = "Visible"
      $global:WPFASLblAppSecret.Visibility = "Visible"

      $global:WPFASLblSecret.Visibility = "Collapsed"
      $global:WPFASComboboxConnection.Visibility = "Collapsed"
    }elseif($connectionSelection){
      $global:WPFASTxtTenantId.Visibility = "Collapsed"
      $global:WPFASTxtAppId.Visibility = "Collapsed"
      $global:WPFASTxtSecret.Visibility = "Collapsed"
      $global:WPFASLblTenantId.Visibility = "Collapsed"
      $global:WPFASLblAppId.Visibility = "Collapsed"
      $global:WPFASLblAppSecret.Visibility = "Collapsed"

      $global:WPFASLblSecret.Visibility = "Visible"
      $global:WPFASComboboxConnection.Visibility = "Visible"

      $connections = Get-ChildItem -Path "$env:LocalAppData\IntuneDeviceInventory\AppConnection\*.connection" -Force
      foreach ($connection in $connections) { $global:WPFASComboboxConnection.items.Add($connection.Name) | Out-Null }
      $WPFASComboboxConnection.SelectedIndex = 0
    }else{
      $global:WPFASTxtTenantId.Visibility = "Visible"
      $global:WPFASTxtAppId.Visibility = "Collapsed"
      $global:WPFASTxtSecret.Visibility = "Collapsed"
      $global:WPFASLblTenantId.Visibility = "Visible"
      $global:WPFASLblAppId.Visibility = "Collapsed"
      $global:WPFASLblAppSecret.Visibility = "Collapsed"

      $global:WPFASLblSecret.Visibility = "Collapsed"
      $global:WPFASComboboxConnection.Visibility = "Collapsed"
    }   

    $global:formAuth.add_Loaded({
        $global:formAuth.Activate()
    })
  }catch{
      Exit-Error -text "Failed to init auth UI"
  }

  Add-XamlEvent -object $global:WPFASButtonMessage1 -event "Add_Click" -scriptBlock {
    if(-not $global:WPFASTxtTenantId.Text -and -not $connectionSelection){
      [System.Windows.MessageBox]::Show('Insert the TenantId')
      return
    }

    if($Manual -and -not $global:WPFASTxtAppId.Text -and -not $connectionSelection){
      [System.Windows.MessageBox]::Show("Insert the AppId")
      return
    }
    if($Manual -and -not $global:WPFASTxtSecret.Text -and -not $connectionSelection){
      [System.Windows.MessageBox]::Show("Insert the Secret")
      return
    }
    $global:AuthTenant = $global:WPFASTxtTenantId
    $global:AuthAppId = $global:WPFASTxtAppId
    $global:AuthAppSecret = $global:WPFASTxtSecret
    if($connectionSelection){
      if($global:WPFASComboboxConnection.SelectedItem){
        $global:AuthTenant = ($global:WPFASComboboxConnection.SelectedItem).Replace('.connection','')  
      }else{
        Exit-Error -text "Erro while getting selected connection"
      }
    }
    $global:formAuth.Hide()
  }
 $global:formAuth.ShowDialog() | out-null
}


function Approve-ServicePrinciple {
  try{
    $returnMainForm = New-XamlScreen -xamlPath ("$global:Path\xaml\authServicePrinciple.xaml")
    $global:formAuth = $returnMainForm[0]
    $xamlFormAuth = $returnMainForm[1]
    $xamlFormAuth.SelectNodes("//*[@Name]") | % {Set-Variable -Name "WPFAS1$($_.Name)" -Value $formAuth.FindName($_.Name) -scope global}
    $global:WPFAS1TxtTenantId.Visibility = "Collapsed"
    $global:WPFAS1LblTenantId.Visibility = "Collapsed"
    $global:WPFAS1TextMessageBody.Text = "Approve the Service Principle Consent, wait 1 min and click Next"

    $global:formAuth.add_Loaded({
        $global:formAuth.Activate()
    })
  }catch{
      Exit-Error -text "Failed to init UI"
  }

  Add-XamlEvent -object $global:WPFAS1ButtonMessage1 -event "Add_Click" -scriptBlock {
    $global:formAuth.Hide()
  }

  $global:formAuth.ShowDialog() | out-null
}

