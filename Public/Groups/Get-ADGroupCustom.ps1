function Get-ADGroupCustom
{
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('Name')][string]$Identity,
        [Parameter(Mandatory = $false)][switch]$Detailed,
        [Parameter(Mandatory = $false)][string]$Server = $env:USERDNSDOMAIN,
        # Specifies the user account credentials to use when performing this task.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty

    )
    begin
    {
        $Properties = @(
            'GroupCategory',
            'GroupScope'
            'Description'
            'CanonicalName',
            'Members',
            'MemberOf',
            'WhenChanged',
            'WhenCreated'
        )

        $SelectProperties = @(
            'Name',
            'Description',
            'GroupScope',
            @{Name = 'MembersCount'; Expression = {
                    $_.Members.count
                }
            },
            @{Name = 'MemberOfCount'; Expression = {
                    $_.MemberOf.count
                }
            },
            'WhenChanged',
            'WhenCreated',
            'SID'

        )

        $DetailedProperties = @(
            @{Name = 'OU'; Expression = {
                    $TempArray = ($_.CanonicalName -split '\/') | Select-Object -Skip 1
                    $TempArray[0..$($TempArray.count - 2)] -join ' ❯ '

                }
            }
        )

        if ($Detailed) { $SelectProperties += $DetailedProperties }
    }
    process
    {

        Write-Verbose "Look for computer $identity on $Server domain ..."
        try
        {
            Get-ADGroup $Identity -Properties $Properties -ErrorAction Stop -Server $Server |
                Select-Object $SelectProperties

        }
        catch
        {
            Write-Warning "$Identity not found in $Server"
        }
    }
    end
    {

    }
}

New-Alias grp -Value Get-ADGroupCustom -Force

