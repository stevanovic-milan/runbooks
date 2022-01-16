# Requires Automation Account System Managed Identity, Az.Accounts and Az.Resources PS modules
# <#
# .SYNOPSIS
#   Changes Wrong Tag Names of each resource within the given Resource Group.
# .DESCRIPTION
#   Updates all the wrongly assigned tag names withing the resource group.
#   Created to standardize Resource Tag Names, such as "env", "Env", "ENVIRONMENT" into one single value.
#   To replace multiple Tag Names in one go just add them as space separated values to $WrongTagNames parameter.
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
  [String] $CorrectTagName,
  [Parameter (Mandatory= $true)]
  [String] $TagValue,
  [Parameter (Mandatory= $true)]
  [String] $WrongTagNames
  
)
# Import the modules
Import-module 'az.accounts'
Import-module 'az.resources'

# Connect to Azure with the System Managed Identity
Connect-AzAccount -Identity

$WrongTagNamesArray = $WrongTagNames.Split(" ")
$NewTag = @{$CorrectTagName=$TagValue}

# Checking each Wrong Tag Name
foreach ($TagName in $WrongTagNamesArray) {

    $WrongTag = @{$TagName=$TagValue}
    $Resources = @()
    Write-Output "Selected Resource Group: $($ResourceGroupName)"
    $Resources = Get-AzResource -ResourceGroupName $ResourceGroupName  -Tag $WrongTag

    foreach ($Resource in $Resources) {

        $ResourceTags = ""
        
        Write-Host "Processing resource $($Resource.Name) ..."
        
        $ResourceTags = Get-AzTag -ResourceId $Resource.ResourceId
        
        $Value = $ResourceTags.Properties.TagsProperty[$TagName]

        # Create new tag with original value
        Update-AzTag -ResourceId $Resource.ResourceId -Tag $NewTag -Operation Merge
        
        # Delete the old tag with incorrect name
        Update-AzTag -ResourceId $Resource.ResourceId -Tag $WrongTag -Operation Delete
    }

}
