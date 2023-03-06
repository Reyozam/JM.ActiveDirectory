function Test-ADReplication
{
    param (
        [string]$OriginServer,
        # Specifies the user account credentials to use when performing this task.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )


    try
    {
        Write-Verbose "Look for Domain Controller: $OriginServer" -Verbose
        $OriginDCObject = Get-ADDomainController -Server $OriginServer
        Write-Verbose "Domain controller: $OriginServer found !" -Verbose
        Write-Verbose "`tDomain : $($OriginDCObject.Domain)" -Verbose
        Write-Verbose "`tForest : $($OriginDCObject.Forest)" -Verbose

        Write-Verbose 'Look for other domain controllers' -Verbose

        $OtherDCs = (Get-ADDomainController -Filter * -Server $OriginDCObject.Domain | Where-Object { $_.Name -ne $OriginDCObject.Name })

        $ReportTable = $OtherDCs | ForEach-Object {
            Write-Verbose "`t$($_)" -Verbose

            [PSCustomObject]@{
                Hostname        = $_.Hostname
                Name            = $_.Name
                Replicated      = $False
                ReplicationTime = $null
            }
        }

        #New ADUser Params
        $NewParam = @{
            Name        = 'testreplication'
            Enabled     = $False
            Server      = $OriginDCObject.HostName
            Path        = (Get-ADDomain -Server $OriginServer).UsersContainer
            ErrorAction = 'Stop'
        }
        if ($Credential) { $NewParam['Credential'] = $Credential }

        Write-Verbose 'Creating Test User Object ' -Verbose
        $TestUserObject = New-ADUser @NewParam -PassThru

        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

        Write-Verbose 'Wait for replication ...' -Verbose
        do
        {

            foreach ($DC in ($ReportTable | Where-Object { $_.Replicated -eq $False }))
            {
                try
                {
                    $null = $TestUserObject | Get-ADUser -Server $DC.Hostname -ErrorAction Stop
                        ($ReportTable | Where-Object { $_.Hostname -eq $DC.Hostname }).Replicated = $true
                        ($ReportTable | Where-Object { $_.Hostname -eq $DC.Hostname }).ReplicationTime = $StopWatch.Elapsed

                    $Found = ($ReportTable | Where-Object { $_.Replicated -eq $true })
                    Write-Verbose "[$($Found.Count) / $($ReportTable.Count)] Object found on $($DC.Name) in $('{0:d2} hours {1:d2} minutes {2:D2} seconds' -f $StopWatch.Elapsed.Hours,$StopWatch.Elapsed.Minutes,$StopWatch.Elapsed.Seconds)" -Verbose
                }
                catch
                {}
            }


        }
        until ( $Found.count -eq $ReportTable.Count )

        $StopWatch.Stop()
        Write-Verbose "Object Replicated on all controllers in $('{0:d2} hours {1:d2} minutes {2:D2} seconds' -f $StopWatch.Elapsed.Hours,$StopWatch.Elapsed.Minutes,$StopWatch.Elapsed.Seconds)" -Verbose
        Write-Verbose "Remove Test Object from $($OriginDCObject.HostName)" -Verbose
        $TestUserObject | Remove-ADUser -Credential $Credential -Confirm:$false -Server $OriginDCObject.HostName

        $ReportTable | Select-Object Name, Replicated, ReplicationTime | Sort-Object TimeSpan
    }
    catch
    {
        $_.Exception.Message
    }








}


