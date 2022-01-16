# Requires Automation Account System Managed Identity, Az.Accounts and Az.Resources PS modules
# <#
# .SYNOPSIS
#   Changes Wrong Tag Vaulues of each resource within the given resource group.
# .DESCRIPTION
#   Updates all the wrongly assigned tag values withing the resource group.
#   Created to standardize Resource Tag Values, such as "PRD", "Prod", "Production" into one single value.
#   To replace multiple Tag Values in one go just add them as space separated values to $WrongTagValues parameter.
# .NOTES
#   Version:        1.0
#   Author:         Milan Stevanovic
#   Creation Date:  16.01.2022.
#   Purpose/Change: Initial script development
# #>
Param
(
  [Parameter (Mandatory= $true)]
  [String] $ResourceGroupName,
  [Parameter (Mandatory= $true)]
  [String] $TagName,
  [Parameter (Mandatory= $true)]
  [String] $WrongTagValues,
  [Parameter (Mandatory= $true)]
  [String] $CorrectTagValue
)
# Import the modules
Import-module 'az.accounts'
Import-module 'az.resources'

# Connect to Azure with the System Managed Identity
Connect-AzAccount -Identity

$WrongTagValuesArray = $WrongTagValues.Split(" ")
$NewTag = @{$TagName=$CorrectTagValue}
Write-Output "New Tag : $($NewTag)"

#Checking each Wrong Tag Value
foreach ($TagValue in $WrongTagValuesArray) {

    $WrongTag = @{$TagName=$TagValue}
    $Resources = @()
    Write-Output "Selected Resource Group: $($ResourceGroupName)"
    $Resources = Get-AzResource -ResourceGroupName $ResourceGroupName  -Tag $WrongTag

    foreach ($Resource in $Resources) {
            Write-Output "Processing resource $($Resource.Name) ..."
            Update-AzTag -ResourceId $Resource.ResourceId -Tag $NewTag -Operation Merge
    }

}
