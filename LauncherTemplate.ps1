param([Alias("w")][switch]$wide, [Double]$InitWait = %%InitWait%%, [Double]$Wait=%%Wait%%, [Alias("m")][switch]$Monitor=%%Monitor%%, [Alias("ac")][switch]$AutoClose=%%AutoClose%%, $DisplayName = "%%DisplayName%%", $Titles = "%%Titles%%", $Command = "%%Command%%")

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
    }
    exit
}

function select_from_array() {
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

$mypid = [System.Diagnostics.Process]::GetCurrentProcess().Id

if (!$Monitor) {
    Write-Output "Launching $DisplayName"
    $Command
} else {
    Write-Output "Monitoring $DisplayName"
}
Start-Sleep $InitWait

$process = $null
do {
    [bool]$re_check = $false
    if (!$process -or $re_check) {
        if ($wide) {
            $running = Get-Process | Where-Object { $_.MainWindowTitle -match $Titles -and -not ($_.id -eq $mypid) }    
        } else {
            $running = Get-Process | Where-Object { ($_.ProcessName -match $Titles -or $_.Path -match $Titles) -and -not ($_.id -eq $mypid) }
        }
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
                Write-Host -ForegroundColor Red -NoNewLine "`n`Multiple process matches found for '$DisplayName'"
                $select = select_from_array "Select one" $a "qr" "q -quit`nr - recheck"

                if ($select -eq "r") {
                    [bool]$re_check = $true
                    Start-Sleep $InitWait
                    continue
                } elseif ($select -eq "q") {
                    exit_launcher $AutoClose
                } else {
                    $n=([int][string]$select)-1
                    $process = $running[[int]$n]
                }
            }

        } else {
            $process = $running
        }
        if($process) {
            Write-Output "$DisplayName detected as '$($process.MainWindowTitle.trim())': $($process.Name).exe"
        } else {
            Write-host -ForegroundColor Red "Could not locate '$DisplayName'"
            exit_launcher $AutoClose
        }

    }

    Start-Sleep $Wait
}
while ($re_check -or ($process -and !$process.HasExited))
