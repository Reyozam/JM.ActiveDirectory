Function Get-ADObsoleteComputer
{
<#
    .SYNOPSIS
    Finds the Obsolete computer objects.
    .DESCRIPTION
    Function is querying the Active Directory and searching for all computer objects that did not update their passwords for period of time.
    .PARAMETER PasswordOlderThan

    .EXAMPLE
    PS C:\> Find-ObsoleteComputer -PasswordOlderThan 90
    ComputerName    PasswordLastSet
    ------------    ---------------
    DESKTOP-ROOH24P 21/2/2018 13:35:04
#>
    [CmdletBinding()]
    param (
        # Password age in days.
        [Parameter(Mandatory = $false)]
        [int16]$PasswordOlderThan = 30,
        [Parameter(Mandatory = $false)]
        [string]$Server = $env:USERDNSDOMAIN
    )
    process
    {
        $PasswordDate = (Get-Date).AddDays(-$PasswordOlderThan).ToFileTime()
        $Computerlist = (Get-ADComputer -filter { Enabled -eq $true } -Properties LastLogon,PasswordLastSet -server $server | Where-Object { $_.PwdLastSet -le $PasswordDate })

        $Computerlist | Select-Object Name, PasswordLastSet

    }
}