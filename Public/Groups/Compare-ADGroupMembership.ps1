function Compare-ADGroupMembership
{
<#
    .SYNOPSIS
    Compare Group Membership for multiple Users

    .DESCRIPTION
    Compare Group Membership for multiple Users

    .EXAMPLE
    PS> Compare-ADGroupMembership user1,user2

    UserName Status GroupName                             %OfUsersInGroup
    -------- ------ ---------                             ---------------
    user1   NotIn  Group1                                 50
    user1   NotIn  Group2                                 50
    user2   NotIn  Group3                                 50
    user2   NotIn  Group4                                 50
#>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [string[]]$UserName,
        [switch]$IncludeEqual,
        [string]$Server = $env:USERDNSDOMAIN
    )
    
    BEGIN { }
    
    PROCESS
    {
        foreach ($name in $UserName)
        {
            try
            {
                Write-Verbose -Message "Attempting to query Active Directory of user: '$name'."
                [array]$users += Get-ADUser -Identity $name -Properties MemberOf -Server $Server -ErrorAction Stop
            }
            catch
            {
                Write-Warning -Message "An error occured. Error Details: $_.Exception.Message"
            }
        }
    }
    
    END
    {
        Write-Verbose -Message "The `$users variable currently contains $($users.Count) items."
    
        $commongroups = ($groups = $users | Select-Object -ExpandProperty MemberOf | Group-Object) | Where-Object Count -ge ($users.Count / 2) | Select-Object -ExpandProperty Name
            
        Write-Verbose -Message "There are $($commongroups.Count) groups with 50% or more of the specified users in them."

        $Result = [System.Collections.ArrayList]::new()

        #Common groups
        If ($PSBoundParameters['IncludeEqual'])
        {
            $CommonMemberhip = foreach ($group in ($groups | Where-Object { $_.Count -eq $users.count })  ) 
            {
                [PSCustomObject]@{
                    UserName          = "ALL"
                    Status            = "In"
                    GroupName         = $Group.Name -replace '^CN=|,.*$'
                    '%OfUsersInGroup' = 100
                }
            }
        }
            
        $UsersMembership = foreach ($user in $users)
        {
            Write-Verbose -Message "Checking user: '$($user.SamAccountName)' for group differences."
    
            $differences = Compare-Object -ReferenceObject $commongroups -DifferenceObject $user.MemberOf
    
            foreach ($difference in $differences)
            {
                [PSCustomObject]@{
                    UserName          = $user.SamAccountName
                    Status            = switch ($difference.SideIndicator) { '<=' { 'NotIn'; break }'=>' { 'In'; break } }
                    GroupName         = $difference.InputObject -replace '^CN=|,.*$'
                    '%OfUsersInGroup' = ($groups | Where-Object name -eq $difference.InputObject).Count / $users.Count * 100 -as [int]
                }
            }
        }

        $Result.Add($CommonMemberhip) | Out-Null
        $Result.Add($UsersMembership) | Out-Null

        return $Result

    }
}