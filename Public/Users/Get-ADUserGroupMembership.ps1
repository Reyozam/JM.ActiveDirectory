function Get-ADUserGroupMembership
{
<#
    .SYNOPSIS
    Get AD User Group Membership list

    .DESCRIPTION
    Get AD User Group Membership list

    .EXAMPLE
    PS C:\> Get-ADUserGroupMembership "UserSamAccountName"
#>
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [Alias("ID", "Users", "Name")]
        [string[]]$User
    )
    Begin
    {
        Try { Import-Module ActiveDirectory -ErrorAction Stop }
        Catch { Write-Host "Unable to load Active Directory module, is RSAT installed?"; Break }
    }

    Process
    {
        ForEach ($U in $User)
        {
            $UN = Get-ADUser $U -Properties MemberOf
            $Groups = ForEach ($Group in ($UN.MemberOf))
            {
                (Get-ADGroup $Group)
            }
            $Groups = $Groups | Sort-Object
            ForEach ($Group in $Groups)
            {        
                [PSCustomObject]@{
                    Group             = $Group.Name
                    GroupCategory     = $Group.GroupCategory
                    GroupScope        = $Group.GroupScope
                }  
            }
        }
    }
}
