
Function Get-ADEmptyGroup
{
<#
    .SYNOPSIS
        Retrieves all groups without members in a domain or container.
    .DESCRIPTION
        Retrieves all groups without members in a domain or container.
    .PARAMETER SearchRoot
        OU where search for emptygroup
    .EXAMPLE
    Get-ADEmptyGroup -SearchRoot "CN=Servers,DC=contoso,DC=com"
#>

    [CmdletBinding()]
    param(
        [string]$SearchRoot
    )

    Begin
    {

        $c = 0
        $filter = "(&(objectClass=group)(!member=*))"

        $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://RootDSE")
        $searcher = New-Object System.DirectoryServices.DirectorySearcher $filter
    }

    Process
    {
        if (!($SearchRoot))
        { $SearchRoot = $root.defaultNamingContext }
        elseif (!($SearchRoot) -or ![ADSI]::Exists("LDAP://$SearchRoot"))
        { Write-Error "$($MyInvocation.MyCommand.Name):: SearchRoot value: '$SearchRoot' is invalid, please check value"; return }
        $searcher.SearchRoot = "LDAP://$SearchRoot"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Searching in: $($searcher.SearchRoot)"

        $searcher.SearchScope = "SubTree"
        $searcher.SizeLimit = $SizeLimit
        $searcher.PageSize = $PageSize
        try
        {
            $searcher.FindAll() | `
                Foreach-Object `
            {
                $c++
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Found: $($_.Properties.cn)"
                $_.GetDirectoryEntry()
            }
        }
        catch
        {
            { return $false }
        }
    }

    End
    {

    }
}