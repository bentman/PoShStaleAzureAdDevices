# Stale Azure AD Device Management

This repository provides a collection of PowerShell scripts for managing stale Azure AD devices. The scripts use the Microsoft Graph API to identify and remove devices that have been inactive for a specified period.

## Scripts

### 1. Get-StaleAzureADDevices.ps1

This script identifies stale devices in Azure AD by querying the Microsoft Graph API. It authenticates with an Azure AD App Registration and retrieves all devices in Azure AD. The script then filters these devices based on the 'approximateLastLogonTimestamp' property to identify devices that have not been used for a specified number of days.

### 2. Remove-StaleAzureADDevices.ps1

This script removes the stale devices identified by the 'Get-StaleAzureADDevices.ps1' script. It authenticates with an Azure AD App Registration and uses the Microsoft Graph API to remove the identified devices from Azure AD.

### 3. Manage-StaleAzureADDevices.ps1

This script combines the functionality of the 'Get-StaleAzureADDevices.ps1' and 'Remove-StaleAzureADDevices.ps1' scripts. It first runs the 'Get-StaleAzureADDevices.ps1' script to identify stale devices and then runs the 'Remove-StaleAzureADDevices.ps1' script to remove them.

## Usage

1. Ensure you have the Azure PowerShell module installed on your machine.
2. Create an Azure AD App Registration and obtain the necessary credentials (client ID, tenant ID, and client secret).
3. Review the script files and update the parameters as needed.
4. Run the scripts individually or use the 'Manage-StaleAzureADDevices.ps1' script for a combined workflow.

To create a schedule for automatically managing stale Azure AD devices, follow these steps:

1. Open the Azure portal and navigate to your Automation Account.
2. Under "Process Automation," select "Schedules."
3. Click on "+ Add a schedule" to create a new schedule.
4. Provide a name for the schedule (e.g., "Manage-StaleAzureADDevices-Schedule").
5. Specify the frequency and timing for the schedule.
6. In the "Runbook" field, select the "Manage-StaleAzureADDevices" runbook from the dropdown list.
7. Set the required parameters for the runbook, such as `clientId`, `tenantId`, `clientSecret`, and any others needed.
8. Click on "Create" to save the schedule.

The schedule is now created, and the `Manage-StaleAzureADDevices.ps1` script will run automatically based on the defined frequency and timing. It will execute the `Get-StaleAzureADDevices.ps1` script to identify stale devices and then the `Remove-StaleAzureADDevices.ps1` script to remove them.

For detailed instructions on setting up and using the scripts, please refer to the individual script files and the instructions provided within.

## License

This project is licensed under the [MIT License](LICENSE).
