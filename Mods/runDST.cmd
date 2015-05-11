:: Updates newest files from git folder and deletes unexisted files
:: CAPITALIZE COMMANDS WITH FILES OR APP ::
@echo off
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
set gamePath=%steamPath%\SteamApps\common\Don't Starve Together Beta
set modName=Character_Michael
set modPath=%gamePath%\mods\%modName%

:: --- checking deleted files ---
setlocal enabledelayedexpansion
for /R "%modPath%" %%F in (*) do (
    set path=%%F
    set file=%modName%!path:%modPath%=!
    set ext=%%~xF
    set /a deleted=0
    :: NEQ = not equal
    if !ext! NEQ .zip (
        if not exist !file! (
            echo Remove: !file!
            set /a deleted=deleted+1
            DEL "%%F"
        )
    )
)
if !deleted! NEQ 0 echo Deleted !deleted! files
endlocal

:: --- copy files from project folder to game ---
echo(
echo Copy files to %modPath%
echo(
XCOPY /s /Y /D /Q Character_Michael "%modPath%"

:: --- Force start ---
set modsettingsFile=%gamePath%\mods\modsettings.lua
set enableStr=ForceEnableMod('%modName%')
FINDSTR %enableStr% "%modsettingsFile%" 2>&1
if errorlevel 1 (
    echo Enable force start!
    ECHO %enableStr% >> "%modsettingsFile%"
)

START "" steam://rungameid/322330
