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
    $iconBlog = "iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAdVBMVEX///8wMDArKytZWVktLS0oKCgbGxsZGRkjIyMcHBwfHx/a2toSEhK+vr5WVlYmJibm5ubg4OA8PDxmZmbs7Ozy8vK6urqrq6tJSUkQEBCSkpJpaWnHx8dSUlKFhYXW1takpKTExMR3d3eAgICxsbFAQECLi4uOY5+ZAAAEi0lEQVR4nO3d6XbiIBgG4ICQxCxGjftuR73/SxxT23EZbRGSD8T3+dlz7Ml7QtgCJAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4D0Nu710kY92o3yR9rpD25dTrzSfzZd9nmRR2G63wyhLeH85n+Wp7QurRbppyaQdSy7YJcFl3E5ka/PaKYeLFTver+ts1zmTKVstXrXIpqt+VDxO9y9lEe0Pr3gnR50k/j3eV8g46YxsX/CTxjLkivFOeCjHti/6CeN+qHr7Lm5k2N/ZvnBF20n0fL7PjNFkYfviFQzKJ8vnJR6WA9sBfjOeSu18FTl1+3HslpFRvkpUdm3HeCwXZjfwpBC57SCPHDK9GuaWyGa2o9w1LMNa8lXC0sGO3GAS1xaQsXjiXJ3aZXU8gmeSOVbfrAv9RvA+Lp3qja9lPXXMJeFSxK7CIEknojMFdcDqLqInnDlS3Qwn9VYyZ3LiRqNR1tlMXItL2+Eqh/oa+v+FDvRuRlmDARnLrPdRu6KJavRMCNsVatlULfOtsPwobszHg7+JrA6JB9PGAzI2tdkqNl5GK9JiOd022VCchfZm4CbN9NZu8YmtgOPmq5mTyNZUcb/ZpvBM9O0EHLeJAh6fRDstRiODwvuEtBFwRFORnoQ2Xr51aCrSE96hD5gmhAEZS+gnbVaa417NOx8fqAMO9ZoKIUq94ZbYU09oLPRae54Ga72+bETddftTaAVsBbpVVLEiTqhX1j4TtrQSCkYbMNWbnTFIyKa0telGryY1SZhsSBNqXqVJws/f0tF8E2OSkLZvqtuhMUlI263JNQdORgnblJPDB90um0nCmHKGX3eOzSihnBMmXGpepFFCvqQLqNntNkwo+nSd767uRLBRQsbpXtL0dOegzBImPbKEa92JUrOEGV2DqD6bz68V1XRLp7j5q+o/Ixwi5ooJBW9d63wcf/3RufnrD9sVroRbsoQjxedQqBWrtWLCNt2U4k6tW8pVX4uVagWVMKH/91D5OZRKz6HqUIzwOfS/LvW/PfS/T+N/v9T/sYX/48M3GOPPvJ+n8X+uzf/5Uitz3pwyoJX3FrQL+Px/9+T/+0P/3wG/wXt8/9di6K+nUZ1Zu/kh+Xoa/9dEvcG6NuK1ibTLFE5o15da2f7UwM7YR4j7pN/GdDcxtLRY3/u1+m+w38L/PTNvsO+JaO8a5RzbLZL9h5nVXfkElY3dPaTHcqo1TnyC7X3Aze/ltn9yRO77fvwgmPl+pkKz52LYbCjO/D/bxP/zaaq33p6fMRQEqe/nRFURPT/r6w3Oa3uDM/dqPjdx7kgzcWNW19mXUyd6Mvfkoo6RRsEc6Is+MqjlDFoHH8ELxucIZ26fIxwYnwU9d/sGniw8P8+7stM7k33/KmeyV3b82XP1I/FK+Sp565lvI8Qth1uIh9LDXvn7FnTrm+tVfaNk+uM3SmT1jZK1m100Vemm5El49zszYcLL8avevWvpdjZf7kUSfX0rKErEfjmfbR0bAZr6/N7TNh/lWw+/9wQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyv4CEOVTynxhXaUAAAAASUVORK5CYII="

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