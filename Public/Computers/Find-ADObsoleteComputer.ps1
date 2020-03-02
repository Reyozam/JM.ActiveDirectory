Function Find-ObsoleteComputer
{
    <#
.SYNOPSIS
Finds the Obsolete computer objects.
.DESCRIPTION
Function is querying the Active Directory and searching for all computer objects that did not update their passwords for period of time specified by the user input.
.PARAMETER PasswordOlderThan
Represents a number of days which will be used for a query.
.EXAMPLE
PS C:\> Find-ObsoleteComputer -PasswordOlderThan 90
ComputerName    PasswordLastSet     
------------    ---------------     
DESKTOP-ROOH24P 6/18/2018 1:35:04 PM
.INPUTS
System.Reflection.TypeInfo
.OUTPUTS
PSCustomObject
#>
    [CmdletBinding()]
    param (
        # Password age in days.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int16]$PasswordOlderThan
    )
    process
    {
        $PasswordDate = (Get-Date).AddDays(-$PasswordOlderThan).ToFileTime()
        $Computerlist = (Get-ADComputer -filter { Enabled -eq $true } -Properties * | Where-Object { $_.PwdLastSet -le $PasswordDate })

        $Computerlist | Select-Object Name,PasswordLastSet

    }
}