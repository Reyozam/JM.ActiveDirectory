$ModuleName = "JM.ActiveDirectory"

#=====================================================================================
$ZipURL = "https://github.com/Reyozam/${ModuleName}/archive/master.zip"
$DownloadFile = Join-Path $env:TEMP $($ModuleName + ".zip")
$TempDir = Join-Path $env:TEMP -ChildPath (New-Guid).Guid
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")


if ($IsAdmin)
{
    $Destination = switch -Wildcard ($PSVersionTable.PSVersion.Major)
    {
        { $_ -gt 5 } { "C:\Program Files\PowerShell\Modules\$ModuleName" }
        default { "C:\Program Files\WindowsPowerShell\Modules\$ModuleName" }
    }
}
else
{
    $Destination = switch -Wildcard ($PSVersionTable.PSVersion.Major)
    {
        { $_ -gt 5 } { Join-Path $([environment]::getfolderpath("mydocuments")) -ChildPath "Powershell\Modules\$ModuleName"}
        default { Join-Path $([environment]::getfolderpath("mydocuments")) -ChildPath "WindowsPowershell\Modules\$ModuleName"}
    }
}

if (Test-Path $Destination) {
    Write-Verbose "Remove Old Files from $Destination" -Verbose
    Remove-Item $Destination -Force -Recurse
}

Write-Verbose "Download of $ZipURL ..." -Verbose
Invoke-WebRequest -Uri $ZipURL -OutFile $DownloadFile
Unblock-File $DownloadFile

Write-Verbose "Unzip $DownloadFile to $TempDir" -Verbose
Expand-Archive -Path $DownloadFile -DestinationPath $TempDir -Force
$UnzippedFolder = (Get-ChildItem $TempDir | Where-Object { $_.Name -like "*-master" }).FullName 


Write-Verbose "Copy to $Destination ..." -Verbose

Get-ChildItem $UnzippedFolder | Copy-Item -Destination $Destination -Recurse -Container -Force


Write-Verbose "Remove Temp Files ..." -Verbose
Remove-Item $TempDir -Force -Recurse
Remove-Item $DownloadFile -Force



