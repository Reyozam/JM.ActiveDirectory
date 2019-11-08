function Get-ADFSMORoles 
{
    param (
        [string]$Domain = $env:USERDNSDOMAIN
    )

    $DCs = Get-ADDomainController -Filter * -Server $Domain | Select Name,OperatingSystem,IPv4Address

    $DomainRoles = Get-ADDomain -Server $Domain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator
    $ForestRoles = Get-ADForest -Server $Domain | Select-Object DomainNamingMaster, SchemaMaster

    $FSMO = @(
        [PSCustomObject]@{Role = "DomainNamingMaster" ; DC = $ForestRoles.DomainNamingMaster}
        [PSCustomObject]@{Role = "SchemaMaster" ; DC = $ForestRoles.SchemaMaster}
        [PSCustomObject]@{Role = "InfrastructureMaster" ; DC = $DomainRoles.InfrastructureMaster}
        [PSCustomObject]@{Role = "RIDMaster" ; DC = $DomainRoles.RIDMaster}
        [PSCustomObject]@{Role = "PDCEmulator" ; DC = $DomainRoles.PDCEmulator}
        
    )

    foreach ($Role in $FSMO)
    {
        $DC = $DCs | Where-Object {$_.Name -match ($Role.DC -split "\.")[0]}

        $Role | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $DC.OperatingSystem
        $Role | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $DC.IPv4Address
    }
    
    return $FSMO
}

