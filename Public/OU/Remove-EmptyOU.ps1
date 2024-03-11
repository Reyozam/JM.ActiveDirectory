function Remove-EmptyOU
{
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)][string]$RootOU,
        [string]$Server = $env:USERDNSDOMAIN,
        [int]$DaysOldLimit = 30,
        [System.Management.Automation.PSCredential]$Credential
    )

    $ADParams = @{
        Server = $Server

    }

    if ($Credential) { $ADParams['Credential'] = $Credential }

    $LimitDate = (Get-Date).AddDays(-$DaysOldLimit)

    $EmptyOUs = Get-ADOrganizationalUnit -Filter * -SearchBase $RootOU  -Properties whenCreated @ADParams |
        Where-Object {$_.whenCreated -lt $LimitDate} |
        ForEach-Object { If ( !( Get-ADObject -Filter * -SearchBase $_ -SearchScope OneLevel @ADParams) ) { $_ } }


    $EmptyOUs | ForEach-Object {

        Write-Verbose "Remove OU: $($_.DistinguishedName)" -Verbose
        $_ | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false
    }

}