Function Get-ADUserGroupMembership
{
    [cmdletBinding()]
    [OutputType("Microsoft.ActiveDirectory.Management.ADGroup")]
    Param(
        [Parameter(Mandatory, HelpMessage = "Enter a user's SAMAccountname or distinguishedname", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [string]$Identity,

        [Parameter()]
        [string]$Server = $env:USERDNSDOMAIN

    )

    Begin
    {
        Write-Verbose "Starting $($myinvocation.mycommand)"
        Function Get-GroupMemberOf
        {
            Param([string]$identity, [string]$Server)
            $group = Get-ADGroup -Identity $Identity -Server $Server -Properties MemberOf
            
            $group

            if ($group.MemberOf)
            {
                $group | Select-Object -ExpandProperty MemberOf |
                    ForEach-Object {
                        Get-GroupMemberOf -identity $_ -Server $Server
                    }
            }
        } #end function
    } #close Begin

    Process
    {
        Write-Verbose "Getting all groups for user $identity"
        Get-ADUser -Identity $identity -Properties memberof -Server $Server |
            Select-Object -ExpandProperty MemberOf |
            ForEach-Object {
                Write-Verbose "Getting group member of $_"
                Get-GroupMemberOf -identity $_ -Server $Server
            } #foreach
    } #close process

    End
    {
        Write-Verbose "Ending $($myinvocation.mycommand)"
    }
} 
    

