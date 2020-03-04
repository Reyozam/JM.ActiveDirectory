# :busts_in_silhouette: JM.ActiveDirectory

Some PowerShell helpers for Active Directory Daily Tasks

## Installation

You can get the current release from this repository or install this from the PowerShell Gallery:

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Reyozam/JM.ActiveDirectory/master/InstallModule.ps1'))
```

## Functions

### Compare-ADGroupMembership

Compare Group Membership for multiple Users
```powershell
PS>Compare-ADGroupMembership user1,user2

UserName Status GroupName                             %OfUsersInGroup

user1   NotIn  Group1                                 50
user1   NotIn  Group2                                 50
user2   NotIn  Group3                                 50
user2   NotIn  Group4                                 50
```
### Copy-ADGroupMembership

Add target users on the same AD group than the source user
```powershell
PS>Copy-ADGroupMembership -SourceUser user1 -TargetUsers user2,user3
```
### Export-GPOReport

Export HTML Report of all GPO in a domain
```powershell
PS C:\>Export-DomainGPOs -OutputDirectory C:\TEMP\ -Verbose
```
### Find-ADObsoleteComputer

Function is querying the Active Directory and searching for all computer objects that did not update their passwords for period of time.
```powershell
PS C:\>Find-ObsoleteComputer -PasswordOlderThan 90

ComputerName    PasswordLastSet     

DESKTOP-ROOH24P 21/2/2018 13:35:04
```
### Get-ADDC

This function will return domain controllers list & info.
```powershell
PS C:\>Get-ADDC

Hostname                    Site     IPv4Address   OperationMasterRoles                          IsGlobalCatalog IsReadOnly

DC01                        FR      10.22.231.69  {}                                                        True      False
DC02                        BEL     10.22.250.32  {}                                                        True      False
DC03                        CRO     10.22.194.108 {}                                                        True      False
DC04                        SING    10.22.165.48  {PDCEmulator, RIDMaster, InfrastructureMaster}            True      False
```
### Get-ADReplicationStatus

Return Replication Status, Success & Errors TimeStamp

```powershell
PS C:\>Get-ADReplicationStatus

Server       ServerPartner PartnerType LastReplicationAttempt LastReplicationResult LastReplicationSuccess ConsecutiveReplicationFailures

DC03          DC01          Inbound     04/03/2020 17:16:06                        0 04/03/2020 17:16:06                                 0
DC03          DC02          Inbound     04/03/2020 17:16:06                        0 04/03/2020 17:16:06                                 0
DC04          DC01          Inbound     04/03/2020 17:29:17                        0 04/03/2020 17:29:17                                 0
DC04          DC02          Inbound     04/03/2020 17:29:17                        0 04/03/2020 17:29:17                                 0
DC04          DC03          Inbound     04/03/2020 17:29:17                        0 04/03/2020 17:29:17                                 0
```
### Get-ADSiteIPAttribution

Return AD Site attribution by IP Address
```powershell
PS C:\>Get-ADSiteIPAttribution 10.20.160.23

ADSite  Subnet
------  ------

00FR    10.0.0.0/8
```

### Get-ADUserBySID

Convert SID to user or computer account name, can find built-in SID
```powershell
PS C:\>ConvertFrom-SID S-1-5-21-2139171146-395215898-1246945465-2359
```
### Get-ADUserGroupMembership

Get AD User Group Membership list
```powershell
PS C:\>Get-ADUserGroupMembership "User01"
```
### Get-ADUserLockOut

Get-ADUserLockOut returns a list of users who were locked out in AD and the source of the lockout
```powershell
PS C:\>Get-ADUserLockOut

TimeCreated         UserName ClientName
-----------         -------- ----------
3/4/2020 9:44:15 AM USER1    COMPUTER01

PS C:\>Get-ADUserLockOut -UserName 'user01'
```
### Set-ADPassword

Reset AD Password from the console
```powershell
PS C:\>Set-ADPassword
```
### Start-ADReplication

Start replication against one or all domain controllers.
```powershell
PS C:\>Start-ADReplication -All

PS C:\>Start-ADReplication -DomainController DC01
```
### Sync-ADObjectNow

Start replication of one AD object on all controllers
```powershell
PS C:\>Sync-ADObjectNow user01

PS C:\>Sync-ADObjectNow computer01
```
### Watch-ADObjectReplication

Search object on all controller and wait for replication is completed. Return information on replication time.
```powershell
PS C:\>Watch-ADObjectReplication -Identity user01

Object                                    Server            ReplicatedOn

CN=MCLANE John,OU=Users,DC=contoso,DC=com DC01.contoso.com  11/07/2019 16:14:43
CN=MCLANE John,OU=Users,DC=contoso,DC=com DC02.contoso.com  11/07/2019 16:14:49
CN=MCLANE John,OU=Users,DC=contoso,DC=com DC03.contoso.com  11/07/2019 16:16:54
CN=MCLANE John,OU=Users,DC=contoso,DC=com DC04.contoso.com  11/07/2019 16:18:10
```
