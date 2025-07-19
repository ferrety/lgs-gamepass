# Game Pass game detection for Logitec LGS and Corsair iCUE
Powershell script to create a Game Pass game launcher that can be used to detect if game is running in iCUE and LGS (an similar tools)

## Usage
Use `CreateExe.ps1`to to create game specific launcher or generic one..


### Create  create launcher 


1. Create Game Pass game launcher to launchers -directory
```
./CreateExe.ps1 <part of game name>
```
2. Add launcher executable in LGS (or iCUE) to detect when game
3. Launch the game using the launhcer executable


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

## Parameters

### Required Parameters
- **Search** - Part of the game name to search for (e.g., "doom", "mechwarrior", "clans")

### Optional Parameters
- **-ac, -Autoclose** - Enable autoclose functionality in the generated launcher
- **-m, -Monitor** - Create a monitoring launcher instead of a regular launcher
- **-NoExe** - Only create the PowerShell script, don't compile to executable
- **-y** - Skip confirmation prompt and proceed automatically
- **-InitWait** - Initial wait time in seconds before starting (default: 30.0)
- **-Wait** - Wait time between checks in seconds (default: 1.0)
- **-Template** - Specify custom template file (default: "LauncherTemplate.ps1")
- **-Name** - Override the display name for the launcher
- **-OutputDir** - Specify output directory for generated files (default: current directory)
- **-Title** - Add additional title/alias to the game detection titles list
- **-w, -Wide** - Enable additional detection methods (can be slow)

### Examples
```powershell
# Basic usage - create launcher with confirmation
.\CreateExe.ps1 "doom"

# Create autoclose launcher without confirmation
.\CreateExe.ps1 "mechwarrior" -ac -y

# Create monitoring launcher with custom wait times
.\CreateExe.ps1 "clans" -m -InitWait 10 -Wait 0.5

# Create only PowerShell script, no executable
.\CreateExe.ps1 "nomans" -NoExe

# Use custom name for the launcher
.\CreateExe.ps1 "xbox" -Name "Xbox Game Bar"

# Create files in a specific output directory
.\CreateExe.ps1 "clans" -ac -y -OutputDir "C:\GameLaunchers"

# Add custom title/alias for better game detection
.\CreateExe.ps1 "clans" -ac -y -Title "MW5 Clans" -Title "MechWarrior Clans"

# Enable wide detection mode for better window title matching
.\CreateExe.ps1 "doom" -ac -y -w

# Use only executable pattern matching (fastest detection)
.\CreateExe.ps1 "GameLaunchHelper" -ac -y -e -Name "MechWarrior5"
```

## Compatibility
- **PowerShell 5.1** (Windows PowerShell) - Native support

# Launcher

## Launcher Functionality
The generated launcher can operate in two modes:

### Launch Mode (default)
- Executes the game launch command
- Waits for the game process to start
- Monitors the game process until it exits
- Automatically closes or waits for user input

### Monitor Mode (-m parameter)
- Does not launch the game
- Only monitors for existing game processes
- Useful for games already running or launched externally


## Parameters

### Parameters
- **`exe`** - Use executable name for GamePass detection, skips other detection methods


### CreateExe Parameters
Followign CreateExe.ps1 paramters are mirrored in the launcher and can be overidden 

- **-ac, -Autoclose** - Enable autoclose functionality in the launcher
- **-m, -Monitor** - Run a monitoring launcher instead of a regular launcher
- **-InitWait** - Initial wait time in seconds before starting (default: 30.0)
- **-Wait** - Wait time between checks in seconds (default: 1.0)
- **-w, -Wide** - Enable additional detection methods (can be slow)

## Process Detection Methods
1. **Exact executable name** - When `-exe` parameter is provided
2. **Window title matching** - When `-wide` parameter is used (matches against window titles)
3. **Process name/path matching** - Default method (matches process names and paths against Titles)

## Custom Template
You can create custom launcher templates by:
1. Copying `LauncherTemplate.ps1` to a new file
2. Modifying the logic as needed
3. Using the `-Template` parameter to specify your custom template

```powershell
# Use custom template
.\CreateExe.ps1 "doom" -Template "MyCustomTemplate.ps1"
```
