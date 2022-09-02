function Get-ADDC
{
<#
    .SYNOPSIS
        This function will return domain controllers list & info.

    .DESCRIPTION
        This function will return domain controllers list & info.

    .EXAMPLE
        Get-ADDC

        Hostname                    Site     IPv4Address   OperationMasterRoles                           IsGlobalCatalog IsReadOnly
        --------                    ----     -----------   --------------------                           --------------- ----------
        DC01                        FR      10.22.231.69  {}                                                        True      False
        DC02                        BEL     10.22.250.32  {}                                                        True      False
        DC03                        CRO     10.22.194.108 {}                                                        True      False
        DC04                        SING    10.22.165.48  {PDCEmulator, RIDMaster, InfrastructureMaster}            True      False
#>

    [CmdletBinding()]
    param (
        [Parameter()][string]$Server = $env:USERDNSDOMAIN
    )

    $DCs = (Get-ADDomainController -Filter * -Server $Server | Select-Object Name, Site, IPv4Address,OperatingSystem,OperationMasterRoles)

    return $DCs

}



