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


param([string]$Search, [Alias("ac")][switch]$Autoclose, [Alias("m")][switch]$Monitor, [switch]$NoExe, [switch]$y, [Double]$InitWait = 30.0, [Double]$Wait = 1.0, [string]$Template = "LauncherTemplate.ps1", [string]$Name=$null)
function select_from_array() {
    [CmdletBinding()]
    param (
        $prompt,
        $items,
        $controls="q",
        $help="q - quit"
        )

    $n=$null
    $items | Format-Table | Out-Host

    write-host "? for commands"
    do {
        if ($items.Length -lt 10) {
        write-Host -NoNewLine "${prompt}:"
        $select = [Console]::ReadKey().KeyChar
        write-Host ""
        } else {
            $select = Read-Host -Prompt $prompt
            $select = $select -replace '\s',''
    }
    if ($select -eq "?") {
        Write-host $help
        continue
    }
} while (!($controls.contains($select) -or ([System.Int32]::TryParse($select, [ref]$n) -and $n -le $items.Length -and $n -gt 0)))
return $select
}

function as_bool_string() {
param([bool]$value)
$ret= if ($value) { '$true' } else { '$false' }
return $ret
}
$oPackage = Get-AppxPackage *$Search*

# The publisher name is typically included with the install location
if (!$oPackage -and !$oPackage -is [array]){
    $oPackage = Get-AppxPackage  -ErrorAction SilentlyContinue  | Where-object { $_.InstallLocation  -like "*$Search*"}
}

# Finally try with publisher displayname
# TODO: Use Package.Publisher, needs converting name to publisher id
if (!$oPackage -and !$oPackage -is [array]){
    $p = Get-AppxPackage  -ErrorAction SilentlyContinue  | Get-AppxPackageManifest -ErrorAction SilentlyContinue   | Where-object { $_.Package.Properties.PublisherDisplayName -like "*$Search*"}
    $oPackage = Get-AppxPackage -Name $p.Package.Identity.Name
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

    $i=0
    foreach ($p in $oPackage)
    {
        $i++
        $a+=[PSCustomObject]@{ "#" = $i; "Package Name" = $p.name; "Display Name" = (Get-AppPackageManifest  $p).Package.Properties.DisplayName}
    }
    $select=select_from_array "Select one" $a
    if ($select -eq "q"){
        Exit
    }
    $n=([int][string]$select)-1
    $oPackage = $oPackage[$n]
}
$oManifest = Get-AppPackageManifest $oPackage

$appId = $oManifest.Package.Applications.Application.id

if ($Name) {
    $sDisplayName = $Name
} else {
$sDisplayName = $oManifest.Package.Properties.DisplayName
}

$FamilyName = $oPackage.PackageFamilyName

$sCommand = "explorer.exe shell:appsFolder\$FamilyName!$appId"
$sName = $sDisplayName.replace(" ", "")

$sFileName = $sName
foreach($c in [System.IO.Path]::GetInvalidFileNameChars()) {
    $sFileName  = $sFileName.replace([string]$c,"-")

}

Write-Host $sFileName
$sScript = $sFileName+".ps1"
$sExe = $sFileName+".exe"

$Titles = @($sName,$sDisplayName) -join ("|")

$Template = Get-Content "LauncherTemplate.ps1" -Raw

$sMonitor = as_bool_string $Monitor
$sAutoClose = as_bool_string $Autoclose

if (!$Monitor) {
    Write-host -NoNewline "Creating launcher "
} else {
    Write-host -NoNewline "Creating monitoring "
}
Write-Host "for '$sDisplayName'"
$pub = $oManifest.Package.Properties.PublisherDisplayName
$inst = $oPackage.InstallLocation
Write-Output "Publisher:        $pub"
Write-Output "Install Location: $inst"

if (!$y)
{
    do {
    $continue = Read-Host "Continue? (Y/n)"
    } while  (!"YNny".contains("$continue"))
    if ($continue -eq "n") {
        exit
    }
}

$Launcher = $template -replace "%%InitWait%%", $InitWait -replace "%%Wait%%", $Wait -replace  "%%DisplayName%%", $sDisplayName `
-replace "%%Titles%%", $Titles -replace "%%Command%%", $sCommand -replace "%%Autoclose%%", $sAutoClose `
-replace "%%Monitor%%", $sMonitor  `
-replace "%%AutoClose%%", $Autoclose

try {
    $Launcher | Out-File -FilePath $sScript
} catch {
    Write-host -ForegroundColor Red "could not create launcher $sScript"
    exit
}


if (!$NoExe)
{
    try {
    Invoke-ps2exe .\$sScript .\$sExe
    } catch {
        Write-host -ForegroundColor Red "Could not create launcher $sExe"
        exit
    }
    Write-Host -NoNewline "Created $sExe "

} else {
    Write-Host -NoNewline "Would Create $sScript "
}
if ($Monitor) {
    Write-Output "to monitor $sDisplayName"
} else {
Write-Output "with launch command $sCommand"
}