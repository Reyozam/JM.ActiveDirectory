function Copy-ADUserGroupMembership {
    [CmdletBinding()]
    param (
        [String]$SourceUser,
        [string[]]$TargetUsers
    )
    
    begin {
        $VerbosePreference="Continue"
    }
    
    process {
        Get-ADUser -Identity $SourceUser -Properties memberof |
        Select-Object -ExpandProperty memberof |
        Add-ADGroupMember -Members $TargetUsers -Verbose
    }
    
    end {
        
    }
}