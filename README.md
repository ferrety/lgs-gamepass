# Simplistic LGS detection for GamePass games
Powershell script to create a Game Pass game  launcher that can be used for  LGS detection

## Usage:
```
./CreateExe.ps1 <part of game name>
```

When creating LGS profile you need to select the "Lock profile while game is running" -option. When you finish playing, you need to close the launcher.


## Requirements

  [PS2EXE](https://github.com/MScholtes/PS2EXE)
  Install with
```
Install-Module ps2exe
```

  Enable running PS scripts if needed, i.e., running scripts is disabled on your system
```
Set-ExecutionPolicy  -ExecutionPolicy Unrestricted -Scope Process
```

## Example
```
./CreateExe.ps1 Doom*Eter
```
  Create DOOMEternal.exe that can be  used launch Doom Eternal
  The executable can then be used in LGS to detect if Doom Eternal is running
