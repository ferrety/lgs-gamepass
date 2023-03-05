# Powershell script to create executable launcher for gamepass games, e.g., for LGS
#
## Usage:
#    ./CreateExe.ps1 <part of game name>
#
## Example
#
#    ./CreateExe <NoMans>
#
#  Creates NomansSky.exe that can be used launch No Man's Sky
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


param([string]$Search, [switch]$NoAutoclose, [switch]$NoExe, [Double]$InitWait = 30.0, [Double]$Wait = 1.0)

$oPackage = Get-AppxPackage *$Search*

if (!$oPackage)
{
    Write-Host -ForegroundColor Red "Could not find package for '$Search'"
    Exit
} elseif ($oPackage -is [array])
{
    Write-Host -ForegroundColor Red "Multiple packages found for search '$Search'"
    $a = @()
    foreach ($p in $oPackage)
    {
        $a+=[PSCustomObject]@{ "Package Name" = $p.name; "Display Name" = (Get-AppPackageManifest  $p).Package.Properties.DisplayName}
    }
    $a |Format-Table -AutoSize |Out-String
    Exit
}
$oManifest = Get-AppPackageManifest  $oPackage
$sFile = (Get-ChildItem -Filter "appxmanifest.xml" -Recurse  $oPackage.InstallLocation).FullName

$appId = $oManifest.Package.Applications.Application.id
$sDisplayName = $oManifest.Package.Applications.Application.VisualElements.DisplayName

$FamilyName = $oPackage.PackageFamilyName

$sCommand = "explorer.exe shell:appsFolder\$FamilyName!$appId"
$sName = $oPackage.name.Split(".")[1].ToString().split("-")[0].toString()
$sScript = $sName+".ps1"
$sExe = $sName+".exe"

Write-Output "Creating launcher for "+$sDisplayName
Out-File -FilePath $sScript -InputObject @"
param([Double]`$InitWait = $InitWait, [Double]`$Wait=$Wait)
Write-Output "Launching  $sDisplayname"
$sCommand
"@

if (!$NoAutoclose)
{
    Out-File -FilePath $sScript -Append -InputObject @"


Start-Sleep `$InitWait
[bool]`$bCheck = `$true
do
{
    `$running = Get-Process | Where-Object { `$_.MainWindowTitle -like "$sDisplayname"}
    Start-Sleep `$Wait
    if ((`$bCheck)  -and (`$running))
    {
        Write-Output "$sDisplayname detected"
        `$bCheck = `$false
    }

}
while (`$running)

"@
} else {
    Out-File -FilePath $sScript -Append -InputObject @"
Write-Host -NoNewLine 'Press space after game exit...';
do
{
    `$key = [Console]::ReadKey($true)
    `$value = `$key.KeyChar
}
while (`$value -notmatch ' ')
"@
}

Out-File -FilePath $sScript -Append -InputObject "Write-Output 'Exiting...'"


if (!$NoExe)
{
    Invoke-ps2exe .\$sScript .\$sExe

    Write-Output "Created $sExe with"
} else {
    Write-Output "Would Create $sExe with"
}
Write-Output "$sCommand"
