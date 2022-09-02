function Get-ADReplicationStatus {
    <#
    .SYNOPSIS
    Extracted from EvoTec Blog
    https://evotec.xyz/active-directory-instant-replication-between-sites-with-powershell/
    .DESCRIPTION
    Get replication status for all Domain site connections
    .PARAMETER Extended
    Retrieves additional sync information
    .EXAMPLE
    Get-ReplicationStatus -Extended
    Get replication information, included extended details
    .LINK
    https://evotec.xyz/active-directory-instant-replication-between-sites-with-powershell/
    #>

    [CmdletBinding()]
    param(
        [string] $Server = $env:USERDNSDOMAIN,
        [switch] $Extended
    )

    $DomainInfo = Get-ADDomain $Server
    $FQDN = $DomainInfo.DNSRoot
    $PDC = $DomainInfo.PDCEmulator

    $Replication = Get-ADReplicationPartnerMetadata -Target $FQDN -Partition $((Get-ADDomain -server $Server).DistinguishedName) -EnumerationServer $PDC -Scope Domain  -ErrorAction SilentlyContinue -ErrorVariable ProcessErrors
    if ($ProcessErrors) {
        foreach ($_ in $ProcessErrors) {
            Write-Warning -Message "Get-ADReplicationPartnerMetaData - Error on server $($_.Exception.ServerName): $($_.Exception.Message)"
        }
    }
    foreach ($_ in $Replication) {
        $ServerPartner = (Resolve-DnsName -Name $_.PartnerAddress -Verbose:$false -ErrorAction SilentlyContinue)
        $ServerInitiating = (Resolve-DnsName -Name $_.Server -Verbose:$false -ErrorAction SilentlyContinue)
        $ReplicationObject = [ordered] @{
            PSTypeName        = "ADReplication"
            To                         = $_.Server
            From                  = $ServerPartner.NameHost
            LastReplicationAttempt         = $_.LastReplicationAttempt
            LastReplicationResult          = $_.LastReplicationResult
            LastReplicationSuccess         = $_.LastReplicationSuccess
            ConsecutiveReplicationFailures = $_.ConsecutiveReplicationFailures
            LastChangeUsn                  = $_.LastChangeUsn
            PartnerType                    = $_.PartnerType
            Partition                      = $_.Partition
            TwoWaySync                     = $_.TwoWaySync
            ScheduledSync                  = $_.ScheduledSync
            SyncOnStartup                  = $_.SyncOnStartup
            CompressChanges                = $_.CompressChanges
            DisableScheduledSync           = $_.DisableScheduledSync
            IgnoreChangeNotifications      = $_.IgnoreChangeNotifications
            IntersiteTransport             = $_.IntersiteTransport
            IntersiteTransportGuid         = $_.IntersiteTransportGuid
            IntersiteTransportType         = $_.IntersiteTransportType
            UsnFilter                      = $_.UsnFilter
            Writable                       = $_.Writable
        }
        if ($Extended) {
            $ReplicationObject.Partner = $_.Partner
            $ReplicationObject.PartnerAddress = $_.PartnerAddress
            $ReplicationObject.PartnerGuid = $_.PartnerGuid
            $ReplicationObject.PartnerInvocationId = $_.PartnerInvocationId
            $ReplicationObject.PartitionGuid = $_.PartitionGuid
        }
        [PSCustomObject]$ReplicationObject
    }
}

Update-TypeData -TypeName ADReplication -DefaultDisplayPropertySet From,To,LastReplicationAttempt,LastReplicationSuccess,ConsecutiveReplicationFailures -Force