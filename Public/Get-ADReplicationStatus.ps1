function Get-ADReplicationStatus
{
    [CmdletBinding()]
    param (
        $Domain = $env:USERDNSDOMAIN
    )
    
    begin
    {
        $DomainControllers = Get-ADDomainController -Filter *
    }
    
    process
    {
        
        foreach ($DC in $DomainControllers) 
        {
            $Replication = Get-ADReplicationPartnerMetadata -Target $DC -ErrorAction SilentlyContinue -ErrorVariable ProcessErrors
            if ($ProcessErrors)
            {
                foreach ($_ in $ProcessErrors)
                {
                    Write-Warning -Message "Error on server $($_.Exception.ServerName): $($_.Exception.Message)"
                }
            }
            foreach ($_ in $Replication)
            {
                $ServerPartner = (Resolve-DnsName -Name $_.PartnerAddress -Verbose:$false -ErrorAction SilentlyContinue)
                $ReplicationObject = [ordered] @{
                    Server                         = $_.Server
                    ServerPartner                  = $ServerPartner.NameHost
                    PartnerType                    = $_.PartnerType
                    LastReplicationAttempt         = $_.LastReplicationAttempt
                    LastReplicationResult          = $_.LastReplicationResult
                    LastReplicationSuccess         = $_.LastReplicationSuccess
                    ConsecutiveReplicationFailures = $_.ConsecutiveReplicationFailures
                }

                [PSCustomObject] $ReplicationObject
            }
        }
    }
    end
    {
        
    }
    
}
