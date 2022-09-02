function Test-ADReplication
{
    param (
        [string]$OriginServer,
        [string]$Path,
        [pscredential]$Credential
    )

    $NewParam = @{
        Name = "test_replication_object"
        Enabled = $False
        Server = $OriginServer
    }

    if ($Path) {$NewParam["Path"] = $Path}
    else {$NewParam["Path"] = (Get-ADDomain -Server $OriginServer).UsersContainer }

    if ($Credential) { $NewParam["Credential"] = $Credential }


    New-ADUser @NewParam

}


