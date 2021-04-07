function Show-ADUser
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("SamAccountName")]
        [string]$Identity,
        [Parameter()][string]$Server = $env:USERDOMAIN
    )
    $Date = [datetime]::Now
    $ObsoloteDate = $DAte.AddDays(-90)

        try 
        {
            $User = Get-ADUser $Identity -Server $Server -Properties * -ErrorAction Stop
            Write-Host " STATUS          `t" -NoNewline

            if ($User.Enabled -eq $true) { Write-Host " ENABLED " -BackgroundColor Green -ForegroundColor Black -NoNewline }
            else { Write-Host " DISABLED " -BackgroundColor Red -ForegroundColor Black -NoNewline }
    
            if ($USer.LockedOut -eq $true) { Write-Host " LOCKED " -BackgroundColor DarkYellow -ForegroundColor Black -NoNewline }
            else { Write-Host "" }

            Write-Host ""
            Write-Host "SamAccountName   `t" -NoNewline ; Write-Host $User.SamAccountName
            Write-Host "Display Name:    `t" -NoNewline ; Write-Host $User.DisplayName
            Write-Host "UPN:             `t" -NoNewline ; Write-Host $User.UserPrincipalName
      
            #OU
            [array]$OUs = ("$( $User.DistinguishedName -replace '^.*?,(..=.*)$', '$1')" -split "," | Where-Object { $_ -like "OU=*" }) -replace "OU="
            [array]::Reverse($OUs)
            Write-Host "OU:              `t" -NoNewline ; Write-Host ($Server + " > " + ($OUs -join " > "))

            Write-Host ""
            Write-Host "LastLogonDate:   `t" -NoNewline
            if ($User.LastLogonDate -gt $ObsoloteDate) { Write-Host $user.LastLogonDate -ForegroundColor Green } else { Write-Host $user.LastLogonDate -ForegroundColor DarkYellow }
            Write-Host "LastPasswordSet: `t" -NoNewline
            if ($User.PasswordLastSet -gt $ObsoloteDate) { Write-Host $user.PasswordLastSet -ForegroundColor Green } else { Write-Host $user.PasswordLastSet -ForegroundColor DarkYellow }
            Write-Host "CreatedOn:       `t" -NoNewline ; Write-Host $User.Created
            Write-Host "ModifiedOn:      `t" -NoNewline ; Write-Host $User.Modified
      
        }
        catch 
        {
            Write-Warning "Le compte $Identity n'existe pas dans $Server"
        }

}

New-Alias -Name user -Value Show-ADUser -Scope global
    
