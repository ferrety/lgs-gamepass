param([Double]$InitWait = %%InitWait%%, [Double]$Wait=%%Wait%%, [Alias("m")][switch]$Monitor=%%Monitor%%, [Alias("ac")][switch]$AutoClose=%%AutoClose%%)

function exit_launcher() {
    param([bool]$AutoClose)
    if ($AutoClose) {
        Write-Host -NoNewLine 'Exiting'
        for($i=0;$i -lt 5;$i++){
            Write-Host -NoNewLine  '.'
            Start-Sleep -m 500
        }
    } else {
        Write-Host -NoNewLine 'Press any key to exit';
        $key = [Console]::ReadKey($true)
        exit
    }
}

$DisplayName = "%%DisplayName%%"
$Titles = "%%Titles%%"

if (!$Monitor) {
    Write-Output "Launching $DisplayName"
    %%Command%%
} else {
    Write-Output "Monitoring $DisplayName"
}
Start-Sleep $InitWait

$process = $null
do {
    [bool]$re_check = $false
    if (!$process -or $re_check) {
        $running = Get-Process | Where-Object { $_.MainWindowTitle -match $Titles}
        if ($running -is [array]) {
            $a = @()
            for ($i = 0; $i -lt $running.Length; $i++) {
                $p = $running[$i]
                if ($p.Name -match $Titles -or $p.ProcessName -match $Titles -or $p.Path -match $Titles) {
                    $process = $p
                    break
                }
                $a+=[PSCustomObject]@{ "`#" = $i+1; "Name" = $p.Name; "Window Title"=$p.MainWindowTitle; "Path" = $p.Path;}
            }
            if (!$process) {
                Write-Host -ForegroundColor Red -NoNewLine "`n`Multiple match found for '$DisplayName'"
                $a |Format-Table -AutoSize |Out-String
                write-Host -NoNewLine "Select one, re-check with r or exit with any other key: "
                $select = [Console]::ReadKey().KeyChar
                write-Host ""
                if ($select -eq "r") {
                    [bool]$re_check = $true
                    Start-Sleep $InitWait
                    continue
                }
                $n = $null
                if ( [System.Int32]::TryParse($select, [ref]$n) -and $n -le $running.Length -and $n -gt 0) {
                       $process = $running[[int]$n-1]
                } else {
                    exit_launcher $AutoClose
                }
            }

        } else {
            $process = $running
        }
        if($process) {
            Write-Output "$DisplayName detected as '$($process.Name): $($process.MainWindowTitle)'"
        } else {
            Write-host -ForegroundColor Red "Could not locate '$DisplayName'"
            exit_launcher $AutoClose
        }

    }

    Start-Sleep $Wait
}
while ($re_check -or ($process -and !$process.HasExited))
