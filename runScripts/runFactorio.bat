@echo off
setlocal enableDelayedExpansion

REM Check if config file exists
set "configFile=%~dp0config.txt"
if not exist "%configFile%" (
    echo Configuration file not found. A new configuration file will be generated.

    REM Prompt user for Factorio executable path
    set /p "factorioExecutable=Enter Factorio executable path: "

    REM Prompt user for mods directory path
    set /p "modsDirectory=Enter Mods directory path: "

    REM Create config file with provided paths
    echo FactorioExecutablePath=!factorioExecutable! >> "%configFile%"
    echo ModsDirectoryPath=!modsDirectory! >> "%configFile%"
)

REM Read Factorio executable and mods directory paths from config file
for /f "tokens=1,* delims==" %%a in ('type "%configFile%"') do (
    if /i "%%a"=="FactorioExecutablePath" set "factorioExecutable=%%b"
    if /i "%%a"=="ModsDirectoryPath" set "modsDirectory=%%b"
)

REM Check if Factorio executable path is provided
if not defined factorioExecutable (
    echo Factorio executable path not found in the config.txt file.
    exit /b 1
)

REM Remove quotes if they exist
set factorioExecutable=%factorioExecutable:"=%
set modsDirectory=%modsDirectory:"=%

REM Check if Factorio executable exists
if not exist "%factorioExecutable%" (
    echo Factorio exectable not found. Please update the path in the config.txt file.
    exit /b 1
)

REM Check if mods directory path is provided
if not defined modsDirectory (
    echo Mods directory path not found in the config.txt file.
    exit /b 1
)

REM Check if mods directory exists
if not exist "%modsDirectory%" (
    echo Mods directory not found. Please update the path in the config.txt file.
    exit /b 1
)

REM Run Factorio with mods directory parameter
"%factorioExecutable%" --mod-directory "%modsDirectory%"

endlocal
