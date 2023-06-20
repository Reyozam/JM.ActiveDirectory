function Get-ADComputerCustom
{
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('Name')][string]$Identity,
        [Parameter(Mandatory = $false)][switch]$Detailed,
        [Parameter(Mandatory = $false)][string]$Server = $env:USERDNSDOMAIN,
        # Specifies the user account credentials to use when performing this task.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty

    )
    begin
    {
        $Properties = @(
            'Created',
            'Description'
            'CanonicalName',
            'LastLogonDate',
            'PasswordLastSet',
            'IPv4Address',
            'OperatingSystem'
        )

        $SelectProperties = @(
            'Name',
            'IPv4Address',
            'OperatingSystem'
            @{Name = 'Enabled'; Expression = {
                    if ($host.name -eq 'ConsoleHost')
                    {
                        if ($_.Enabled)
                        {
                            "$([char]0x1b)[32m$($_.Enabled)$([char]0x1b)[0m"
                        }
                        else
                        {
                            "$([char]0x1b)[91m$($_.Enabled)$([char]0x1b)[0m"
                        }
                    }
                    else
                    {
                        $_.Enabled
                    }
                }
            },
            @{Name = 'LastLogonDate'; Expression = {
                    if ($host.name -eq 'ConsoleHost')
                    {
                        $LastLogonDate = Get-Date ( $_.LastLogonDate )
                        switch ((New-TimeSpan -Start $($LastLogonDate) -End ([datetime]::Now)).Days)
                        {
                            { $_ -gt 90 } { "$([char]0x1b)[91m$($LastLogonDate.ToString())$([char]0x1b)[0m" ; break }
                            { $_ -gt 30 } { "$([char]0x1b)[93m$($LastLogonDate.ToString())$([char]0x1b)[0m" ; break }
                            default { "$([char]0x1b)[32m$($LastLogonDate.ToString())$([char]0x1b)[0m" }
                        }
                    }
                    else
                    {
                        $_.LastLogonDate
                    }
                }
            },
            @{Name = 'PasswordLastSet'; Expression = {
                    if ($host.name -eq 'ConsoleHost')
                    {
                        $PasswordLastSet = Get-Date ( $_.PasswordLastSet )
                        switch ((New-TimeSpan -Start $($PasswordLastSet) -End ([datetime]::Now)).Days)
                        {
                            { $_ -gt 180 } { "$([char]0x1b)[91m$($PasswordLastSet.ToString())$([char]0x1b)[0m" ; break }
                            { $_ -gt 90 } { "$([char]0x1b)[93m$($PasswordLastSet.ToString())$([char]0x1b)[0m" ; break }
                            default { "$([char]0x1b)[32m$($PasswordLastSet.ToString())$([char]0x1b)[0m" }
                        }
                    }
                    else
                    {
                        $_.PasswordLastSet
                    }
                }
            },
            'Created'
        )

        $DetailedProperties = @(
            @{Name = 'OU'; Expression = {
                    $TempArray = ($_.CanonicalName -split '\/') | Select-Object -Skip 1
                    $TempArray[0..$($TempArray.count - 2)] -join ' ❯ '

                }
            },
            'Description',
            'SID'

        )

        if ($Detailed) { $SelectProperties += $DetailedProperties }
    }
    process
    {

        Write-Verbose "Look for computer $identity on $Server domain ..."
        try
        {
            Get-ADComputer $Identity -Properties $Properties -ErrorAction Stop -Server $Server |
                Select-Object $SelectProperties

        }
        catch
        {
            Write-Warning "$Identity not found in $Server"
        }
    }
    end
    {

    }
}

New-Alias computer -Value Get-ADComputerCustom -Force

