# Test content
<#

$IDI_Intune = '
{
	"Monitor":  "Dell 24inc",
	"Mouse":  "Logitech MX",
	"purchade date":  "2020.01.23",
	"memory":  "15.8 GB",
	"wifiConnectionActive":  "False"
}
' | ConvertFrom-Json


$WebhookData = '
{
    "data":  {
                 "hostname":  "SCLOUD-FLORIAN",
                 "processor":  "11th Gen Intel(R) Core(TM) i5-1145G7 @ 2.60GHz",
                 "memory":  "15.8 GB",
                 "wifiConnectionActive":  "False"
             },
    "validation":  {
                       "aadDeviceId":  "99acf826-7869-49cf-891d-51b2c7665686",
                       "aadDeviceJoinDate":  "07/03/2022 11:41:08",
                       "tenantId":  "acc82e89-04ec-460e-a300-f962ff2c4901"
                   },
    "time":  "01/15/2023 16:15:35"
}
'

#>

param
(
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
)

$Data = $WebhookData | ConvertFrom-Json
$Validation = $Data.validation
$IDI_local = $Data.data

# Check Teannt ID
$uri = "https://graph.microsoft.com/v1.0/organization"     
$TenantInfo = (Invoke-MSGraphRequest -HttpMethod GET -Url $uri -ErrorAction Stop).value
if($TenantInfo.id -eq $Validation.tenantId){
	Write-Output "Tenant ID matched: $($TenantInfo.id) ..."
}else{
	Write-Error "Wrong Tenant ID in request: $($Validation.tenantId)"
	break
}


# Get Intune Device by aadDeviceID
$IDI_Intune = Get-IDIDevice -azureADDeviceId $Validation.aadDeviceId

if($IDI_Intune.enrolledDateTime -eq $Validation.aadDeviceJoinDate){
	Write-Output "AAD Device ID and enrollemt Date matched."
}else{
	Write-Error "Wrong Validation in request: $($Validation)"
	break
}

# Compare and add or set notes
$properties_local = $IDI_local | Get-Member -MemberType NoteProperty
foreach($property in $properties_local){
	if (-not ($IDI_Intune | Get-Member -Name $property.Name)){
		$IDI_Intune | Add-Member -NotePropertyName $property.Name -NotePropertyValue $IDI_local.($property.Name)
	}else{
		$IDI_Intune.($property.Name) = $IDI_local.($property.Name)
	}
}

# save notes in Intune
Set-IDIDevice -IDIDevice $IDI_Intune