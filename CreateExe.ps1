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


param([string]$Search, [switch]$NoAutoclose, [switch]$NoExe, [switch]$y=$False, [Double]$InitWait = 30.0, [Double]$Wait = 1.0)

$oPackage = Get-AppxPackage *$Search*

# The publisher name is typically included with the install location
if (!$oPackage -and !$oPackage -is [array]){
    $oPackage = Get-AppxPackage  -ErrorAction SilentlyContinue  | Where-object { $_.InstallLocation  -like "*$Search*"}
}

# Finally try with publisher displayname
# TODO: Use Package.Publisher, needs converting name to publisher id
if (!$oPackage -and !$oPackage -is [array]){
    $p =Get-AppxPackage  -ErrorAction SilentlyContinue  | Get-AppxPackageManifest -ErrorAction SilentlyContinue   | Where-object { $_.Package.Properties.PublisherDisplayName -like "Focus*"}
    $oPackage=Get-AppxPackage -Name $p.Package.Identity.Name
}


if (!$oPackage)
{
    Write-Host -ForegroundColor Red "Could not find package for '$Search'"
    Write-Output "You can try with part of publisher name or install directory"
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

$appId = $oManifest.Package.Applications.Application.id
$sDisplayName = $oManifest.Package.Properties.DisplayName

$FamilyName = $oPackage.PackageFamilyName

$sCommand = "explorer.exe shell:appsFolder\$FamilyName!$appId"
$sName = $sDisplayName.replace(" ", "")
$sScript = $sName+".ps1"
$sExe = $sName+".exe"

Write-Output "Creating launcher for '$sDisplayName'"
if (!$y)
{
    do {
    $continue = Read-Host "Continue? (Y/n)"
    } while  (!"YNny".contains("$continue"))
    if ($continue -eq "n") {
        exit
    }
}
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

    Write-Output "Created $sExe with command"
} else {
    Write-Output "Would Create $sExe with command"
}
Write-Output "$sCommand"
