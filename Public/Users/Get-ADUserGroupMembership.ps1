#requires -version 5.1
#requires -module ActiveDirectory

<#
Get-ADMemberOf -identity user | Select-Object -property DistinguishedName
DistinguishedNAme
-----------------
CN=JEA Operators,OU=JEA_Operators,DC=Company,DC=Pri
CN=Foo,OU=Employees,DC=Company,DC=Pri
CN=Master Dev,OU=Dev,DC=Company,DC=Pri
CN=IT,OU=IT,DC=Company,DC=Pri
#>

Function Get-ADUerGroupMembership {
    [cmdletBinding()]
    [OutputType("Microsoft.ActiveDirectory.Management.ADGroup")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter a user's SAMAccountname or distinguishedname",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullorEmpty()]
        [string]$Identity
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.mycommand)"
        Function Get-GroupMemberOf {
            Param([string]$identity)
            $group = Get-ADGroup -Identity $Identity -Properties MemberOf
            
            $group

            if ($group.MemberOf) {
                $group | Select-Object -expandProperty MemberOf |
                ForEach-Object {
                    Get-GroupMemberOf -identity $_
                }
        }
    } #end function
} #close Begin

Process {
    Write-Verbose "Getting all groups for user $identity"
    Get-ADUser -identity $identity -Properties memberof |
        Select-Object -ExpandProperty MemberOf |
        ForEach-Object {
            Write-Verbose "Getting group member of $_"
            Get-GroupMemberOf -identity $_
        } #foreach
} #close process

End {
    Write-Verbose "Ending $($myinvocation.mycommand)"
}
} 
    

