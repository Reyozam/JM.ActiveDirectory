function Test-UserInGroup
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $UserSamAccountName,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $GroupName,
        [Parameter(Mandatory = $false, Position = 2)]
        [string] $Server = $env:USERDNSDOMAIN
    )

    $ADParams = @{
        Server      = $Server
        ErrorAction = 'Stop'
    }

    try
    {
        $MemberOf = Get-ADuser -Identity $UserSamAccountName -Properties MemberOf @ADParams | Select-Object MemberOf -ExpandProperty MemberOf
        $GroupDN = Get-ADGroup $GroupName @ADParams | Select-Object -ExpandProperty DistinguishedName

        if ($MemberOf -contains $GroupDN)
        {
            $true
        }
        else
        {
            $false
        }
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}