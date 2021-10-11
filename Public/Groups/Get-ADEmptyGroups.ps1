
function Get-ADEmptyGroups
{
<#
    .SYNOPSIS
        Retrieves all groups without members in a domain or container.
    .DESCRIPTION
        Retrieves all groups without members in a domain or container.
    .PARAMETER Server
        TargetDomain
    .EXAMPLE
    Get-ADEmptyGroup -Server contoso.com
#>

    [CmdletBinding()]
    param(
        [string]$Server = $env:USERDNSDOMAIN,
        [string]$SearchScope
    )

         
    Try {
        If($SearchScope) 
        {
          Write-Verbose "Lookup empty groups under $SearchScope ..."
          Get-ADGroup -Filter { Members -notlike "*" } -SearchBase $SearchScope -Server $Server | Select-Object Name, GroupCategory, DistinguishedName
        } 
        Else 
        {
          Write-Verbose "Lookup empty groups on all $Server domain ..."
          Get-ADGroup -Filter { Members -notlike "*" } -Server $Server | Select-Object Name, GroupCategory, DistinguishedName
        }
      }
  
      Catch {
        Write-Error "$($_.Exception.Message)"
        Break
      }

}