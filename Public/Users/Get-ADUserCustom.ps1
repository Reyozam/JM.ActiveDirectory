function Get-ADUserCustom
{
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('SamAccountName')][string]$Identity,
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
            'LockedOut',
            'LastLogonDate',
            'PasswordLastSet',
            'PasswordNeverExpires',
            'msDS-UserPasswordExpiryTimeComputed'
        )

        $SelectProperties = @(
            'SamAccountName',
            'Name',
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
            @{Name = 'LockedOut'; Expression = {
                    if ($host.name -eq 'ConsoleHost')
                    {
                        if (-not $_.LockedOut)
                        {
                            "$([char]0x1b)[32m$($_.LockedOut)$([char]0x1b)[0m"
                        }
                        else
                        {
                            "$([char]0x1b)[91m$($_.LockedOut)$([char]0x1b)[0m"
                        }
                    }
                    else
                    {
                        $_.LockedOut
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
            @{Name = 'PasswordExpiration'; Expression = {

                    $PasswordExpiration = if ($_.PasswordNeverExpires) { 'Never' } else { ([datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')) }
                    $Now = ([datetime]::Now)
                    $TimeSpan = New-TimeSpan -Start $PasswordExpiration -End $Now

                    if ($host.name -eq 'ConsoleHost')
                    {
                        if ($Now -gt $PasswordExpiration) { "$([char]0x1b)[91m$($PasswordExpiration.ToString())$([char]0x1b)[0m" }
                        elseif ($TimeSpan.Days -ge -10 ) { "$([char]0x1b)[93m$($PasswordExpiration.ToString())$([char]0x1b)[0m" }
                        else { "$([char]0x1b)[32m$($PasswordExpiration.ToString())$([char]0x1b)[0m" }
                    }
                    else
                    {
                        $PasswordExpiration
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
            'UserPrincipalName',
            'Description',
            'SID'

        )

        if ($Detailed) { $SelectProperties += $DetailedProperties }
    }

    process
    {

        Write-Verbose "Look for user $identity on $Server domain ..."
        try
        {
            Get-ADUser $Identity -Properties $Properties -ErrorAction Stop -Server $Server |
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

New-Alias user -Value Get-ADUserCustom -Force

