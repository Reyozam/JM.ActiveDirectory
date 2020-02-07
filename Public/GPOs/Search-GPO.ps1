﻿###############################################################################################################
# Language     :  PowerShell 5.0
# Filename     :  Get-RunInfo.ps1
# Autor        :  Julien Mazoyer
# Description  :  Search particular GPO status
###############################################################################################################

<#
    .SYNOPSIS
    Search particular GPO status

    .DESCRIPTION
    Search particular GPO status

    .EXAMPLE
    PS> Search-GPO -Disabled

    .EXAMPLE
    PS> Search-GPO -Empty

    .EXAMPLE
    PS> Search-GPO -Unlinked

#>

function Search-GPO
{
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Disabled")][switch]$Disabled,
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
                $GPOs = Get-GPO -All  
            }
            catch
            {
                Write-Error -Message "Can't Load GPO's Please make sure you have connection to the Domain Controllers"
                exit
            }

            $DisabledGPO = ForEach ($GPO  in $GPOs)
            { 
                Write-Verbose -Message "Checking '$($GPO.DisplayName)' status"
                switch ($GPO.GPOStatus)
                {
                    "ComputerSettingsDisabled" { $DisabledGPO = "Computer Settings" }
                    "UserSettingsDisabled" { $DisabledGPO = "User Settings" }
                    "AllSettingsDisabled" { $DisabledGPO = "All Settings" }
                }
        
                [PSCustomObject]@{
                    Name   = $GPO.DisplayName
                    Status = $DisabledGPO
                }
            }

            return $DisabledGPO
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
                    [PSCustomObject]@{
                        Name         = $GPO.DisplayName
                        Status       = $GPO.GPOStatus
                        CreationTime = $GPO.CreationTime
                    }
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
                    [PSCustomObject]@{
                        Name         = $GPO.DisplayName
                        Status       = $GPO.GPOStatus
                        CreationTime = $GPO.CreationTime
                    }
                }
            }

            return $UnlinkedGPO
        }
    }

}
