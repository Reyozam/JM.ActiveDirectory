function Get-ADDC
{

    <#
    .Description
    This function will return domain info. Requires the Active Directory Module.
    .NOTES
    Requires the Active Directory Module
    .Link
    Get-PCInfo
    #>

    [CmdletBinding()]
    param (
        [Parameter()][string]$Domain = $env:USERDNSDOMAIN,

        [Parameter()][switch]$AsObject
    )

    $DCs = (Get-ADDomainController -Filter * -Server $Domain | Select-Object Hostname,Site,IPv4Address,OperatingSystem,IsGlobalCatalog,IsReadOnly )

    if ($AsObject)
    {
        return $DCs
    }
    else
    {
        $DCs | Format-table -AutoSize
    }

}



