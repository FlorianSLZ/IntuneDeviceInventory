#### Configuration ####
$time = Get-Date
function Get-ValidationInfo{
		$AzureADJoinInfoRegistryKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo"
        $AzureADJoinInfoKey = Get-ChildItem -Path $AzureADJoinInfoRegistryKeyPath | Select-Object -ExpandProperty "PSChildName"
		if ($AzureADJoinInfoKey -ne $null) {
                if ([guid]::TryParse($AzureADJoinInfoKey, $([ref][guid]::Empty))) {
                    $AzureADJoinCertificate = Get-ChildItem -Path "Cert:\LocalMachine\My" -Recurse | Where-Object { $PSItem.Subject -like "CN=$($AzureADJoinInfoKey)" }
                }
                else {
                    $AzureADJoinCertificate = Get-ChildItem -Path "Cert:\LocalMachine\My" -Recurse | Where-Object { $PSItem.Thumbprint -eq $AzureADJoinInfoKey }    
                }
			if ($AzureADJoinCertificate -ne $null) {
				$AzureADDeviceID = ($AzureADJoinCertificate | Select-Object -ExpandProperty "Subject") -replace "CN=", ""
				$AzureADJoinDate = ($AzureADJoinCertificate | Select-Object -ExpandProperty "NotBefore") 
			}
		}
    $AzureADTenantInfoRegistryKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo"
	$AzureADTenantID = Get-ChildItem -Path $AzureADTenantInfoRegistryKeyPath | Select-Object -ExpandProperty "PSChildName"
	

    return @"
    {
        "aadDeviceId" : "$($AzureADDeviceID)"
        ,"aadDeviceJoinDate" : "$(($AzureADJoinDate).ToString("MM/dd/yyyy HH:mm:ss"))"
        ,"tenantId" : "$($AzureADTenantID)"
    }
"@
}

function  Get-DeviceMemory {
    $system = Get-WmiObject -Class Win32_ComputerSystem
    return "$([Math]::Round(($system.TotalPhysicalMemory/ 1GB),1)) GB"
}

function Get-ConnectedDevicesPerClass {
    param(
        $class
    )
    return (Get-PnpDevice -PresentOnly | Where-Object {$_.Class -eq $class}).FriendlyName[0]
}

function Test-ConnectionType {
    param(
        [Parameter(Mandatory = $true)] $test
    )
    $adapters = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object { $_.NetConnectionStatus -ne 2 }

    foreach ($adapter in $adapters) {
        $nic = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.Index -eq $adapter.Index }
        if ($nic.Description -like $test) {
            return $True
        }
    }
    return $False
}

####### Start #######

$result = @"
{
    "data" : {
        "hostname" : "$($env:computername)",
        "processor" : "$(Get-ConnectedDevicesPerClass -class 'Processor')",
        "memory" : "$(Get-DeviceMemory)",
        "wifiConnectionActive" : "$(Test-ConnectionType -test "*Wireless*")"
    }
    ,"validation" : $(Get-ValidationInfo)
    ,"time" : "$($time.ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss"))"
}
"@ | ConvertFrom-Json

$result | ConvertTo-Json
