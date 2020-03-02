Function Start-ADReplication
{
    <#
.SYNOPSIS
Invokes replication against domain controller.
.DESCRIPTION
Invokes replication on specific Domain Controller, or all Domain Controllers found in the domain.
.PARAMETER All
Parameter to search and invoke replication against all Domain Controllers.
.PARAMETER DomainController
Parameter to search and invoke replicaiton against specific Domain Controller.
.EXAMPLE
Invoke-ADReplication -All
.EXAMPLE
Invoke-ADReplication -DomainController AD-DC01
#>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'DomainController',
            Position = 0)]
        [string]$DomainController
    )
    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'All')
        {
            $DomainControllers = (Get-ADDomainController -filter *).name
            $LastRepTime = (Get-ADReplicationUpToDatenessVectorTable -Target $DomainControllers[0]).LastReplicationSuccess[0]
            Write-Output "Last replication time was at - $LastRepTime"
            foreach ($DC in $DomainControllers)
            {
                Test-QuickConnect -Name $DC
                try
                {
                    Write-Output "Invoking replication against $DC"
                    [void](Invoke-Command -ComputerName $DC -ScriptBlock {
                            cmd.exe /c repadmin /syncall /A /d /e /P
                        } -InDisconnectedSession -ErrorAction Stop)
                }
                catch
                {
                    Write-Error -Exception $PSItem.Exception -Message $PSItem.Exception.Message
                    Break
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'DomainController')
        {
            
            $DomainController = (Get-ADDomainController -filter * | Where-Object { $_.Name -eq $DomainController }).Name

            if (!$DomainController)
            {
                Write-Warning "Cannot an find Domain Controller named $($DomainController)"
                break
            }
            
            if (!(Test-Connection $DomainController -Count 1 -Quiet ))
            {
                Write-Warning "$($DomainController) is not reacheable"
                break
            }

            $LastRepTime = (Get-ADReplicationUpToDatenessVectorTable -Target $DomainController).LastReplicationSuccess[0]
            Write-Output "Last replication time was at - $LastRepTime"
            try
            {
                Write-Output "Invoking replication against $DomainController"
                [void](Invoke-Command -ComputerName $DomainController -ScriptBlock {
                        cmd.exe /c repadmin /syncall /A /d /e /P
                    } -InDisconnectedSession -ErrorAction Stop)
            }
            catch
            {
                Write-Error $_.Exception
            }
        }    
    }
}