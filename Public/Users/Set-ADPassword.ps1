function Set-ADPassword
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$Username,
        [Parameter(Mandatory = $false)]$Domain = $env:USERDNSDOMAIN,
        [switch]$ChangePasswordAtLogon
    )

    try 
    {
        $user = Get-ADUser $Username -Server $Domain -ErrorAction Stop
    }
    catch 
    {
        Write-Warning "$Username not found in $Domain"
        break
    }

    do
    {

        Write-Host "Type Password    > " -ForegroundColor DarkYellow -NoNewline ; $Password01 = Read-Host -AsSecureString
        Write-Host "Re-Type Password > " -ForegroundColor DarkYellow -NoNewline ; $Password02 = Read-Host -AsSecureString
        Write-Host ""
    
        $Password01_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password01))
        $Password02_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password02))
        
    } until ($Password01_text -ceq $Password02_text)

    try 
    {
        Set-ADAccountPassword -identity $Username -Reset -NewPassword $Password01 -Server $Domain -ErrorAction Stop
        Write-Host "[!] The Password for ${User.Name} has been changed " -ForegroundColor Green
    }
    catch 
    {
        Write-Host "[x] The Password for ${User.Name} has not been changed " -ForegroundColor Red
    }
    

    if ($ChangePasswordAtLogon)
    {
        Set-ADUser -Identity $Username -ChangePasswordAtLogon $true -Server $Domain
    }

}