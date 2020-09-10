function Show-ADUser {
   [CmdletBinding()]
   param (
       [Parameter(Mandatory)][string]$Identity,
       [Parameter()][string]$Server = $env:USERDNSDOMAIN
   )
    $Date = [datetime]::Now
    $ObsoloteDate = $DAte.AddDays(-90)

    try 
    {
      $User = Get-ADUser $Identity -Server $Server -Properties * -ErrorAction Stop
      Write-Host " STATUS          `t" -NoNewLine

      if ($User.Enabled -eq $true) {Write-Host " ENABLED " -BackgroundColor Green -ForegroundColor Black -NoNewLine}
      else {Write-Host " DISABLED " -BackgroundColor Red -ForegroundColor Black -NoNewLine}
    
      if ($USer.LockedOut -eq $true) {Write-Host " LOCKED " -BackgroundColor DarkYellow -ForegroundColor Black -NoNewLine}
      else {Write-Host ""}

      Write-Host ""
      Write-Host "SamAccountName   `t" -NoNewLine ; Write-Host $User.SamAccountName
      Write-Host "Display Name:    `t" -NoNewLine ; Write-Host $User.DisplayName
      Write-Host "UPN:             `t" -NoNewLine ; Write-Host $User.UserPrincipalName
      
      #OU
      [array]$OUs = ("$( $User.DistinguishedName -replace '^.*?,(..=.*)$', '$1')" -split "," | Where-Object { $_ -like "OU=*" }) -replace "OU="
      [array]::Reverse($OUs)
      Write-Host "OU:              `t" -NoNewLine ; Write-host ($Server + " > " + ($OUs -join " > "))

      Write-Host ""
      Write-Host "LastLogonDate:   `t" -NoNewLine
      if ($User.LastLogonDate -gt $ObsoloteDate) {Write-Host $user.LastLogonDate -ForegroundColor Green} else {Write-Host $user.LastLogonDate -ForegroundColor DarkYellow}
      Write-Host "LastPasswordSet: `t" -NoNewLine
      if ($User.PasswordLastSet -gt $ObsoloteDate) {Write-Host $user.PasswordLastSet -ForegroundColor Green} else {Write-Host $user.PasswordLastSet -ForegroundColor DarkYellow}
      Write-Host "CreatedOn:       `t" -NoNewLine ; Write-Host $User.Created
      Write-Host "ModifiedOn:      `t" -NoNewLine ; Write-Host $User.Modified
      
    }
    catch 
    {
        Write-Warning "Le compte $Identity n'existe pas dans $Server"
    }
}