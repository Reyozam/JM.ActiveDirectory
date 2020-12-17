
Function Get-ADEmptyGroup
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
        [string]$Server = $env:USERDNSDOMAIN
    )

        return Get-ADGroup -LDAPFilter "(!(member=*))" -Server $Server

}