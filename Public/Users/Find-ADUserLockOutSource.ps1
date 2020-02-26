<# 
    .SYNOPSIS 
        Find-ADUserLockOutSource returns a list of users who were locked out in Active Directory. 
      
    .DESCRIPTION 
        Find-ADUserLockOutSource is an advanced function that returns a list of users who were locked out in Active Directory 
        by querying the event logs on the PDC emulator in the domain. 
      
    .PARAMETER UserName 
        The userid of the specific user you are looking for lockouts for. The default is all locked out users. 
      
    .PARAMETER StartTime 
        The datetime to start searching the event logs from. The default is the past three days.
    .PARAMETER Credential
        Specifies a user account that has permission to read the security event log on the PDC emulator. The default is
        the current user.
      
    .EXAMPLE 
        Find-ADUserLockOutSource
    .EXAMPLE
        Find-ADUserLockOutSource -Credential (Get-Credential)
      
    .EXAMPLE 
        Find-ADUserLockOutSource -UserName 'user01' 
      
    .EXAMPLE 
        Find-ADUserLockOutSource -StartTime (Get-Date).AddDays(-1) 
      
    .EXAMPLE 
        Find-ADUserLockOutSource -UserName 'user01' -StartTime (Get-Date).AddDays(-1) -Credential (Get-Credential)
    #> 
function Find-ADUserLockOutSource
{

    [CmdletBinding()] 
    param ( 
        [ValidateNotNullOrEmpty()] 
        [string]$DomainName = $env:USERDOMAIN, 
     
        [ValidateNotNullOrEmpty()] 
        [string]$UserName = '*', 
     
        [ValidateNotNullOrEmpty()] 
        [datetime]$StartTime = (Get-Date).AddDays(-3),
    
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    try
    {
        $ErrorActionPreference = 'Stop'
    
        $PdcEmulator = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(( 
                New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $DomainName)) 
        ).PdcRoleOwner.name
    
        $ErrorActionPreference = 'Continue'
    }
    catch
    {
        Write-Error -Message "Unable to query domain $DomainName."
    }
        
    $Params = @{ }
    If ($PSBoundParameters['Credential'])
    {
        $Params.Credential = $Credential
    }
    
    Invoke-Command -ComputerName $PdcEmulator { 
        Get-WinEvent -FilterHashtable @{LogName = 'Security'; Id = 4740; StartTime = $Using:StartTime } |
        Where-Object { $_.Properties[0].Value -like "$Using:UserName" } |
        Select-Object -Property TimeCreated,
        @{Label = 'UserName'; Expression = { $_.Properties[0].Value } },
        @{Label = 'ClientName'; Expression = { $_.Properties[1].Value } }
    } @Params | 
    Select-Object -Property TimeCreated, UserName, ClientName
}