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
            $ReplicationPartnerMetadata = Get-ADReplicationPartnerMetadata -Target $DC.Hostname

            foreach ($ReplicationFlow in $ReplicationPartnerMetadata) 
            {
                [PSCustomObject]@{
                    DC              = $DC.Name
                    Partners        = ($ReplicationFlow.Partner -replace "CN=" -split ",")[1]
                    LastReplication = $ReplicationFlow.LastReplicationSuccess
                } 
            }
            
        }
    
        end {
        
        }
    }
}