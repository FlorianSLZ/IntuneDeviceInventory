#Requires -Modules AzureAD

# Managed Identiy Object ID
$MI_objid = Read-Host "Object (principal) ID (ex. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
# Microsoft Graph App ID
$AppID = "00000003-0000-0000-c000-000000000000"
# API permissions
$permissions = "DeviceManagementManagedDevices.ReadWrite.All"

# Connect to Azure AD
Connect-AzureAD

# Get service principal of the Managed Identiy 
$app = Get-AzureADServicePrincipal -Filter "AppID eq '$AppID'"

# Assign permissions to the Managed Identity service principal
foreach ($permission in $permissions){
   $role = $app.AppRoles | Where-Object Value -Like $permission | Select-Object -First 1
   New-AzureADServiceAppRoleAssignment -Id $role.Id -ObjectId $MI_objid -PrincipalId $MI_objid -ResourceId $app.ObjectId
}
