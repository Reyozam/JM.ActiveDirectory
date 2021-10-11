function Get-ADGroupMemberCrossDomain
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Identity,

        [Parameter(Mandatory = $false)]
        [string]
        $Server = $env:USERDOMAIN

    )

    try 
    {
        $GroupObj = Get-ADGroup -Identity $Identity -Properties members -Server $Server -ErrorAction Stop
        $MembersObj = $GroupObj.Members | Get-ADObject -Server $Server

    }
    catch 
    {
        Write-Error "Unable to find group $identity in $server domain"
    }

    $output = New-Object collections.generic.list[object]

    foreach ($member in $MembersObj) 
    {
        $return = switch ($member.ObjectClass)
        {
            foreignSecurityPrincipal 
            {  
                $SID = $member.Name
                $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
                $ResolvedDomain, $ResolvedObject = $objSID.Translate( [System.Security.Principal.NTAccount]).Value -split "\\"
                $ADObj = Get-ADObject -Filter { objectsid -eq $sid } -Server $ResolvedDomain -Verbose

                switch ($ADObj.ObjectClass)
                {
                    user { Get-ADUser -Identity $ResolvedObject -Server  $ResolvedDomain -Verbose }
                    group { Get-ADGroup -Identity $ResolvedObject -Server $ResolvedDomain -Verbose }
                }

                $OriginDomain = $ResolvedDomain
            }
            user    
            { 
                Get-ADUser $member.name -Server $Server
                $OriginDomain = $Server
            }
            group   
            { 
                Get-ADGroup $member.name -Server $Server
                $OriginDomain = $Server
            }
        }

        $return | Add-Member -NotePropertyName SourceDomain -NotePropertyValue $OriginDomain.ToUpper() -Force
        $output.Add( $return )
    
    }

    return $output
}
