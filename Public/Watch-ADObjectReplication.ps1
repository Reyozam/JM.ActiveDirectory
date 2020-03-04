function Watch-ADObjectReplication
{
    <#
.SYNOPSIS
    Search object on all controller and wait for replication is completed. Return information on replication time.
.DESCRIPTION
    Search object on all controller and wait for replication is completed. Return information on replication time.
.EXAMPLE
    PS C:\> Watch-ADObjectReplication -Identity user01
    
    Object                                    Server            ReplicatedOn
    ------                                    ------            ------------
    CN=MCLANE John,OU=Users,DC=contoso,DC=com DC01.contoso.com  11/07/2019 16:14:43
    CN=MCLANE John,OU=Users,DC=contoso,DC=com DC02.contoso.com  11/07/2019 16:14:49
    CN=MCLANE John,OU=Users,DC=contoso,DC=com DC03.contoso.com  11/07/2019 16:16:54
    CN=MCLANE John,OU=Users,DC=contoso,DC=com DC04.contoso.com  11/07/2019 16:18:10
#>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Identity,

        [Parameter()]
        [string]
        $Domain = $env:USERDNSDOMAIN
    )

    #Clear-Host
    
    [psobject]$DCs = Get-ADDomainController -Server $Domain -Filter * | Select-Object Name, Hostname
    $ComputerPattern = $Identity + "$"

    $StartTime = [DateTime]::Now
    $Output = [System.Collections.ArrayList]::new()
    
    Write-Host "[+] Search [$($Identity.ToUpper())] on $($DCs.Count) domain controllers ... "

    do 
    {
        foreach ($DC in $DCs) 
        {
            try
            {
                $Search = Get-ADObject -Filter {SamAccountName -like $Identity -OR SamAccountName -like $ComputerPattern} -Server $DC.Hostname -ErrorAction SilentlyContinue
            }
            catch
            {
                Write-Host "`t[!] " -ForegroundColor Yellow -NoNewLine
                Write-Host "Unable to reach $($Dc.Hostname)" -ForegroundColor Yellow
                
                $DCs = $DCS | Where-Object { $_.Name -ne $DC.Name }
                continue
            }

            if ($Search)
            {
                $Metadata = Get-ADReplicationAttributeMetadata -Object $Search -Server $Dc.Hostname | Where-Object {$_.AttributeName -eq "cn"}

                Write-Host "`t[+] " -ForegroundColor Green -NoNewLine
                Write-Host "Object found on $($DC.Name) - First Replicated on $($MetaData.LastOriginatingChangeTime)" -ForegroundColor Green

                $DCs = $DCS | Where-Object { $_.Name -ne $DC.Name }

                $Output.Add([PSCustomObject]@{
                        Object        = $Metadata.Object
                        Server        = $Metadata.Server
                        ReplicatedOn  = $Metadata.LastOriginatingChangeTime
                    }) | Out-Null
            }
            else
            {

            }
        }
    
        

    } until ($DCs.Count -eq 0)

    Write-Output ($Output | Sort-Object ReplicatedOn)

}
    