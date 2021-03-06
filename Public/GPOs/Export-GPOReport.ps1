Function Export-GPOReport
{
<#
    .SYNOPSIS
    Export HTML Report of all GPO in a domain
    .DESCRIPTION
    Export HTML Report of all GPO in a domain
    .PARAMETER OutputDirectory
    
    .EXAMPLE
    PS C:\> Export-DomainGPOs -OutputDirectory C:\TEMP\ -Verbose
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)][String]$OutputDirectory,
        [String]$Server = $env:userdomain

    )

    if (-not(Get-Module -ListAvailable -Name GroupPolicy))
    {
        Write-Error "Le module `"GroupPolicy`" est introuvable"
        break
    }

    if (-not(Get-Module -ListAvailable -Name ActiveDirectory))
    {
        Write-Error "Le module `"ActiveDirectory`" est introuvable"
        break
    }

    #Remove trailing slash if present.
    If ($OutputDirectory -like "*\") { $OutputDirectory = $OutputDirectory.substring(0, ($OutputDirectory.Length - 1)) }

    $OutputDirectory = Join-Path -Path $OutputDirectory -ChildPath ("{0}-GPO-{1}" -f (Get-Date -f "yyMMdd"), $Server.ToUpper())
    $ServerFQDN = (Get-ADDomain $Server).DNSRoot
    $GPOs = Get-Gpo -All -Domain $ServerFQDN
    $AllGPOs = @()

    If (!(Test-Path $OutputDirectory)) { mkdir $OutputDirectory -Force | Out-Null }

    $i = 0
    $Count = ($GPOs | Measure-Object).Count
    ForEach ($GPO in $GPOs)
    {
        $i++
        Write-Progress -Activity "Exporting GPOs..." -Status $GPO.DisplayName -PercentComplete $(($i / $Count) * 100)

        $AllGPOs += $GPO.DisplayName
        Write-Verbose ("Exporting " + $OutputDirectory + "\" + $GPO.DisplayName + ".HTML...")
        $Path = $OutputDirectory + "\" + $GPO.DisplayName + ".HTML"
        Get-GPOReport -Name $GPO.DisplayName -Domain $ServerFQDN -ReportType HTML -Path $Path
    }
    $AllGPOs = $AllGPOs | Sort-Object
    Write-Verbose ("Exporting " + $OutputDirectory + "\AllGPOs.txt...")
    $AllGPOs | Out-File ($OutputDirectory + "\AllGPOs.txt")

    $OUs = Get-ADOrganizationalUnit -Filter * -server $ServerFQDN | Sort-Object { -join ($_.distinguishedname[($_.distinguishedname.length - 1)..0]) }
    $OutputArray = @()
    $OUs | ForEach-Object {
        $Inheritance = Get-GPInheritance -Target $_.DistinguishedName -Domain $ServerFQDN

        $GpoLinks = @()
        If ($Inheritance.GpoLinks.DisplayName)
        {
            ForEach ($i in 0..($Inheritance.GpoLinks.DisplayName.Count - 1))
            {
                $GpoLinks += $Inheritance.GpoLinks[$i].Order.toString() + ": " + $Inheritance.GpoLinks[$i].DisplayName
            }
        }

        $Obj = New-Object -TypeName PSObject
        $Obj | Add-Member -MemberType NoteProperty -Name "Path" -Value $Inheritance.Path
        $Obj | Add-Member -MemberType NoteProperty -Name "GpoLinks" -Value ($GpoLinks -join ", ")
        $OutputArray += $Obj
    }

    Write-Verbose ("Exporting " + $OutputDirectory + "\GPOLinks.csv...")
    $OutputArray | Export-Csv ($OutputDirectory + "\GPOLinks.csv") -NoTypeInformation -Delimiter ";"
}

