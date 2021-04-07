function Get-ADUserLockOut
{
<# 
    .SYNOPSIS 
        Get-ADUserLockOut returns a list of users who were locked out in AD and the source of the lockout
      
    .DESCRIPTION 
        Get-ADUserLockOut returns a list of users who were locked out in AD and the source of the lockout
      
    .EXAMPLE 
        Get-ADUserLockOut
      
    .EXAMPLE 
        Get-ADUserLockOut -UserName 'user01'  
#>     

    [CmdletBinding()] 
    param ( 

        [ValidateNotNullOrEmpty()] 
        [string]$UserName = '*', 
        
        [ValidateNotNullOrEmpty()] 
        [string]$Server = $env:USERDNSDOMAIN, 
 
        [ValidateNotNullOrEmpty()] 
        [datetime]$StartTime = (Get-Date).AddDays(-3),

        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    try
    {
        Write-Verbose -Message "Looking for  PDC emulator in $Server domain"
        $PdcEmulator = (Get-ADDomain -Server $Server -ErrorAction Stop).PDCEmulator

        Write-Verbose -Message "The PDC emulator in your forest root domain is: $PdcEmulator"
        $ErrorActionPreference = 'Continue'
    }
    catch
    {
        Write-Error -Message 'Unable to query the domain. Verify the user running this script has read access to Active Directory and try again.'
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