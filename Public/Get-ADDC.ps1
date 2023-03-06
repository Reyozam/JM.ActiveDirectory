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

    $Properties = @(
        @{Name = 'Name'; Expression = {
                if ($host.name -eq 'ConsoleHost')
                {
                    if ($_.OperationMasterRoles -contains 'PDCEmulator') { "$([char]0x1b)[93m$($_.Name)$([char]0x1b)[0m" }
                    else { $_.Name }
                }
                else
                {
                    $_.Name
                }
            }
        },
        'Site',
        'IPv4Address',
        'OperatingSystem'
    )

    $DCs = (Get-ADDomainController -Filter * -Server $Server | Select-Object $Properties)

    return $DCs

}



