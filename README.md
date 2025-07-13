# CORSAIR iCUE and Logitech LGS detection for GamePass games
Powershell script to create a Game Pass game  launcher that can be used to detect if game is running in iCUE and LGS (an similar tools)

## Usage:
```
./CreateExe.ps1 <part of game name>
```
### LGS
When creating LGS profile you need to select the "Lock profile while game is running" -option.


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
  The executable can then be used to launch game pass Doom Eternal and and detect if Doom Eternal is running
