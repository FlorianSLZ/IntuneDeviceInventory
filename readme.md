[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)

# IntuneDeviceInventory (PowerShell Module)



# Manual import
Import-Module ".\IntuneDeviceInventory\IntuneDeviceInventory.psd1" -Verbose

# Examples
Here are some examples to start with

## Get all Devices (inc. custom fields)
$All = Get-IDIDevices

## Adding a Prperty
Add-IDIProperty -PropertyName "Monitor"

## Get a Singel device
$Device2change = $All | Out-GridView -OutputMode Single

## Set Device Property
$Device2change.Monitor = "Samsung Odyssey ARK"

## Update Device in Intune with changes
Set-IDIDevice -IDIDevice $Device2change

## Sync all devices
Sync-IDIDevice -all