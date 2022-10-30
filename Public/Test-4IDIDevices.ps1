function Test-4IDIDevices {

    <#
    .SYNOPSIS
        Test if Get-IDIDevices already run (presence of $global:IDIDevices_all)

    .DESCRIPTION
        Test if Get-IDIDevices already run (presence of $global:IDIDevices_all)

    #>
    
    if(!$global:IDIDevices_all){
        Write-Verbose "Devices not retrived yet, will do that for you..."
        Start-IDI -All
    }  
}
