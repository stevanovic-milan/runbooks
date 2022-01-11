#requires Automation Account System Managed Identity, Az.Accounts and Az.Automation PS modules
<#
.SYNOPSIS
  Prints out Azure Automation Account credential passwords.
.DESCRIPTION
  Prints out all of the Azure Automation Accounts credentials UserName : Password pairs when ResourceGroupName and AutomationAccountName parameters are given.
  In case the CredentialName parameter is provided, then it prints out only UserName : Password pair for a given credential name.
.NOTES
  Version:        1.0
  Author:         Milan Stevanovic
  Creation Date:  11.01.2022.
  Purpose/Change: Initial script development
#>

Param
(
  [Parameter (Mandatory= $false)]
  [String] $CredentialName,
  [Parameter (Mandatory= $false)]
  [String] $ResourceGroupName,
  [Parameter (Mandatory= $false)]
  [String] $AutomationAccountName
)
# Import the modules
Import-module 'az.accounts'
Import-module 'az.automation'

# Connect to Azure with the System Managed Identity
Connect-AzAccount -Identity

if ($CredentialName -eq "" -and ($ResourceGroup -and $AutomationAccount)) {
    try {
            $creds = Get-AzAutomationCredential -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName
        }
        catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error getting the list of credentials: " + $ErrorMessage)
            Break
        }  
    foreach ($cred in $creds) {
        try {
            $cred = Get-AutomationPSCredential -Name $cred.Name
        }
        catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error getting the credential: " + $ErrorMessage)
        }       
        Write-Output "$($cred.UserName) : $($cred.GetNetworkCredential().Password)"
    }
}   elseif ($CredentialName) {
        try {
            $cred = Get-AutomationPSCredential -Name $CredentialName
        }
        catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error getting the credential: " + $ErrorMessage)
            Break
        }
        Write-Output "$($cred.UserName) : $($cred.GetNetworkCredential().Password)"
    } else {
        Write-Error "To get the single credential please provide Credential parameter."
        Write-Error "To get all the credentials please provide both ResourceGroupName and AutomationAccountName parameters."
        }
