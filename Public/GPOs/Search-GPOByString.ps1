Function Search-GPOForString
{
<#
    .SYNOPSIS
    Searches group policy objects for specific string.
    .DESCRIPTION
    Searches group policy objects for specific string.
    .PARAMETER String
    String that you are looking for.
    .EXAMPLE
    PS C:\> Search-GPOForString -String "certificate"
    GPO Name                      GPO ID                              
    --------                      ------                              
    AutoEnrollment - Certificates 1d20f399-7aeb-4492-954a-e3bff2944cb1
    Default Domain Policy         31b2f340-016d-11d2-945f-00c04fb984f9
    BitLocker                     6c005315-ce5d-471c-9eb4-00b18049379b
    SmartCard Cryptography        77a20bbc-2259-464b-8a97-186ea1453ed7
#>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true,Position = 0)][ValidateNotNullOrEmpty()][string]$String,
        [Parameter(Mandatory = $false,Position = 1)][ValidateNotNullOrEmpty()][string]$Domain = $env:USERDNSDOMAIN
    )
    begin
    {

    }
    process
    {
        $AllGPOObjects = (Get-GPO -All -Domain $Domain)

        $Result = foreach ($GPO in $AllGPOObjects)
        {
            Write-Verbose -Message "Searching for specific string at group policy object : $($GPO.Name)"
            $Report = (Get-GPOReport -Guid $($Gpo.Id) -ReportType Xml)
            if ($Report -match $String)
            {
                $TempObject = [PSCustomObject]@{
                    'GPO Name' = $($Gpo.DisplayName)
                    'GPO ID'   = $($Gpo.Id)
                }
                
            }
        }
        $Result
    }
}