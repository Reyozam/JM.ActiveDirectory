
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

    $ExclusionOU = "CN=Builtin,DC=gsy,DC=ad,DC=gaselys,DC=com|CN=Users,DC=gsy,DC=ad,DC=gaselys,DC=com"

    Try {
        If($SearchScope)
        {
          Write-Verbose "Lookup empty groups under $SearchScope ..."
          Get-ADGroup -Filter { Members -notlike "*" } -SearchBase $SearchScope -Server $Server -Properties grouptype | Where-Object {$_.grouptype -ne -2147483643 -and $_.DistinguishedName -notmatch $ExclusionOU  } | Select-Object Name, GroupCategory, DistinguishedName
        }
        Else
        {
          Write-Verbose "Lookup empty groups on all $Server domain ..."
          Get-ADGroup -Filter { Members -notlike "*" } -Server $Server -Properties grouptype | Where-Object { $_.grouptype -ne -2147483643 -and $_.DistinguishedName -notmatch $ExclusionOU }  | Select-Object Name, GroupCategory, DistinguishedName
        }
      }

      Catch {
        Write-Error "$($_.Exception.Message)"
        Break
      }

}