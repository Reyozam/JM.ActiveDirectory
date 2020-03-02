

function Search-GPOByStatusByStatus
{
    <#
    .SYNOPSIS
    Search particular GPO status

    .DESCRIPTION
    Search particular GPO status

    .EXAMPLE
    PS> Search-GPOByStatus -Disabled

    .EXAMPLE
    PS> Search-GPOByStatus -Empty

    .EXAMPLE
    PS> Search-GPOByStatus -Unlinked

#>
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Disabled")][ValidateSet("AllSettings", "Computer", "User")][string[]]$Disabled,
        [Parameter(ParameterSetName = "Empty")][switch]$Empty,
        [Parameter(ParameterSetName = "Unlinked")][switch]$Unlinked
    )
    
    try
    {
        Write-Verbose -Message "Importing GroupPolicy module"
        Import-Module GroupPolicy -ErrorAction Stop
    }
    catch
    {
        Write-Error -Message "GroupPolicy Module not found. Make sure RSAT (Remote Server Admin Tools) is installed"
        exit
    }

    Switch ($PsCmdlet.ParameterSetName)
    {
        "Disabled"
        {
            try
            {
                $GPOs = Get-GPO -All | Where-Object { ($_.GpoStatus -ne "AllSettingsEnabled") -AND ($_.GpoStatus -match $($Disabled -join "|")) } 
            }
            catch
            {
                Write-Error -Message "Can't Load GPO's Please make sure you have connection to the Domain Controllers"
                exit
            }

            $GPOs | Select-Object GPOStatus, DisplayName, ID, CreationTime, ModificationTime

        }

        "Empty"
        {
            try
            {          
                $GPOs = Get-GPO -All  
            }
            catch
            {
                Write-Error -Message "Can't Load GPO's Please make sure you have connection to the Domain Controllers"
                exit
            }
            $EmptyGPO = ForEach ($GPO  in $GPOs)
            { 
                [xml]$GPOXMLReport = $GPO | Get-GPOReport -ReportType xml
                if ($null -eq $GPOXMLReport.GPO.User.ExtensionData -and $null -eq $GPOXMLReport.GPO.Computer.ExtensionData)
                {

                    $GPO | Select-Object DisplayName, ID, GPOStatus, CreationTime, ModificationTime
                }
            }

            return $EmptyGPO
        }

        "Unlinked"
        {
            try
            {          
                $GPOs = Get-GPO -All  
            }
            catch
            {
                Write-Error -Message "Can't Load GPO's Please make sure you have connection to the Domain Controllers"
                exit
            }

            $UnlinkedGPO = ForEach ($GPO  in $GPOs)
            { 
                
                [xml]$GPOXMLReport = $GPO | Get-GPOReport -ReportType xml
                if ($null -eq $GPOXMLReport.GPO.LinksTo)
                { 
                    $GPO | Select-Object DisplayName, ID, GPOStatus, CreationTime, ModificationTime
                }
            }

            return $UnlinkedGPO
        }
    }

}

