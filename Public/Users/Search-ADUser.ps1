function Search-ADUser
{
    [CmdletBinding()]
    [alias("su")]
    Param (
        [Parameter(Mandatory = $true)]
        [Alias("User", "UserName", "SamAccountName", "Name")]
        [string]$Search,
        [Parameter(Mandatory = $false)]
        [string]$Server = $env:USERDOMAIN

    )

    try
    {
        $Found = Get-ADUser $Search -Properties LastLogonDate,PasswordLastSet -ErrorAction Stop -Server $Server
        return $Found
    }
    catch
    {
        $Lookup = "*" + $Search + "*" -replace " ", "*"
        $Found = Get-ADUser -Filter { (SamAccountName -like $Lookup) -or (Name -like  $Lookup) } -Properties LastLogonDate,PasswordLastSet -Server $Server
    }

    return $found
}

