# Powershell script to create executable launcher for gamepass games, e.g., for LGS
#  
## Usage:
#    ./CreateExe.ps1 <part of game name>
# 
## Example 
#
#    ./CreateExe <NoMans>
#
#  Creates NomansSky.exe that can be  used launch No Man's Sky
#  The executable can then be used in LGS to detect if NMS is running
#  
## Rquirements
# 
#  [PS2EXE](https://github.com/MScholtes/PS2EXE)
#  Install with 
#  Install-Module ps2exe
#
#  Enable running PS scripts asneeded
#  Set-ExecutionPolicy  -ExecutionPolicy Unrestricted -Scope Process

$search = $args
$package = Get-AppxPackage *$search*
if (!$package)
{
    Write-Output "Could not find package for $search"
    Exit
}
$sFile = (Get-ChildItem -Filter "appxmanifest.xml" -Recurse  $package.InstallLocation).FullName

[xml]$xml = Get-Content $sFile
$appId = $xml.Package.Applications.Application.Id
Write-Output $package.Name

$sName = $package.name.Split(".")[1].ToString().split("-")[0].toString()
$sScript = $sName+".ps1"
$sExe = $sName+".exe"


Out-File -FilePath $sScript -InputObject "explorer.exe shell:appsFolder\$package.PackageFamilyName!$appId"
Out-File -FilePath $sScript -Append -InputObject @"
Write-Host -NoNewLine 'Press space after game exit...';
do 
{
    `$key = [Console]::ReadKey($true)
    `$value = `$key.KeyChar
}
while (`$value -notmatch ' ')
"@

Invoke-ps2exe .\$sScript .\$sExe

Write-Output "Created $sExe with"
Write-Output "explorer.exe shell:appsFolder\$package.PackageFamilyName!$appId"
