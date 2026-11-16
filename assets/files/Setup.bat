@echo off
title Kyroz Development Menu

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Locate VS Code executable (checks User install, System install, and PATH)
set "CODE_EXE="
set "CODE_CMD="
if exist "%LocalAppData%\Programs\Microsoft VS Code\Code.exe" (
    set "CODE_EXE=%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
    set "CODE_CMD=%LocalAppData%\Programs\Microsoft VS Code\bin\code.cmd"
) else if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" (
    set "CODE_EXE=%ProgramFiles%\Microsoft VS Code\Code.exe"
    set "CODE_CMD=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
) else (
    for /f "delims=" %%i in ('where code 2^>nul') do set "CODE_CMD=%%i"
)

:MENU
cls
echo ====================================================
echo              SETUP HELPER by Kyroz
echo ====================================================
echo.
echo   [1] Install Visual Studio Code
echo   [2] Install Java (OpenJDK 21 + VS Code Debugger)
echo   [3] Install PHP ^& WAMP Server (Complete Setup)
echo   [4] Exit
echo.
echo ====================================================
set "CHOICE="
set /p CHOICE="Enter your choice (1-4): "

if "%CHOICE%"=="1" goto VSCODE
if "%CHOICE%"=="2" goto JAVA
if "%CHOICE%"=="3" goto WAMP
if "%CHOICE%"=="4" goto EXIT
goto MENU

:VSCODE
cls
echo ====================================================
echo              Installing Visual Studio Code
echo ====================================================
echo.
winget install --id Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements

:: Re-check actual Code.exe path after installation
if exist "%LocalAppData%\Programs\Microsoft VS Code\Code.exe" (
    set "CODE_EXE=%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
    set "CODE_CMD=%LocalAppData%\Programs\Microsoft VS Code\bin\code.cmd"
) else if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" (
    set "CODE_EXE=%ProgramFiles%\Microsoft VS Code\Code.exe"
    set "CODE_CMD=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
)

if defined CODE_EXE (
    echo.
    echo Creating Desktop shortcut...
    powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Visual Studio Code.lnk'); $s.TargetPath = '%CODE_EXE%'; $s.Save()"
    echo VS Code installation and Desktop shortcut complete!
) else (
    echo.
    echo [!] Could not locate Code.exe to create a shortcut.
)
pause
goto MENU

:JAVA
cls
echo ====================================================
echo    Installing Java (OpenJDK 21) ^& VS Code Debugger
echo ====================================================
echo.
echo [1/3] Installing Microsoft OpenJDK 21...
winget install --id Microsoft.OpenJDK.21 --silent --accept-package-agreements --accept-source-agreements

if defined CODE_CMD (
    echo.
    echo [2/3] Installing VS Code Java Debugger...
    call "%CODE_CMD%" --install-extension vscjava.vscode-java-debug >nul 2>&1

    echo.
    echo [3/3] Installing Language Support for Java by Red Hat...
    call "%CODE_CMD%" --install-extension redhat.java >nul 2>&1
    echo.
    echo Java JDK and VS Code extensions installed!
) else (
    echo.
    echo [!] VS Code was not found. OpenJDK 21 was installed, but VS Code extensions were skipped.
)
pause
goto MENU

:WAMP
cls
echo ====================================================
echo          Installing WAMP Server ^& Standalone PHP
echo ====================================================
echo.
echo [1/3] Installing Standalone PHP 8.3 (For VS Code Intelephense)...
winget install --id PHP.PHP.8.3 --silent --accept-package-agreements --accept-source-agreements

echo.
echo [2/3] Installing WAMP Server (Apache, MySQL, PHP)...
winget install --id Wampserver.Wampserver --silent --accept-package-agreements --accept-source-agreements

if defined CODE_CMD (
    echo.
    echo [3/3] Installing PHP Intelephense Extension for VS Code...
    call "%CODE_CMD%" --install-extension bmewburn.vscode-intelephense >nul 2>&1
) else (
    echo.
    echo [!] VS Code was not found. Skipping PHP Intelephense extension.
)

echo.
echo Setup Complete!
echo - Launch WAMP Server from the Windows Start Menu.
echo - Place all your PHP lab files inside C:\wamp64\www\
echo - Access them by typing http://localhost/your-file.php in your browser.
pause
goto MENU

:EXIT
exit /b