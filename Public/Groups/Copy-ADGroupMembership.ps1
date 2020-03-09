function Copy-ADGroupMembership
{
<#
    .SYNOPSIS
    Add target users on the same AD group than the source user

    .DESCRIPTION
    Add target users on the same AD group than the source user

    .EXAMPLE
    PS> Copy-ADGroupMembership -SourceUser user1 -TargetUsers user2,user3

#>
    [CmdletBinding()]
    param (
        [String]$SourceUser,
        [string[]]$TargetUsers
    )
    
    begin
    {
        $VerbosePreference = "Continue"
    }
    
    process
    {
        Get-ADUser -Identity $SourceUser -Properties memberof |
        Select-Object -ExpandProperty memberof |
        Add-ADGroupMember -Members $TargetUsers -Verbose
    }
    
    end
    {
        
    }
}