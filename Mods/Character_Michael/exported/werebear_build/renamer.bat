@echo off
setlocal enabledelayedexpansion
for /R "." %%F in (*) do (
    set name=%%~nF%%~xF
    set newname=!name:beaver_=!
    echo !name! !newname!
    ren  !name! !newname!
)
endlocal
