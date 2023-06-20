function Get-ADInactiveUsers
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)][int]$InactivityDays = 180,
        [Parameter(Mandatory = $false)][string]$Server = $env:USERDNSDOMAIN,
        # Specifies the user account credentials to use when performing this task.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]$Credential

    )

    $ADParams = @{
        Server = $Server
    }

    if ($Credential)
    {
        $ADParams['Credential'] = $Credential
    }

    $InactivityDate = (Get-Date).AddDays(-$InactivityDays)

    $InactiveConditions = {
        ($_.Enabled) -and
        ($_.LastLogonDate -lt $InactivityDate) -and
        ($_.WhenCreated -lt $InactivityDate) -and
        ($_.DistinguishedName -notmatch "CN=Users,DC=gsy,DC=ad,DC=gaselys,DC=com" )
    }


    $SelectProperties = @(
        "*" ,
        @{Name = 'DaysOfInactivity'; Expression = {
                New-TimeSpan -Start $($_.LastLogonDate, $_.WhenCreated | Sort-Object | Select-Object -Last 1) -End $(Get-Date) | Select-Object -ExpandProperty Days
            }
        }
    )


    Get-ADUser -Filter * -Server $Server -Credential $Credential -Properties LastLogonDate, WhenCreated, Enabled | Where-Object $InactiveConditions | Select-Object $SelectProperties -ExcludeProperty PropertyNames,AddedProperties,RemovedProperties,ModifiedProperties,PropertyCount

}