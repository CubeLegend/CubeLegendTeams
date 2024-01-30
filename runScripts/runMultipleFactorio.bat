@echo off
setlocal enabledelayedexpansion

REM Validate command line parameters
if "%1"=="" (
    echo Usage: %0 "number-of-instances"
    exit /b 1
)

REM Set the number of instances
set "instances=%1"

REM Set config file path in the script directory
set "configFile=%~dp0config.txt"

REM Check if config file exists
if not exist "!configFile!" (
    echo Configuration file not found. A new configuration file will be generated.
    
    REM Prompt user for a common Mods directory path
    set /p "modsDirectory=Enter Common Mods directory path: "
    
    REM Create config file with the common Mods directory path
    (
        echo ModsDirectoryPath=!modsDirectory!
    ) > "!configFile!"
)

REM Read Mods directory path and FactorioExecutablePaths from the config file
for /f "tokens=1,* delims==" %%a in ('type "!configFile!"') do (
    if /i "%%a"=="ModsDirectoryPath" (
        set "modsDirectory=%%b"
        echo !modsDirectory!
    )

    for /L %%j in (1, 1, %instances%) do (
        if /i "%%a"=="FactorioExecutablePath%%j" (
            set "factorioExecutablePath[%%j]=%%b"
        )
    )
)

REM Validate the common Mods directory path
if not exist "!modsDirectory!" (
    echo Common Mods directory not found: "!modsDirectory!".
    exit /b 1
)

REM Run Factorio for each instance
for /L %%i in (1, 1, %instances%) do (
    echo !factorioExecutablePath[%%i]!
    echo !modsDirectory!
    start "" !factorioExecutablePath[%%i]! --mod-directory=%modsDirectory% 
)

endlocal
exit /b 0
