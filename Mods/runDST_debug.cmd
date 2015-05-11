:: Updates newest files from git folder and deletes unexisted files
:: CAPITALIZE COMMANDS WITH FILES OR APP ::
@echo off
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
:: -- ?
echo Steam path: %steamPath%
set gamePath=%steamPath%\SteamApps\common\Don't Starve Together Beta
:: -- ?
echo Game path: %gamePath%
set modName=Character_Michael
set modPath=%gamePath%\mods\%modName%
echo Mod path: %modPath%
pause

:: --- checking deleted files ---
setlocal enabledelayedexpansion
set /a files=0
set /a deleted=0
for /R "%modPath%" %%F in (*) do (
    set path=%%F
    set file=%modName%!path:%modPath%=!
    set ext=%%~xF
    set /a files=files+1
    :: echo file: !file! [!ext!]
    :: ext = extension
    :: NEQ = not equal
    if !ext! NEQ .zip (
        if not exist !file! (
            echo Remove: !file!
            set /a deleted=deleted+1
            pause
            DEL "%%F"
        )
    )
)
echo Total: !files! files
echo Deleted !deleted! files
endlocal
pause

:: --- copy files from project folder to game ---
echo(
echo Copy files to %modPath%
echo(
XCOPY /s /Y /D /Q Character_Michael "%modPath%"
echo Copied!
pause

:: --- Force start ---
set modsettingsFile=%gamePath%\mods\modsettings.lua
set enableStr=ForceEnableMod('%modName%')
FINDSTR %enableStr% "%modsettingsFile%" 2>&1
if errorlevel 1 (
    echo Enable force start!
    ECHO %enableStr% >> "%modsettingsFile%"
)

pause
START "" steam://rungameid/322330
:: -- ?
echo Game started (322330)
pause
