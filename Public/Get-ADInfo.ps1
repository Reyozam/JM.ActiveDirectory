function Get-ADInfo
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
        [Parameter()]
        [string]
        $Domain = $env:USERDNSDOMAIN
    )

    [pscustomobject]$Object1 = Get-ADDomain -Server $Domain |
    Select-Object Name, Forest, ChildDomains, DistinguishedName, DNSRoot, DomainMode, ReplicaDirectoryServers, InfrastructureMaster, RIDMaster, PDCEmulator

    [pscustomobject]$Object2 = Get-ADForest -Server $Domain | Select-Object DomainNamingMaster, SchemaMaster 

    $arguments = [Pscustomobject]@()

    foreach ( $Property in $Object1.psobject.Properties)
    {
        $arguments += @{$Property.Name = $Property.value }   
    }
    
    foreach ( $Property in $Object2.psobject.Properties)
    {
        $arguments += @{ $Property.Name = $Property.value }  
    }

    $MergeObject = [Pscustomobject]$arguments

    return $MergeObject
}


 



