function Get-ADSiteIPAttribution
{
    param (
        
        [Parameter(Mandatory)]
        [IPAddress[]]
        $IP
    )

    $Site = nltest /DSADDRESSTOSITE:$IP /dsgetsite 2>$null
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
    
