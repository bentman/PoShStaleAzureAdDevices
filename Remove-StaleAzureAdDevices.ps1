<#
.SYNOPSIS
This script removes specified stale devices from Azure AD.

.DESCRIPTION
The script authenticates with an Azure AD App Registration and uses the Microsoft Graph API to remove specified devices from Azure AD.

.PARAMETER clientId
The client ID of the Azure AD App Registration.
.PARAMETER tenantId
The tenant ID of the Azure AD tenant.
.PARAMETER clientSecret
The client secret of the Azure AD App Registration.
.PARAMETER staleDevices
The array of stale devices to be removed. Each device in the array should be a hashtable that includes the 'id' of the device.

.EXAMPLE
.\Remove-StaleAzureAdDevices.ps1 -clientId 'your-client-id' -tenantId 'your-tenant-id' -clientSecret 'your-client-secret' -staleDevices $staleDevices

.NOTES
The script uses the MSAL.PS PowerShell module to authenticate with Azure AD. Make sure this module is installed before running the script.

.SETUP
To create a Runbook in Azure Automation with this script, follow these steps:

1. Open the Azure portal and navigate to your Automation Account.
2. Under "Process Automation", select "Runbooks".
3. Click on "+ Create a runbook".
4. Enter a name for the Runbook (e.g., "Remove-StaleAzureAdDevices"), select "PowerShell" as the Runbook type, and click on "Create".
5. In the editor that opens, paste the PowerShell script.
6. Click on "Save".
7. To test the Runbook, click on "Start" and enter the required parameters in the pane that appears on the right. 
    These parameters are the client ID, tenant ID, client secret, and stale devices.
8. Click on "OK" to start the Runbook. The output will appear in the pane at the bottom of the screen.
9. After testing, remember to publish the Runbook by clicking on "Publish".

The Runbook can now be scheduled to run at specific times or triggered by specific events. 
For logging and audit trails, you can use the "Jobs" under "Process Automation" in your Automation Account. This will show you a history of all the Runbook jobs, including their status, start time, end time, and any errors or output.

.LINK
Azure Automation Documentation
https://docs.microsoft.com/en-us/azure/automation/

Azure AD App Registration: Create a client secret
https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#create-a-new-application-secret

Start-AzAutomationRunbook Documentation
https://docs.microsoft.com/en-us/powershell/module/az.automation/start-azautomationrunbook

.NOTES
    Version: 2.0
    Creation Date: 2023-06-10
    Copyright (c) 2023 https://github.com/bentman
    https://github.com/bentman/PoShStaleAzureAdDevices
#>

param (
    # The client ID of your Azure AD App Registration
    [Parameter(Mandatory=$true)][string] $clientId,
    # The tenant ID of your Azure AD tenant
    [Parameter(Mandatory=$true)][string] $tenantId,
    # The client secret of your Azure AD App Registration
    [Parameter(Mandatory=$true)][string] $clientSecret,
    # The list of stale devices to remove
    [Parameter(Mandatory=$true)][array] $staleDevices
)
# Import the MSAL.PS module
try {
    Install-Module -Name MSAL.PS -Force
} catch {
    Write-Error "Failed to import MSAL.PS module. Error: $($_.Exception.Message)"
    return
}
# Authenticate with your App Registration and get an access token
try {
    $token = Get-MsalToken `
        -ClientId $clientId `
        -TenantId $tenantId `
        -ClientSecret $clientSecret
} catch {
    Write-Error "Failed to get access token. Error: $($_.Exception.Message)"
    return
}
# Define the headers for the API request
$headers = @{
    "Authorization" = "Bearer $($token.AccessToken)"
}
foreach ($device in $staleDevices) {
    # Define the URI for the Microsoft Graph API endpoint to remove the device
    $uri = "https://graph.microsoft.com/v1.0/devices/$($device.id)"
    # Send a DELETE request to the API
    try {
        Invoke-RestMethod `
            -Uri $uri `
            -Headers $headers `
            -Method Delete
    } catch {
        Write-Error "Failed to remove device '$($device.id)'. Error: $($_.Exception.Message)"
    }
}
