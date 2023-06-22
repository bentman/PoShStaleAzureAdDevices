<#
.SYNOPSIS
This script identifies stale devices in Azure AD.

.DESCRIPTION
The script authenticates with an Azure AD App Registration and uses the Microsoft Graph API to retrieve all devices in Azure AD. 
It then filters these devices based on the 'approximateLastLogonTimestamp' property to identify devices that have not been used for a specified number of days.

.PARAMETER clientId
The client ID of the Azure AD App Registration.
.PARAMETER tenantId
The tenant ID of the Azure AD tenant.
.PARAMETER clientSecret
The client secret of the Azure AD App Registration.
.PARAMETER staleDays
The period of inactivity (in days) after which a device should be considered stale.

.EXAMPLE
.\Get-StaleAzureAdDevices.ps1 -clientId 'your-client-id' -tenantId 'your-tenant-id' -clientSecret 'your-client-secret' -staleDays 30

.NOTES
The script uses the MSAL.PS PowerShell module to authenticate with Azure AD. 
Make sure this module is installed before running the script.

.SETUP
To create a Runbook in Azure Automation with this script, follow these steps:

1. Open the Azure portal and navigate to your Automation Account.
2. Under "Process Automation", select "Runbooks".
3. Click on "+ Create a runbook".
4. Enter a name for the Runbook (e.g., "Get-StaleAzureAdDevices"), select "PowerShell" as the Runbook type, and click on "Create".
5. In the editor that opens, paste the PowerShell script.
6. Click on "Save".
7. To test the Runbook, click on "Start" and enter the required parameters in the pane that appears on the right. 
    These parameters are the client ID, tenant ID, client secret, and stale days.
8. Click on "OK" to start the Runbook. The output will appear in the pane at the bottom of the screen.
9. After testing, remember to publish the Runbook by clicking on "Publish".

The Runbook can now be scheduled to run at specific times or triggered by specific events. 
For logging and audit trails, you can use the "Jobs" under "Process Automation" in your Automation Account. 
This will show you a history of all the Runbook jobs, including their status, start time, end time, and any errors or output.
Azure Automation Documentation
https://docs.microsoft.com/en-us/azure/automation/

Azure AD App Registration: Create a client secret
https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#create-a-new-application-secret

.NOTES
    Version: 2.0
    Creation Date: 2023-06-10
    Copyright (c) 2023 https://github.com/bentman
    https://github.com/bentman/StaleAzureAdDevices
#>

param (
    # The client ID of your Azure AD App Registration
    [Parameter(Mandatory=$true)][string] $clientId,
    # The tenant ID of your Azure AD tenant
    [Parameter(Mandatory=$true)][string] $tenantId,
    # The client secret of your Azure AD App Registration
    [Parameter(Mandatory=$true)][string] $clientSecret,
    # The period of inactivity (in days) after which a device should be considered stale
    [Parameter(Mandatory=$true)][int] $staleDays
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
# Calculate the date before which a device should be considered stale
$stalePeriod = (Get-Date).AddDays(-$staleDays)
# Define the URI for the Microsoft Graph API endpoint to get all devices
$uri = "https://graph.microsoft.com/v1.0/devices"
# Define the headers for the API request
$headers = @{
    "Authorization" = "Bearer $($token.AccessToken)"
}
# Send a GET request to the API and get the response
try {
    $response = Invoke-RestMethod `
        -Uri $uri `
        -Headers $headers
} catch {
    Write-Error "Failed to get devices. Error: $($_.Exception.Message)"
    return
}
# Extract the devices from the response
$devices = $response.value
# Filter the devices based on the 'approximateLastLogonTimestamp' property
$staleDevices = $devices | 
    Where-Object { $_.approximateLastLogonTimestamp -le $stalePeriod }
# Output the stale devices
$staleDevices
