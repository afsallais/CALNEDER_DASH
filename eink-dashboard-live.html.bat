@echo off
setlocal EnableDelayedExpansion

rem ===== SETTINGS =====
rem Name of the dashboard file (must be in the SAME folder as this .bat)
set "HTMLFILE=eink-dashboard-live.html"
rem Or use a web address instead (remove "rem " to enable):
rem set "URL=https://your-site.pages.dev"

rem ===== BUILD THE ADDRESS =====
if not defined URL (
  if not exist "%~dp0%HTMLFILE%" (
    echo Could not find "%HTMLFILE%" in:
    echo %~dp0
    echo.
    echo Put this .bat and the html file in the same folder, then try again.
    echo If you use a desktop icon, make it a SHORTCUT to this .bat, not a copy.
    pause
    exit /b 1
  )
  set "URL=file:///%~dp0%HTMLFILE%"
  set "URL=!URL:\=/!"
  set "URL=!URL: =%%20!"
)

rem ===== LEFT-MOST MONITOR POSITION =====
set "PS1=%TEMP%\eink-monitor.ps1"
> "%PS1%" echo Add-Type -AssemblyName System.Windows.Forms
>> "%PS1%" echo $s = [System.Windows.Forms.Screen]::AllScreens ^| Sort-Object { $_.Bounds.X } ^| Select-Object -First 1
>> "%PS1%" echo Write-Output ($s.Bounds.X.ToString() + "," + $s.Bounds.Y.ToString())
set "POS=0,0"
for /f "delims=" %%p in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"') do set "POS=%%p"
del "%PS1%" >nul 2>&1

rem ===== FIND A BROWSER =====
set "PROFILE=%LOCALAPPDATA%\EinkDashboard"
set "CHROME="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

if defined CHROME (
  start "" "!CHROME!" --kiosk "--user-data-dir=%PROFILE%" --window-position=%POS% --no-first-run --disable-session-crashed-bubble --allow-file-access-from-files "!URL!"
  exit /b 0
)

start "" msedge --kiosk "!URL!" --edge-kiosk-type=fullscreen "--user-data-dir=%PROFILE%" --window-position=%POS% --no-first-run
exit /b 0
