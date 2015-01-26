@echo off
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
for /f "tokens=2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam /v InstallPath 2^>nul') do set steamPath=%%B
set gamePath=%steamPath%\SteamApps\common\Don't Starve Together Beta
set modPath=%gamePath%\mods\Character_Michael
echo(
echo Copy files to %modPath%
echo(
xcopy /s /Y /D /Q Character_Michael "%modPath%"
:: checking deleted files
for /R %%f in (%modPath%\*) do @echo %%f

start steam://rungameid/322330
