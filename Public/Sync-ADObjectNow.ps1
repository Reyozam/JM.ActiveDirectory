function Sync-ADObjectNow
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory)][string]$Identity,
        [parameter()][string]$SourceDC = (Get-ADDomainController -Discover).Name,
        [string]$Domain = $env:USERDNSDOMAIN
    )
    
    Write-Verbose "Looking for $identity on $SourceDC ..."

    try 
    {
       $ADObject = Get-ADObject -Filter {SamAccountName -eq $Identity -OR DistinguishedName -eq $Identity} -ErrorAction Stop -Server $SourceDC
    }
    catch 
    {
        Write-Warning "$Identity not found on $SourceDC"
        break
    }
    
    Get-ADDomainController -filter * | ForEach-Object {Sync-ADObject -object $ADObject.DistinguishedName -source $SourceDC -destination $_.hostname -Verbose}

}
