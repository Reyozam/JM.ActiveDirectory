function Get-ADSiteIPAttribution
{
<# 
    .SYNOPSIS 
        Return AD Site attribution by IP Address
    .DESCRIPTION 
        Return AD Site attribution by IP Address
    .EXAMPLE 
        Get-ADSiteIPAttribution 10.20.160.23

        ADSite  Subnet
        ------  ------
        00FR    10.0.0.0/8
#> 
    param (
        
        [Parameter(Mandatory)]
        [IPAddress[]]
        $IP,
        [Parameter()]
        [string]
        $Server = $env:USERDNSDOMAIN

    )

    $PDC = (Get-ADDomain -Server $Server).PDCEmulator

    $Site = nltest /DSADDRESSTOSITE:$IP /dsgetsite /SERVER:$PDC 2>$null
    if ($LASTEXITCODE -eq 0)
    {
        $Split = $Site[3] -split "\s+"

        if ($Split[1] -match [regex]"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") 
        {

            [PSCustomObject]@{
                ADSite = $Split[2]
                Subnet = $Split[3]
            }            
        }
    }
}
    
