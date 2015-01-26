:: Updates newest files from git folder and deletes unexisted files
:: CAPITALIZE COMMANDS WITH FILES OR APP ::
@echo off
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
set gamePath=%steamPath%\SteamApps\common\Don't Starve Together Beta
set modName=Character_Michael
set modPath=%gamePath%\mods\%modName%
echo(
echo Copy files to %modPath%
echo(
XCOPY /s /Y /D /Q Character_Michael "%modPath%"

:: --- checking deleted files ---
setlocal enabledelayedexpansion
for /R "%modPath%" %%F in (*) do (
    set path=%%F
    set file=%modName%!path:%modPath%=!
    set ext=%%~xF
    if !ext! NEQ .zip ( :: NEQ = not equal
        if not exist !file! (
            echo Remove: !file!
            DEL "%%F"
        )
    )
)
endlocal

START steam://rungameid/322330
