function Get-ADUserGroupMembership
{
    [cmdletbinding()]
    param(
        [string]$SamAccountNAme, 
        [string]$Server = $env:USERDNSDOMAIN,
        [int]$Level = 0,
        [ValidateSet("Group", "User")][string]$ObjectType = "User"
    )

    $Level = 0
    $indent = "└" + ("-" * $Level)


    if ($ObjectType -eq "User" -and $Level -eq 0)
    {
        $Object = Get-ADUser -Identity $SamAccountNAme -Properties MemberOf -Server $Server
 
    }
    elseif ($ObjectType -eq "Group")
    {
        if ($Level -gt 0)
        {
            Write-Host "$indent $($d.SamAccountName)"
        }

        $Object = Get-ADGroup -Identity $SamAccountNAme -Properties MemberOf -Server $Server
    }
 
        $Object.MemberOf | Sort-Object | ForEach-Object {
            # prevent a loop if the group is a member of itself
            if ( $_ -ne $Object.DistinguishedName )
            {
                Get-ADUserGroupMembership -SamAccountNAme $_  -Level($Level + 1) -ObjectType Group
            }
        }
}
    

