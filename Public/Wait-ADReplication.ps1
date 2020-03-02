function Wait-ADReplication
{
    <#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $SamAccountName,

        [Parameter()]
        [string]
        $Domain = $env:USERDNSDOMAIN
    )

    Clear-Host
    
    [psobject]$DCs = Get-ADDomainController -Server $Domain -Filter * | Select-Object Name, Hostname
    $StartTime = [DateTime]::Now
    $Output = [System.Collections.ArrayList]::new()

    do 
    {
        foreach ($DC in $DCs) 
        {
            Write-Host "Search for [$SamAccountName] on $($DC.Name) `t" -NoNewline
            $Search = Get-ADObject -Filter { Name -eq $SamAccountName -or SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue -Properties whencreated, whenchanged

            if ($Search)
            {
                Write-Host "FOUND in $(([DateTime]::Now - $startTime).Seconds) seconds !" -ForegroundColor Green

                $DCs = $DCS | Where-Object { $_.Name -ne $DC.Name }

                $Output.Add([PSCustomObject]@{
                        SAM        = $SamAccountName
                        DC         = $DC.Name
                        CreatedOn  = $Search.WhenCreated
                        ModifiedOn = $Search.WhenChanged

                    }) | Out-Null
            }
            else
            {
                Write-Host "NOT FOUND !" -ForegroundColor DarkYellow 
            }
        }
    
        Write-Host "Retry in 5 seconds"
        Start-Sleep -Seconds 5

    } until ($DCs.Count -eq 0)
   

    Write-Output $Output

}
    