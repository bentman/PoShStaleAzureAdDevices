<#
.SYNOPSIS
This script starts the Get-StaleAzureAdDevices and Remove-StaleAzureAdDevices runbooks, effectively managing the detection and removal of stale Azure AD devices.

.DESCRIPTION
The Manage-StaleAzureAdDevices script is designed to manage stale Azure AD devices. 
It starts the Get-StaleAzureAdDevices and Remove-StaleAzureAdDevices runbooks, detects stale devices, and removes them.

.PARAMETER clientId
The client ID of your Azure AD App Registration.
.PARAMETER tenantId
The tenant ID of your Azure AD tenant.
.PARAMETER clientSecret
The client secret of your Azure AD App Registration.
.PARAMETER staleDays
The period of inactivity (in days) after which a device should be considered stale.

.EXAMPLE
.\Manage-StaleAzureAdDevices.ps1 -clientId '<client_id>' -tenantId '<tenant_id>' -clientSecret '<client_secret>' -staleDays 90

.NOTES
This script should be executed in an environment where the Azure PowerShell module is installed and you are authenticated with an account that has the necessary permissions.

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
# Start the Get-StaleAzureAdDevices runbook and get its output
$getJob = (
    Start-AzAutomationRunbook `
        -AutomationAccountName 'YourAutomationAccountName' `
        -Name 'Get-StaleAzureAdDevices' `
        -Parameters @{ 
            'clientId' = $clientId; 'tenantId' = $tenantId; 'clientSecret' = $clientSecret; 'staleDays' = $staleDays 
        } -MaxWaitSeconds 3600 -Wait)
$staleDevices = $getJob.Output
# Start the Remove-StaleAzureAdDevices runbook with the output of the Get-StaleAzureAdDevices runbook
Start-AzAutomationRunbook `
    -AutomationAccountName 'YourAutomationAccountName' `
    -Name 'Remove-StaleAzureAdDevices' `
    -Parameters @{ 
        'clientId' = $clientId; 'tenantId' = $tenantId; 'clientSecret' = $clientSecret; 'staleDevices' = $staleDevices 
    } -MaxWaitSeconds 3600 -Wait
