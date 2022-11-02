<#
.SYNOPSIS
Hadeling UI
.DESCRIPTION
Handling of the WPF UI
.NOTES
  Author: Jannik Reinhard
#>

########################################################################################
###################################### UI Actions ######################################
########################################################################################
function Hide-All {
    $WPFTextboxSearchBoxDevice.Text = ""
    $WPFGridAbout.Visibility = "Collapsed"
    $WPFGridDeviceFinder.Visibility = "Collapsed"
    $WPFGridShowDevice.Visibility = "Collapsed"
    $WPFGridShowDevicesMulti.Visibility = "Collapsed"
}

function Set-UiActionButton {
    #Home
    Add-XamlEvent -object $WPFButtonHome -event "Add_Click" -scriptBlock {
        Hide-All
        $WPFGridDeviceFinder.Visibility = "Visible"
    }
    
    #About
    Add-XamlEvent -object $WPFButtonAbout -event "Add_Click" -scriptBlock {
        if ($WPFGridAbout.Visibility -eq "Visible") {
            Hide-All
            $WPFGridDeviceFinder.Visibility = "Visible"
        }
        else {
            Hide-All
            $WPFGridAbout.Visibility = "Visible"
        }
    }
    Add-XamlEvent -object $WPFBlogPost -event "Add_Click" -scriptBlock { Start-Process "https://github.com/JayRHa/Intune-Device-Troubleshooter" } 
    Add-XamlEvent -object $WPFReadme -event "Add_Click" -scriptBlock { Start-Process "https://github.com/FlorianSLZ/IntuneDeviceInventory/blob/main/readme.md" } 

    Add-XamlEvent -object $WPFButtonAboutWordpressFs -event "Add_Click" -scriptBlock { Start-Process "https://www.linkedin.com/in/fsalzmann/" }
    Add-XamlEvent -object $WPFButtonAboutTwitterFs -event "Add_Click" -scriptBlock { Start-Process "https://twitter.com/FlorianSLZ/" }
    Add-XamlEvent -object $WPFButtonAboutLinkedInFs -event "Add_Click" -scriptBlock { Start-Process "https://scloud.work/en/about/" }

    Add-XamlEvent -object $WPFButtonAboutWordpress -event "Add_Click" -scriptBlock { Start-Process "https://www.jannikreinhard.com" }
    Add-XamlEvent -object $WPFButtonAboutTwitter -event "Add_Click" -scriptBlock { Start-Process "https://twitter.com/jannik_reinhard" }
    Add-XamlEvent -object $WPFButtonAboutLinkedIn -event "Add_Click" -scriptBlock { Start-Process "https://www.linkedin.com/in/jannik-r/" }

    # Device selection view
    Add-XamlEvent -object $WPFButtonRefreshDeviceOverview -event "Add_Click" -scriptBlock {
        $WPFTextboxSearchBoxDevice.Text = ""
        Get-RefresDevices
    }

    Add-XamlEvent -object $WPFButtonChangeCustomAttributes -event "Add_Click" -scriptBlock { Show-DeviceAttributes}

    # Signel Device view
    Add-XamlEvent -object $WPFButtonNewRow -event "Add_Click" -scriptBlock {
        $WPFDataGridSingleDevice.ItemsSource +=('{ "Value":"Add a value", "Name":"New Attribute", "Changed":"(*)", "InitValue":"Add a value", "InitName":"New Attribute", "UpdateAttribute":"False" }' | ConvertFrom-Json)
        $WPFDataGridSingleDevice.Items.Refresh()
    }

    Add-XamlEvent -object $WPFButtonRemoveRow -event "Add_Click" -scriptBlock {
        $WPFDataGridSingleDevice.SelectedItem.Changed = "Delete"
        $WPFDataGridSingleDevice.Items.Refresh()
    }

    Add-XamlEvent -object $WPFButtonResetRow -event "Add_Click" -scriptBlock {
        $WPFDataGridSingleDevice.SelectedItem.Changed = $null
        $WPFDataGridSingleDevice.SelectedItem.Name = $WPFDataGridSingleDevice.SelectedItem.InitName
        $WPFDataGridSingleDevice.SelectedItem.Value = $WPFDataGridSingleDevice.SelectedItem.InitValue
        $WPFDataGridSingleDevice.Items.Refresh()
    }

    Add-XamlEvent -object $WPFButtonSave -event "Add_Click" -scriptBlock {
        $WPFDataGridSingleDevice.Items | ForEach-Object{
            $item = $WPFDataGridAllDevices.SelectedItems[0].Details | Where-Object {-not($_.Changed -eq "Delete" -or $_.Changed -eq '(*)')}
            if (-not ($item | Get-Member -Name $_.Name)){
                $item | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
            }
            Set-IDIDevice -IDIDevice $item
            $_.Changed = $null
            $_.InitValue = $_.Value
            $_.InitName = $_.Name
        }
        $WPFDataGridSingleDevice.Items.Refresh()
        Get-RefresDevices
    }

    # Multi devices
    Add-XamlEvent -object $WPFButtonNewRowMulti -event "Add_Click" -scriptBlock {
        $WPFDataGridMultiDevices.ItemsSource +=('{ "Value":"Add a value", "Name":"New Attribute", "Changed":"(*)", "InitValue":"Add a value", "InitName":"New Attribute", "UpdateAttribute":"False" }' | ConvertFrom-Json)
        $WPFDataGridMultiDevices.Items.Refresh()
    }

    Add-XamlEvent -object $WPFButtonRemoveRowMulti -event "Add_Click" -scriptBlock {
        $WPFDataGridMultiDevices.SelectedItem.Changed = "Delete"
        $WPFDataGridMultiDevices.SelectedItem.UpdateAttribute = $true
        $WPFDataGridMultiDevices.Items.Refresh()
    }

    Add-XamlEvent -object $WPFButtonResetRowMulti -event "Add_Click" -scriptBlock {
        $WPFDataGridMultiDevices.SelectedItem.Changed = $null
        $WPFDataGridMultiDevices.SelectedItem.UpdateAttribute = $false
        $WPFDataGridMultiDevices.SelectedItem.Name = $WPFDataGridMultiDevices.SelectedItem.InitName
        $WPFDataGridMultiDevices.SelectedItem.Value = $WPFDataGridMultiDevices.SelectedItem.InitValue
        $WPFDataGridMultiDevices.Items.Refresh()
    }

    Add-XamlEvent -object $WPFButtonSaveMulti -event "Add_Click" -scriptBlock {
        # Check if there are changes to apply
        if(($WPFDataGridMultiDevices.ItemsSource.UpdateAttribute | Where-Object {$_ -eq $true}).count -lt 1){
            Show-MessageBoxInWindow -text "No change to apply. Please check add and mark an attibute to change" -button1text "Ok"
        }

        $WPFDataGridMultiDevicesSelected.ItemsSource | ForEach-Object{
            $device = $_.Details
            foreach($item in $_.CustomInventory){
                $device | Add-Member -NotePropertyName $item.Name -NotePropertyValue $item.Value -Force
            }

            foreach($inventory in $WPFDataGridMultiDevices.ItemsSource){
                if($inventory.CurrentItem.Name -eq 'New Attribute' -and $inventory.CurrentItem.Value -eq 'Add a value'){continue}
                if($inventory.UpdateAttribute -ne $true){continue}
                
                # if($inventory.Name -in $device.PSObject.Properties.Name){
                if($inventory.Changed -eq "Delete"){
                    $device = $device | Select-Object -Property * -ExcludeProperty $inventory.Name
                }else{
                    $device | Add-Member -NotePropertyName $inventory.Name -NotePropertyValue $inventory.Value -Force
                }
                Set-IDIDevice -IDIDevice $device
            } 
        }
        $WPFDataGridMultiDevices.ItemsSource = $WPFDataGridMultiDevices.ItemsSource | Where-Object {($_.Changed -ne "Delete" -and $_.Changed -ne '(*)')}
        
        $WPFDataGridMultiDevices.ItemsSource | ForEach-Object {
            $_.UpdateAttribute = $false
            $_.Changed = $null
            $_.InitValue = $_.Value
            $_.InitName = $_.Name
        }
        
        $WPFDataGridMultiDevices.Items.Refresh()
        $WPFDataGridMultiDevices.ItemsSource
        Get-RefresDevices
    }
    

    # Device Actions
    Add-XamlEvent -object $WPFButtonDeviceSync -event "Add_Click" -scriptBlock {Invoke-IDIDeviceSync -IDIDevice $WPFDataGridAllDevices.SelectedItems[0].Details}
    Add-XamlEvent -object $WPFButtonDeviceRestart -event "Add_Click" -scriptBlock {Invoke-IDIDeviceRestart -IDIDevice $WPFDataGridAllDevices.SelectedItems[0].Details}
    Add-XamlEvent -object $WPFButtonBitlockerRotation -event "Add_Click" -scriptBlock {Invoke-IDIDeviceBitLockerRotation -IDIDevice $WPFDataGridAllDevices.SelectedItems[0].Details}
    Add-XamlEvent -object $WPFButtonDefenderScan -event "Add_Click" -scriptBlock {Invoke-IDIDeviceDefenderScan -IDIDevice $WPFDataGridAllDevices.SelectedItems[0].Details}
    Add-XamlEvent -object $WPFButtonDefenderSignature -event "Add_Click" -scriptBlock {Invoke-IDIDeviceDefenderSignatures -IDIDevice $WPFDataGridAllDevices.SelectedItems[0].Details}
}
function Set-UiAction {
    # Search
    Add-XamlEvent -object $WPFTextboxSearchBoxDevice -event "Add_TextChanged" -scriptBlock {
        Search-DevicesInGrid -searchString $($WPFTextboxSearchBoxDevice.Text)
    }

    Add-XamlEvent -object $WPFDataGridSingleDevice -event "Add_CurrentCellChanged" -scriptBlock {
        if($this.CurrentItem.Name -eq 'New Attribute' -and $this.CurrentItem.Value -eq 'Add a value'){
            $this.CurrentItem.Changed = '(*)'
            return
        }
        if($this.CurrentItem.Name -ne $this.CurrentItem.InitName -or $this.CurrentItem.Value -ne $this.CurrentItem.InitValue){
            $this.CurrentItem.Changed = '*'
        }    
        $this.Items.Refresh()
    }

    Add-XamlEvent -object $WPFDataGridMultiDevices -event "Add_CurrentCellChanged" -scriptBlock {
        if($this.CurrentItem.Name -eq 'New Attribute' -and $this.CurrentItem.Value -eq 'Add a value'){
            $this.CurrentItem.Changed = '(*)'
            return
        }
        if($this.CurrentItem.Name -ne $this.CurrentItem.InitName -or $this.CurrentItem.Value -ne $this.CurrentItem.InitValue){
            $this.CurrentItem.Changed = '*'
        }    
        $this.Items.Refresh()
    }
    
    # Device 
    Add-XamlEvent -object $WPFDataGridAllDevices -event "Add_MouseDoubleClick" -scriptBlock {
        Show-DeviceAttributes
    }
}

### Actions
function Search-DevicesInGrid {
    param (
        [Parameter(Mandatory = $true)] $searchString
    )

    if ($searchString.Length -lt 2 -or $searchString -eq '') {
        Add-DevicesToGrid -devices $global:allDevicesGrid
        return
    }

    $allDeviceSearched = @()          
    $allDeviceSearched = $global:allDevicesGrid | Where-Object `
    { ($_.DeviceName -like "*$searchString*") -or `
        ($_.DevicePrimaryUser -like "*$searchString*") }
    Add-DevicesToGrid -devices $allDeviceSearched
}
function Add-DevicesToGrid {
    param (
        [Parameter(Mandatory = $true)] $devices
    )

    $items = @()
    $devices = $devices | Sort-Object -Property DeviceName
    $items += $devices | Select-Object -First $([int]$($WPFComboboxDevicesCount.SelectedItem))

    $WPFDataGridAllDevices.ItemsSource = $items
    $WPFLabelCountDevices.Content = "$($items.count) Devices"
}

function Show-MessageBoxInWindow {
    param (
        [String]$titel = $global:ToolName,
        [Parameter(Mandatory = $true)]
        [String]$text,
        [String]$button1text = "",
        [String]$button2text = "",
        [String]$messageSeverity = "Information"
  
    )
  
    $global:message = [SimpleDialogs.Controls.MessageDialog]::new()		    
    $global:message.MessageSeverity = $messageSeverity
    $global:message.Title = $titel
    if ($button1text -eq "") { $global:message.ShowFirstButton = $false }else { $global:message.ShowSecondButton = $true }
    if ($button2text -eq "") { $message.ShowSecondButton = $false }else { $global:message.ShowSecondButton = $true }
    $global:message.FirstButtonContent = $button1text
    $global:message.SecondButtonContent = $button2text
  
    $global:message.TitleForeground = "White"
    $global:message.Background = "#FF1B1A19"
    $global:message.Message = $text	
    [SimpleDialogs.DialogManager]::ShowDialogAsync($($global:formMainForm), $global:message)
  
    $global:message.Add_ButtonClicked({
            $buttonArgs = [SimpleDialogs.Controls.DialogButtonClickedEventArgs]$args[1]	
            $buttonValues = $buttonArgs.Button
            If ($buttonValues -eq "FirstButton") {
                return $null
            }
            ElseIf ($buttonValues -eq "SecondButton") {
                return $null
            }				
        })
    return $null
}

function Show-DeviceAttributes {
    $selectedDeviceItem = $WPFDataGridAllDevices.SelectedItems
    if ($selectedDeviceItem.count -lt 1) {
        Show-MessageBoxInWindow -text "Select a Item" -button1text "OK"
        return
    }elseif ($selectedDeviceItem.count -eq 1) {
        Show-SingleDevice -selectedItem $selectedDeviceItem[0]
        return
    }else{
        Show-MultiDevices -selectedItems @($selectedDeviceItem)
    }
    
}
### Views
function Show-SingleDevice{
    param (
        [Parameter(Mandatory = $true)] $selectedItem
    )

    # Change UI
    Hide-All
    $WPFGridShowDevice.Visibility = "Visible"
    # Set lables
    $WPFLabelHostname.Content = $selectedItem.Details.deviceName
    $WPFLabelDeviceCompliance.Content = $selectedItem.Details.complianceState
    $WPFLabelPrimaryUserUpn.Content = $selectedItem.Details.userPrincipalName
    $WPFLabelEnrollmentDateTime.Content = $selectedItem.Details.enrolledDateTime
    $WPFLabelLastSyncDateTime.Content = $selectedItem.Details.lastSyncDateTime
    $WPFLabelOsVersion.Content = "$($selectedItem.Details.osVersion) ($($selectedItem.Details.operatingSystem))"
    $WPFLabelCategory.Content = $selectedItem.Details.deviceCategoryDisplayName
    $WPFLabelModel.Content = "$($selectedItem.Details.model) ($($selectedItem.Details.manufacturer))"
    $WPFLabelSerialNumber.Content = $selectedItem.Details.serialNumber
    $WPFLabelLostModeState.Content = $selectedItem.Details.lostModeState

    # Show custom attributes
    $WPFDataGridSingleDevice.ItemsSource = $selectedItem.CustomInventory
}

function Show-MultiDevices{
    param (
        [Parameter(Mandatory = $true)] $selectedItems
    )

    Hide-All
    $WPFGridShowDevicesMulti.Visibility = "Visible"

    # Show selected Devices
    $WPFDataGridMultiDevicesSelected.ItemsSource = $selectedItems

    # Create inventory
    $inventory = @()
    $selectedItems | ForEach-Object {$inventory =  $inventory  + $_.CustomInventory}
    $inventory = @($inventory | Sort-Object -Property Name,Value -Unique)

    $WPFDataGridMultiDevices.ItemsSource = $inventory
}


### Init
function New-UiInti {
    # Set Lable Text
    $global:formMainForm.Title = "$global:ToolName - v$global:Version by $global:Developer"
    $WPFToolName.Content = "$global:ToolName"
    $WPFCreator.Content = "(c) 2022 by $global:Developer (MIT License)"
    $WPFLableHeader.Content = "$global:ToolName"

    # Set images
    Set-UiImages

    try {
        $WPFLableUPN.Content = (Invoke-MSGraphRequest -URL 'https://graph.microsoft.com/beta/me?$select=userPrincipalName').userPrincipalName
        $WPFLableTenant.Content = (Invoke-MSGraphRequest -URL 'https://graph.microsoft.com/beta/organization?$select=displayName').value.displayName
    }
    catch {
        Write-Error "Fail to load profile info: $_"
        return $false
    }

    # Set buttons
    Set-UiActionButton
    Set-UiAction

    return $true
}


function Set-UiImages {
    #Load images for UI
    $iconHome = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABPElEQVRIiWNgGFHAYerzYoepz4tJ0cNIlKr//xmdpr5o/8/wvxwqMsn+jWRhQwPjP4otCG24yvZGRHA+AwNDFJrU2v/cP2MOJCr+INsCt+4X3L85/61hYGDwwK7i/z6OfxyB2/OEP5FsgfOEl+L/WP5uZWBgMCbgwsvM//947M6Ve0a0BXaTXyiyMP3b+f8/gyo+w5HAfSaGfx57c2RuoUswoQs4TntmzMz47zgJhjMwMDAo/mNgOuYw6YUFXgucJr9wYvjHsI+BgUGcBMNhQJiR6d8ep8nPPbFa4DD1WfR/xn/bGRgY+MgwHAa4/zP+3+Q45WkSigUOk5/lM/5nWMTAwMBGgeEwwMLAwDjHYcrTcgYGLJHsOOXZf0pM358jhWImRiRTG9DcAhZiFaJ7ndigHPpBNGrBKKAcAAB1CWAtKzJosQAAAABJRU5ErkJggg=="
    $iconSearch = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAgVBMVEUAAAAknvMnmfUomfUomfUnmfUpmvUjl/MomPYomfUomfYnmPYpmvYomfUpmvUol/Muov8omvcnmfUomfUmmfIomfUpmPQnmfQomPUomfUnmfMomfUnnesrlf8omfUkku0nm/MomfUomPUnmfUomvQpmfUomfUnmvYomfUomfX///+Vwm5wAAAAKXRSTlMAFYLO9M+DFlLx8lRR/bBACz+v/hTwd3WBskHQDQzzDkKAs+95fc2IfxLEHQcAAAABYktHRCpTvtSeAAAAB3RJTUUH5gYUDicDFaCpggAAAJ5JREFUKM+tkNkOgjAQRVs2obILtaDsgt7//0GJpHFq9Enm6eTc5GZmGPtnuGU7jusdPr0f4DXiaPowQpykaZbjZCRFCbnRGYK2KVQac3gksFFrzHAhgcBVY4PWCLp3IIyqXmMClwQDRo0xLHr2hNtGEgGnh8zA2DdNXSHyjSbM0/aSMjQ9GFeL0y6qIP6+evnl33t59vjh15UGtsc8AfKLD4mzmPrPAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIyLTA2LTIwVDE0OjM5OjAzKzAwOjAwYoXoEAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMi0wNi0yMFQxNDozOTowMyswMDowMBPYUKwAAAAASUVORK5CYII="   
    $iconRefresh = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACVUlEQVRIid2VQWsTQRTHf283qUkTtXhrUSlSSNLc2i8gqBVPBg89etBKlIpQaAW9NLfWVi8epFv04EkICI1Xix9A7K2lKUUQlfaitEqS1TTZ52G3sk3SJS160P9peDPz/82+nXkP/nVJ0GQ6rx21bTsjOBnUGAA9CSjIZ5QlhYW4RAtLWdnx70ta5VwxG8sFApJzlSuIzgJngs+o66oysXYzVvDMJ4FcMRuT1oCcGqlue1rRCS+yrCJPTeqLoUj8A0DtR6lX1byg6AiQBhRlGuEnkAPYF5CyKjOeeVWEsdWNzjly4rQ8fF7NxJY9KuhDIOyfagnw0vISqKrhXFq7cfRNcHq8ffPl5yhXWwGM3UA6rx1ezhFhrG1zqzzZaO7Xb0Bt287g/tDl1a5Oq21zL+dtLC69SFplTViVO21taFOGbzwAENL64l8CSA8A9fjHPwkINQZqkS+BrztIfY+/HgsdiXwDvhezseOw5wt0AyC0Ezl1WEA43HHaHcnmbswHMN4BOGIOHRaghlwEUHjbBFCh4E7qCHk1D+yeVxPkmmvGqyZAqCu6IPAeSCe37FsH9U9s27eBftD1uEQLTYCVYaki4hU4fdQ/VzrXrnlqvnReVGcBVZFxf/luujEJq/JA0LtAFZXx4onoE4al3sr4bE5Dmz32qGceBpkuZjvv+de0LNeJbnvKgwCsCPIMp/7acNxy7RilXhVzCNHrblpQFZlZ24jeb6y8+975lFXOKMwCffutcbW34TQq8FENWhouqX1ZIIMw6LVMBD6BLDlKoVXL/L/0C7qI6rgG7zcJAAAAAElFTkSuQmCC"
    $iconPaging = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAB3UlEQVRIidWVMWtTYRSGn/MlanJvM7fYChXE3jgouLk5OTTaQcHVQUxT/AN1sVpE9BfopX9BESXVwdWtOLjYNIsZQm0Hl9qbREzOcWiE9N5EmljBvtPh/V7OA985Hx8cdUncyIdRwSAEJofsVVehWC3673pNF08ZPB+hOcCUGGHcTACAqRGaAyBw6iCAQ9U/Bxx9JdY0CCP7m4aVeX9fz/96yAq8wZhrkzrT/uFlBE7GQ+kRm9dVuF4t+msx/+thAGqptl2q3B3bCp41p3F6D5gFxoFtYBV1TyoL2RoMP+SO4i5X57MfgnD3CrgXYLlkTL6L6Y310tj7BOAgmllpnha1T2A5jLI6ljMZ73Or1TjnjCWgAOxIyp0faQaiugjkMMqVkn+t52gNuBqEURkooLqYAPzpiizN5MZtf5O9O8fgYb+cqiw7ZwUzZoda007kfeuW4wAnPG+9X06OR7/9iaEAx7zWRLfcBvjZbMwEYfQgAVDvbLfc6geoDwKo6oVu+RrA4CWwtC9kJij3AUR4mwCoUBwEEeMWQKptj4AWMN17ng+ji/mVxitgDtixjnuaGHL3T038TL3qpKUEZOK+wUf2VmQXsZuVhWxtpHcwSEEYbRqs4tzjjTvZLwC/AJiinuCuqDEqAAAAAElFTkSuQmCC"  
    $iconCount = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAAN0lEQVRIiWNgGAUDDRjhrIor/xkYGBgYOnQwxcgBUHOYyDZgxIDROBgFlIPRVDTwYDQORgHlAADHmRgNDUab0wAAAABJRU5ErkJggg=="
    $iconAbout = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABZklEQVRIidWVPU7DQBCFn4OSAhEkqCkRByA0cAMoiKMoSsEZOAcEcQQOkdQcgZ86/KTB9EiRaCDio/CEWM6uvQlVnrSytfP2Pc/s7lhadURFQaAmqSWpKWlf0o6F3iU9SupL6kdR9LWwM9AGRpTjFWgtIrwGXAcI53EFVEIMXOJvllHdRgwMHbxeSFlc4tsO7pbF8oh94jXcNW9b/ARIbBzbXMfBfyE9HHMGXQcZoG7xJJuVzW161nSmutlNaXoqNwbQ7IhmseFZ86eVNWh4yHlMJJ3be9fDOZibAcaedPM4M/4h8OnhjJc1uDHuLvBRwHMaPAUY7Bn3toQ3nOpm9+A+oP4jex6V8O5cBoMAgwmApPUS3rwWUCW9JP/FCNdFM5NW0coMz4cf4LQwN9KuuKzBRUnpJKAC9Ioy8Xz5JSHtOmMUE7Ynz4CvzZT+MquSYqW9paFZP0okPSg9LYMoir6Dv3zl8AsKfI8ggolmqwAAAABJRU5ErkJggg=="
    $iconChange = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACCklEQVRIibWVPW8TQRCGn/EloQhKJEcUiRMaQKKmASHycYmbFFBEgpIuorCdmgbFLqHD5xRxQ0EXBEKAREGIDyjgHyCRVFg+CrAlPkIcJXdDYyNb9tnekzLVrnbmfXZmd3bBwBadStbEHyBmIq4i6ycCiCoOIBHE94EyygdV3XLXEtu94gcuUYuNAhcRViUmb2zHc+celi9EBuxkEllRzTXnwwex036glwTuAd8R5i3L+rSU92a7xfctUdOapSqlp/7HLOerY3U5fISwAtRU/MtuambPKIOwTABer038mq9O3kR5BsRRq9gzg4UN75oEerWUSTwYFAyQ3KyN+0f1XeAMBMlSevpt1wwk4DYi922ncsMEsH0n/hOk0JC81brWDhCuAGhMv5oAAPwgeNkYzoUCFM4CjPwd2jUGjI40D3c6FABYAPtxK0p/NO24F6ACMFw/PGeqeurgqNFs0lbedoDyHkCwrpsCVLVRGv0YClDVrcYgs5yvjpkASpnEC0Xvovq4p6PteK5d8NR2vKfZrHachemf0CHgB/4qUENYeTfx7Ulyszbeuq4i6yaQrm/RUt6bDWI8B+LADxBH0FeBDH0RPf4NIKq5nUyiLyj0sVvYKJ9HraKAHRo8ACT0vrupmT03PbUIQRIoCnwG/vTbcccmTAPsgqcAKpJ1U5O5fv6ROnZQ8Uhmek3/AehKxwor05QOAAAAAElFTkSuQmCC"
    #$iconShow = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABV0lEQVRIie2UPU/CUBSG35dCWDq4InTwLzgbUjYTNj9WN1kUE3+Jg9aIcXKG0XRRgcHR32CiWBMmVqPc42CutDeVloIxMT5b33N7Pu89wD8JMPxRO32pQ0kLQDmjvwGFjdtmyddCLmJWcjaHcwCoCKUVFnLmgTmca5xpARbOjwfIx4nd/WXG6UnUTgIxtT/aIo0uWbcsrgVhexy/W4GZWZbhTw0wK0Ju50TVUwcwZ5BEb6/UBtBOHeA7XC9Yo8IOiCom62UAoA+Ry26zfKfPRrdpQsbu0cMSC8ULAJvTEiDQVm+vu73DlVHqW+R6Q5uF4k3EueCK1rgiSjlC+BMZWywUr11vaJsVPMHYqF9v4DjogNgI20Qpp3dQGQBA1Xt2LOGjkVcnUgGFDXz2cmGkvteuN7Qp730Aq1oTwsdYNZRFWsJzAOuhX+6FeXemh5NlyJnW8izX9AN/r4CCsuo/AAAAAABJRU5ErkJggg=="

    # About
    $iconLinkedIn = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABJ0lEQVRIie2Sr07DUBSHv9N1YmuxGCAMFG5BIJBYeAhCSOpm2wUMju0FyOawPMEegQSFJYHQsTkUCd34k/UgCKQ0KdDugoHP3T/n9+Wee+CfL5DkYrEVbQl0EeaKhCkMUbx+0+m97VkpXado+Gs58yJ0k3tW+kLR8AQLmYIUV4juCBxNY8sUiGon9N3j63G1ATwXFdhZB2pZu0ut0Y1KtA5SNi5AdUWFk9Sg5SazRSrsh4EjYeC8G+xJPBsGjqiySRxvMK5WEF0Fucgt+Ix+0+k9Pbpn4YE8hL57LqhvVLB8GK2VK6O7Wvt+G6A0iU+NCrREXcBGqQNc7s3cGhUQf//niwly8OOCD0+ttSM1EZoc7d9tkcLQQOYgU4DiTSkZIOpNUf8XeQFjeFM4aqoyewAAAABJRU5ErkJggg=="
    $iconTwitter = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACA0lEQVRIie2SP2gTcRTHP+9y1+Qutf4dxCEJHXTUooOtWLqJILqIgrMgAXFqbMUlXUzqqCCosyIu4uBSFBHxz6A4ZQnFFrVasQ62uYsxXp5L06bJ5Uy66NDv+H3vfb7v9/jBhv61pNuBXVl1LNsbFzgDJICPCnd8y8ltXsR3Y95RhH2zY/GJloBk3r1mOU5m+oJU2sF7bO8JcDCg/B7YDiyYyMj0mPMJwFgpqwpC+nfZu79n8tumoADL9sbbwAH6gajC06rqibq5GiCiAovA8QrOu8RV71AzYfksYYqBRHdsdW41zKwqOeleFzjfYL0CvR2pmc8r0eicWfWWgEhIgM5edCKIaN0wG6u9ZeeSa7t7QQ4vW4Mgg77hY1a9vywPIKVGODSeCHBjXqYGE8DLDmgBqn1pdtYEqCH9BvIYGFpfAG9DA3o9Oy3wYp1wFB6FBhSyUpopO8MKZ4HXXfLnq+X4g2bTbDZStncPOADs7IYuIlc+Z6XlJxjNRtX300ARsDumK1MzKftGYHC7mWTOHRBDToNmghZpUKEn4o8UR/sWgoprTrT/plrz35f6TMvcbfh6TNFzoXBlyqByqji67Ue7lpUXpPKlI4jkgIGQbev6IKqXZ37G75KVWlhjy4mSeW9IqJ0UQ4ZVSQBbFL6KMicGb1B96JTjzwpZ+dXBIhv6D/QH8mKgEDaLDDsAAAAASUVORK5CYII="
    $iconWordpress = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAD8ElEQVRIid2VX4iUVRjGf+/5Znfn+2azxT/4J9dZKQpUSDKKErUugoLIyXDcQiMCk4T+XLRuRhcDEbVtGHQRtOJVRbUG6yaBN1uURX/MyEgrMXe2VSMoKXd3vtnd+c7Txcza6mxSl3Uun/Oe53nf5z3nPfBfX3apzeUFNZbScU7mc+CuAy2uHTsF/iuT2xeVw31HCzbxrwWyXaUNhrqBH83oRcnBkrvsFEA4OdJqLljjIW/GUjnrGOqI+v6ZQEEuG8bPG369KdiapCq/usS2gt0CtAENiCHBQCrwPYlSc1CyG3N9xVK4k4L56XSuLvMq+Y0Y62TJ3S5x34I9DqwEWoAMxjIzHkm8O2LyeVVsHfI3tUXxcxfzXSBQtcWvD5w2gnujRnypPjlJw5OT0R+VhiQnaUNb11huRouWF9Q4FpaOmdyDiSUNzuweZOdA90ocx9nXJs3CSGr4JiCbCqPwxKM2Xk1w5FZwPXNbomWHt9nkBRWU0nEOOBmV05/91Nk8UNyR2Y40D5hvxgqkuNiZ2VbckdkuNAeYD1hSHlt3PlufGnTY0Nnf4/V1Fsl8zozeUljqvOplNQGYYxBoAhaYeGzxLoW16O+BEECyFygoVWXzD2HqBXJ1AsAqlByUaJ8sx3dWeZK908yclarEdwF47E0gqe1cm02XblteUDNwhyrJR4LrZxBwCxsZP4NZq0n3Awx2zvoB+OZ8iDQOMNyZOYMYOI8Hlo7T5ZVAW1MwfhpYNFMFUywp4ParXzw3F0DQWythhDg6MGWTodemTjR4DsmUq+e6QMD/PEHTIsyGgMbJJNUOECTB3ppF+2kqLwgm4ocBSkGmTzCKOHZiR3haaCNQLJNeDJypFzD3JQrWmvR+NXNtATj5VPo4cARpLy7ZZFbFf+mwMbA+zPYv6Y5vBpYYNmBya2UcqhMwT7+HPFIP4IEblnaduwbAzPYQRwfA2oGVV3aPrABw5l/3xn4nnwe8J9mDs7wT/XUCUTncVx1cQQvQU0WDLQCDbeErFo5kqY4LEh9sruKZgXmXh1+AbZTZLjwLkW+d3RLWCxwt2IScdaBkdwLPgH0g2ExBjrwlImj/q1+6bwr/7ezoauCIl14y53oMe2LqFV/UZBjqiPow1xegtxK02eC9pVF5ddVDmyZAazYcrb5gF5StogccvA30DnZm3p3OWXdNi6VwJ+Y+dfChx78TldKfZ58dW4gwIAZKwHdOdgWAfBIpZZ+Y2cfFOHr6Yr6/nZRtXWM5QbfDhjD1evmDzXHzMMBI8+gSV3FrcJZHvhVZR/HJTP9MPJf8Mle9qoba4MrJWCVVv0yDYZkddqJ/dkvYP93z/9/6E+aHsqs7a3d1AAAAAElFTkSuQmCC"
    $iconBlog = "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"

    # Device
    $iconDeviceSync = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACCklEQVRIibWVPW8TQRCGn/EloQhKJEcUiRMaQKKmASHycYmbFFBEgpIuorCdmgbFLqHD5xRxQ0EXBEKAREGIDyjgHyCRVFg+CrAlPkIcJXdDYyNb9tnekzLVrnbmfXZmd3bBwBadStbEHyBmIq4i6ycCiCoOIBHE94EyygdV3XLXEtu94gcuUYuNAhcRViUmb2zHc+celi9EBuxkEllRzTXnwwex036glwTuAd8R5i3L+rSU92a7xfctUdOapSqlp/7HLOerY3U5fISwAtRU/MtuambPKIOwTABer038mq9O3kR5BsRRq9gzg4UN75oEerWUSTwYFAyQ3KyN+0f1XeAMBMlSevpt1wwk4DYi922ncsMEsH0n/hOk0JC81brWDhCuAGhMv5oAAPwgeNkYzoUCFM4CjPwd2jUGjI40D3c6FABYAPtxK0p/NO24F6ACMFw/PGeqeurgqNFs0lbedoDyHkCwrpsCVLVRGv0YClDVrcYgs5yvjpkASpnEC0Xvovq4p6PteK5d8NR2vKfZrHachemf0CHgB/4qUENYeTfx7Ulyszbeuq4i6yaQrm/RUt6bDWI8B+LADxBH0FeBDH0RPf4NIKq5nUyiLyj0sVvYKJ9HraKAHRo8ACT0vrupmT03PbUIQRIoCnwG/vTbcccmTAPsgqcAKpJ1U5O5fv6ROnZQ8Uhmek3/AehKxwor05QOAAAAAElFTkSuQmCC"
    $iconDeviceRestart = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACi0lEQVRIidWUT0jTYRjHP89vmwllEFNcm0WQEGi3dQ5nYdBFd1DoUlBBiBsEqVGXfp7KpEtOQ8h7KZjr4CHR6TWyk+siQX90Wzi9mAjT/Z4ObjK3uaY3v6eH9/0+38/78v6B4y7JFs2DK6aKPCtmigTcez5fKPYXWEb5ishkdXJ9ctxsTB0EMLLFbNBjimpfGYs6CVxCuAX6Pll95ltzKOb/L6BciGPLOAVyWZWHKIvARYUJ31C83zTVyPfb8wcs5ITkD+boU49rE4gC0fYxDa2txjpV5RWqvfM1CYDHuf59WU2DsTYRPgAplHcIt2H/GRSTL7R8DYwpoEIV/1zQPZmd29uSd0QdIjIAIKKPIkH3HRUxSwVnFQnUzYhq926vDHhH1FEAqNpJtILWoyw6a9xvAOa6zvaVefA4a93DQBS0fjcrDyCqfgCFt+Mdks6OzwY9Ze1ivEPSCKOZrLYCAOAFsKlMlxNYTGoY2d4rxQAegLTN9uuogO0K28/crHzArqlSSt6YUjq9aWR7rWKAGEDl5s65owK2HNvnM2W8GOALgBraclQAlt7IVJ+LACQMoHC/fUxth81uH1ObqN4FUJGPBYDq5Pok8B1oXFuNdR4WsPonHgAaRFjasLvCe8vONTWHYn6FCSAF1s1IoG6mnPCm1yvXxZApwI5qWyTo2dtBwY3xDcX7Ue0FUqLa7ax1D+c+vH3BptpxxrtEGAAcqryYC7qf5HoKAKapxnxN4nkGAhBFGFXDmMYyfgBgWBckbbUA94AGQAV5eTXpemqaYuXmHXjnd39WGQCtP8gDIMKSqvZEAp5w0flSzd4RdVTtJFozf4sXqMs0/UZYsJDwht0VXngg26Vyjrf+AYUP8PvzHZOfAAAAAElFTkSuQmCC"
    $iconBitlockerRotation = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAC7klEQVRIidWVTWxMURTHf+d1pq1ESRiMaQkNG8RCIyQSZhohWBiSComNj0Skrz5SJGz6dqXd6VRIiB1SIcZCfMQMCwkNsVELJSTMDOlUaNNgat6xmI8+7cwLds7qvnP/5/8/97xz7oX/3cRts8nqq0z7poVRDSMsA+qALPABeI5qj2/wy+2r1uLMXwuEupNbUTqBetcMhX7AjDUH7hZ8jV0JK9ZSawEY4wMsS41QJNGBcg2oR3mhyiGQJd5vxuRqu2pqVo2lKnIEeKnKQlXuBLtTbQDB7lSbirSVPUEokugAOQpkEDm8ZsB/1rLELpV90FKP+FIHgHagEngErAKImwGZIJAvyzUgI2psiLX4Y27lKcadSW3C1huAp+ArCBQdTVZfZTpXcxA5HDPHyIMX31YzUtUusB1FgSs6+ceJB7vmfweQrL1cRYpcTis6075pYdB6lBe+mf5zv6Fy5AeBy4AgHJKRKgVaG7sSlrPmZQXyrYjC+avbJOsECWwHLsXNwE6AUFcSYAfQmu8Wq5zAWBcJDQAVKvdK4Pyi+noMqq8QZpcjHZdczkKR5BBQk5nknfJoz4zhgj8YSfYKLC8T/yRuBla6CTh/TMmhcyEHWOH82HB6cMp348dXYChuBqbC74OWBKge+TnHLSM3++YdnZtfpgo+p8BTADV03b8KYOv6/Kq3hIBEART2NvVoxd9yN/VohajuBlCRmxMEfOnPN4A3wOLBgeR+R2wv5Uz1cWE58CllAotE6B/2+KPFtJ34xkhyi8J1IAP2xrhZd/9Psg+eTqwVQ24BHlTD8Zba4gkmXnbdqVOoHgMyonpk+qzAmfGDVyS21MP0VLMInYBXlZMPWgLHnZgJApalxsMZH9vzIgB9CBfUMO5hG+8AMOx5krXXAXuARYAK0rE67T8x/uYt++AEu5JhEekEXVAOA7kHR1WPxs3aaMl9t+CGc+qt+flxs6iGgQZyTyYC7xGe2Uh02OOPPtsno248/7f9Aq1TEoOuYXfCAAAAAElFTkSuQmCC"
    $iconDefenderScan = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACEklEQVRIidWVPWhTURTH//+0eQiaJSaQvDpJcelmBMcki459LdRFcC3I6+CQqujwRtsHopgOHRwdpEiTgoIIpp014lIXPwYrj0CfRaxDyddx8CU831dftEvPdN+95/5/59x73j3AcTdGLc4Z24qdSWsQ0UCcB3DGWfoGwTuQtYy9V1szptojA8or1iwEJoCzhwT5mUDlta6uxwIYhiS2MtY9gBVn6gOAxz1JvFIU5Wuvc/AjOFQuF3dztw2Dfff0uNfPJX4g5N1sNvdg7Qp7w8yqVnAeIotb2RYA3AzNwDmWZwDaSHC2cT3/3KtTrloSTBhwMLO5oNYG34nBYM7YVpwzB0Cb7L6PEgozkmZhVZI+gJ1JaxheqKjSG3t5+f5OenSETKa6rWkfgMCMx3OqrYy9uGS2To6KoIjmA4BSCPC92DnRf1oyxFcMh9iFoexgUK5a+wBOhWx4UrTz17wl6NrrvfhfDV1NAe4Mou3q5unWw5i+ADAMxJ26BeBc2A5S9HLV0mMChj+LO4O3ccOLYW8CAKwflbqQGz7Az2RuHeCnI9D/kt3d8wOa8+wQsvif4gKRG+7n+68q+vPkivnP6oKlxsLEhnvOV6ZFW70FcnlUbYJLpe/5O96F0IZTemRpJE1AJqOUSXwUkUpDnwgsksiWWViVZKrbmnbelgKclklgB0SzD9b3x3P15jw7UTrH234D+7qw57KK2MsAAAAASUVORK5CYII="
    $iconDefenderSiganture = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABw0lEQVRIid2UsW7TUBSGv3ObDlVeoHYKXVGkblURTEkjMbDDWMKCVDXuhhALYoaJkFCVhYpu9AGQQCUWiKVrpSpjq1YxL5BaamsfBmrJctyb1EzwS3f57/H333uObfjXJVmj3gnug24Cc9dknYjKk2+e8zltmtG6QnCAORXdzJo5AYXgiW5MEjBeIo+A4SSlhQJ6a85HVRYF9v824AzVZyW9qPRariQLwPfcfik0dwTdsgFKtk1FX/he5dW4UxYOmNZoG6DeGfwE7iZ+r+VKox1Uz028A1K1Mawt+urdHDTaQTUNB6h1g2ZsdA+YV5HHhQNSoGEaJKofgLKJZclfc6wzsAZcgo7yQCr82F13DpY3jis2hnUGgm6VwqnWl6ezQ/jT+2yNRlMrhQNsWt44rlzCX1434AiYB1CkeT4TLzXawYPddeeg3hloUqRRLu8wa4zMQFRWgdOUVY2N7tW6QdN2UuBUhdURXl5l7e3glhE+KSyMgSbqR2oefvdmR34duW+R77n98Cy6DbyfAL49HZrFPDhccYO06t1gBdV3QDmzFary3PfcN7bnxwZAbsuubEmhAIB7r3+VL2aiDkD62/j/9Ru9Zqiay1/nrAAAAABJRU5ErkJggg=="
   
    $iconSave = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABC0lEQVRIie2UPVICQRCFv96f8gwsHkYIvQMp0ZqKiaUYsRqyiWaWngMOgytnYF1sEyiXmbEcWDfCL+s3/fpVz1QN/PMLUi96+fIc9Ano7jVEdTy76N66zoLdUh/3HQ6gIjf9aeEMMDZ4V4B5moir2WTb/z1MslnauaprxgbNUHTUz5eT1gK2Ia0GmEQu0bzbJrS+wfEErEAuqzhOqjhOUB0BpY/R+cg2cj1POw814f4sL0SQyY+WDV4bqIQvdmb87OP1ClhHYn0dQbAK/ywgKsuBJX6Gtuby+jQhctebFkSsXwE+JByoMj4k4A04dfSdIJJVRBkYX7DNol7sXJGoDDchh7JQYdjAf4x8AQtPRQ5j4u9sAAAAAElFTkSuQmCC"
    $iconNewRow = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAApklEQVRIie2UwQ3CMAxFnyumqOgu9MYkvcA45QKLcCu7VMoa5pJUxKJAQqGq1HdLZP1vx45h5Q3yeNid3F6UC7DN1OtVaG6H8houishNOX8hDlB5jYGNDQDojqWQQd06DRqBYiR2MpIM6tapz/I3Bjks38BOUcTYe9v7V1M3bwU2s5B5yj9ZfpPn7YElZ0f9vYIeqFL3zRONgagCFRobkCruNVY+5w4EICu+rqoZ4wAAAABJRU5ErkJggg=="
    $iconRemoveRow = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABzUlEQVRIidWSwU4TYRSFvzuFhMgLtLUsfAFc4Lo6w0p2rHgBwwI7WmJ0pU0jmhgUEtOxCe9A2GjixtLq0u4krl0UB2J8AJT0Py6aJjJOkba66Fn9/39u7v3PPQcmHfb7xY+OlkA7QGHIPocmW90Pc2+ThHf2OlJzgIJMO2nEVLIQoFnKW7LQj2L9hZtLG+ClPf5LTP6ARIp6ex4Vaf78dwXJFA38yQVSlIrJMNnzuldPfnYvpXGpKxoWjbW5T4O4kVJksFv8nlupVs0FUbwscRfjGoDgI3jbrVL2DYy2om/e9MytatWcH33dFOxhXAdmgVkD33Cv/Vr8eKCCi6QoiOJlwR5wgtk9pEpPgW0YegHMmGxpZJMFZQAz3W/eztU9Z4HnLGiVcq9MegDgTOvjmLwAIFmlWDt+3wizBwCL9c68c1YBMFgYJ6b9QChjcv1Hh/cDcdrnkgoOgcJ5aSrWjq98CLNfBG0D36Qn+2H+82K9M3/anVZzLXvgR/Ez4CXQPqPAZKtA57xvT3lupXfytgFk9jyI4rJzmUbGXCOI4jKwCUhOW3+kZRjciOINg4cplCQetcL807EGAAS1o5vOtG490wW05bTVunP5HcAvysG6Vtp3MgsAAAAASUVORK5CYII="
   

 

    # Add image to UI
    $WPFImgHome.source = Get-DecodeBase64Image -ImageBase64 $iconHome
    $WPFImgSearchBoxDevice.source = Get-DecodeBase64Image -ImageBase64 $iconSearch
    $WPFImgRefresh.source = Get-DecodeBase64Image -ImageBase64 $iconRefresh
    $WPFImgMaxDevices.source = Get-DecodeBase64Image -ImageBase64 $iconPaging
    $WPFImgDeviceCount.source = Get-DecodeBase64Image -ImageBase64 $iconCount
    $WPFImgButtonAbout.source = Get-DecodeBase64Image -ImageBase64 $iconAbout
    $WPFImgChangeCustomAttribute.source = Get-DecodeBase64Image -ImageBase64 $iconChange
    #$WPFImgShowCustomAttribute.source = Get-DecodeBase64Image -ImageBase64 $iconShow

    #About
    $WPFImgTwitter.source = Get-DecodeBase64Image -ImageBase64 $iconTwitter
    $WPFImgWordpress.source = Get-DecodeBase64Image -ImageBase64 $iconWordpress
    $WPFImgLinkedIn.source = Get-DecodeBase64Image -ImageBase64 $iconLinkedIn
    $WPFImgBlog.source = Get-DecodeBase64Image -ImageBase64 $iconBlog

    $WPFImgTwitterFs.source = Get-DecodeBase64Image -ImageBase64 $iconTwitter
    $WPFImgWordpressFs.source = Get-DecodeBase64Image -ImageBase64 $iconWordpress
    $WPFImgLinkedInFs.source = Get-DecodeBase64Image -ImageBase64 $iconLinkedIn
 
    $WPFImgDeviceSync.source = Get-DecodeBase64Image -ImageBase64 $iconDeviceSync
    $WPFImgDeviceRestart.source = Get-DecodeBase64Image -ImageBase64 $iconDeviceRestart
    $WPFImgBitlockerRotation.source = Get-DecodeBase64Image -ImageBase64 $iconBitlockerRotation
    $WPFImgDefenderScan.source = Get-DecodeBase64Image -ImageBase64 $iconDefenderScan
    $WPFImgDefenderSiganture.source = Get-DecodeBase64Image -ImageBase64 $iconDefenderSiganture
   
    $WPFImgSave.source = Get-DecodeBase64Image -ImageBase64 $iconSave
    $WPFImgNewRow.source = Get-DecodeBase64Image -ImageBase64 $iconNewRow
    $WPFImgRemoveRow.source = Get-DecodeBase64Image -ImageBase64 $iconRemoveRow  
    $WPFImgResetRow.source = Get-DecodeBase64Image -ImageBase64 $iconDeviceRestart  

    $WPFImgSaveMulti.source = Get-DecodeBase64Image -ImageBase64 $iconSave
    $WPFImgNewRowMulti.source = Get-DecodeBase64Image -ImageBase64 $iconNewRow
    $WPFImgRemoveRowMulti.source = Get-DecodeBase64Image -ImageBase64 $iconRemoveRow  
    $WPFImgResetRowMulti.source = Get-DecodeBase64Image -ImageBase64 $iconDeviceRestart  

    # Fill combo box    
    $valueGroupCount = "10", "100", "500", "1000", "5000", "10000", "All"
    foreach ($value in $valueGroupCount) { $WPFComboboxDevicesCount.items.Add($value) | Out-Null }
    $WPFComboboxDevicesCount.SelectedIndex = 2

    # Reset lables
    $WPFLableUPN.Content = ""
    $WPFLableTenant.Content = ""
}