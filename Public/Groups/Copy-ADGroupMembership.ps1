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
        [string[]]$TargetUsers,
        [string]$Server = $env:USERDNSDOMAIN,
        [PSCredential]$Credential
    )

    begin
    {
        $VerbosePreference = "Continue"
        $ADParams = @{
            Server = $Server
        }

        if ($Credential) { $ADParams["Credential"] = $Credential }
    }

    process
    {
        Get-ADUser -Identity $SourceUser -Properties memberof @ADParams |
        Select-Object -ExpandProperty memberof |
        Add-ADGroupMember -Members $TargetUsers @ADParams -Verbose
    }

    end
    {

    }
}