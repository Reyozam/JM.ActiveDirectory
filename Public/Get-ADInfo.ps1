function Get-ADInfo {

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
        [Parameter()]
        [string]
        $Domain = $env:USERDNSDOMAIN
    )

    Import-Module ActiveDirectory

    Get-ADDomain -Server $Domain |
    Select-Object Name, Forest, ChildDomains, DistinguishedName, DNSRoot, DomainMode, ReplicaDirectoryServers, InfrastructureMaster, RIDMaster, PDCEmulator |
    Format-List

    Get-ADForest -Server $Domain |
    Select-Object DomainNamingMaster, SchemaMaster |
    Format-List

}