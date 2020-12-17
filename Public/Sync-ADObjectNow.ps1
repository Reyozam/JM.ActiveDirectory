function Sync-ADObjectNow
{
    <#
    .SYNOPSIS
    Start replication of one AD object on all controllers
    .DESCRIPTION
    Start replication of one AD object on all controllers
    .EXAMPLE
    Sync-ADObjectNow user01
    .EXAMPLE
    Sync-ADObjectNow computer01
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory)][string]$Identity,
        [parameter()][string]$SourceDC = (Get-ADDomainController -Discover).hostname
    )
    
    Write-Verbose "Looking for $identity on $SourceDC ..."

    try 
    {
        $ADObject = Get-ADObject -Filter { SamAccountName -eq $Identity -OR Name -eq $Identity } -ErrorAction Stop -Server $SourceDC
    }
    catch 
    {
        Write-Warning "$Identity not found on $SourceDC"
        break
    }
    Get-ADDomainController -filter * | ForEach-Object { Sync-ADObject -object $ADObject.DistinguishedName -source $SourceDC -destination $_.hostname -Verbose }

}
