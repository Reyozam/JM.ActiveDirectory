function Get-ADReplicationStatus
{
<# 
    .SYNOPSIS 
        Return Replication Information
      
    .DESCRIPTION 
        Return Replication Status, Success & Errors TimeStamp
      
    .EXAMPLE 
        Get-ADReplicationStatus

        Server       ServerPartner PartnerType LastReplicationAttempt LastReplicationResult LastReplicationSuccess ConsecutiveReplicationFailures
        ------       ------------- ----------- ---------------------- --------------------- ---------------------- ------------------------------
        DC03          DC01          Inbound     04/03/2020 17:16:06                        0 04/03/2020 17:16:06                                 0
        DC03          DC02          Inbound     04/03/2020 17:16:06                        0 04/03/2020 17:16:06                                 0
        DC04          DC01          Inbound     04/03/2020 17:29:17                        0 04/03/2020 17:29:17                                 0
        DC04          DC02          Inbound     04/03/2020 17:29:17                        0 04/03/2020 17:29:17                                 0
        DC04          DC03          Inbound     04/03/2020 17:29:17                        0 04/03/2020 17:29:17                                 0
#> 
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
                    Server                         = ($_.Server -split "\.")[0].ToUpper()
                    ServerPartner                  = ($ServerPartner.NameHost -split "\.")[0].ToUpper()
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
