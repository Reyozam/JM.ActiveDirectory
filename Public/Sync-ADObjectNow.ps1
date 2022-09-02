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
        [parameter()][string]$SourceDC = (Get-ADDomainController -Discover).hostname,
        [pscredential]$Credential
    )

    $Params = @{
        Server = $SourceDC
    }

    $SyncParams = @{
        source = $SourceDC
    }

    if ($Credential)
    {
        $Params["Credential"] = $Credential
        $SyncParams["Credential"] = $Credential
    }

    Write-Verbose "Looking for $identity on $SourceDC ..."

    try
    {
        $ADObject = Get-ADObject -Filter { SamAccountName -eq $Identity -OR Name -eq $Identity } -ErrorAction Stop @Params
    }
    catch
    {
        Write-Warning "$Identity not found on $SourceDC"
        break
    }

    Get-ADDomainController -filter * @Params | ForEach-Object { Sync-ADObject -object $ADObject.DistinguishedName @SyncParams -Destination $_.hostname -Verbose }

}
