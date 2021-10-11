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
        $Server = $env:USERDNSDOMAIN
    )

    #Clear-Host
    
    [psobject]$DCs = Get-ADDomainController -Server $Server -Filter * | Select-Object Name, Hostname,@{Name="Identity";expression={$Identity}}
    $ComputerPattern = $Identity + "$"

    $StartTime = [DateTime]::Now
    $Output = [System.Collections.ArrayList]::new()
    
    Write-Host "[+] Search [$($Identity.ToUpper())] on $($DCs.Count) domain controllers ... "

    
    $Output = $DCs | ForEach-Object -Parallel {


        #$Search = 
        
        $Search = Get-ADObject -Filter  "SamAccountName -eq '$($_.Identity)' -OR SamAccountName -eq '$($_.Identity+"$")'" -Server $_.Hostname -Properties modified -ErrorAction SilentlyContinue
        #-Server $_.Hostname -Properties modified -ErrorAction SilentlyContinue
        
        [PSCustomObject]@{
            Name = $_.Name
            Found = if ($Search) {$true} else {$false}
            LastModified = $Search.modified
        } 
    } 
    

    Write-Output ($Output | Sort-Object LastModified)

}
    