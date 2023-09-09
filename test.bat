@echo off
rem the section below makes the GITHUB_WORKSPACE variable consistent if the
rem batch file is run in github actions or manually run from the directory
rem set the variable if it is not already set
if "%GITHUB_WORKSPACE%"=="" set "GITHUB_WORKSPACE=%~dp0"
rem strip trailing backslash from path
if "%GITHUB_WORKSPACE:~-1%"=="\" set "GITHUB_WORKSPACE=%GITHUB_WORKSPACE:~0,-1%"
cd "%GITHUB_WORKSPACE%"

rem change underscores to spaces and set the window title
set "window_title=%~n0"
set "window_title=%window_title:_= %"
title %window_title%

if not defined Platform (
    rem can be x64 or x86
    if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
        set "Platform=x64"
    ) else (
        set "Platform=x86"
    )
)

set "php_ver=8.2.10"
set "php_dir=php"
set "php_zip=php-%php_ver%-Win32-vs16-%Platform%.zip"
set "php_url=https://windows.php.net/downloads/releases/%php_zip%"

rem check if php is available
where php>nul 2>&1
if %errorlevel% NEQ 0 (
    call :setup
)
if "%~1"=="setup" (
    rem
) else if "%~1"=="batch" (
    call :test_batch
) else if "%~1"=="php" (
    call :test_php
) else (
    call :test_batch
    call :test_php
)

title Done
echo.Done.
rem GITHUB_ACTIONS - Always set to true when GitHub Actions is running the
rem workflow. You can use this variable to differentiate when
rem tests are being run locally or by GitHub Actions.
if /I not "%GITHUB_ACTIONS%"=="true" (
    rem don't pause if running under CI
    pause
)
@exit

:setup
if not exist "%GITHUB_WORKSPACE%\%php_dir%" (
    mkdir "%GITHUB_WORKSPACE%\%php_dir%"
)
if not exist "%GITHUB_WORKSPACE%\%php_dir%\%php_zip%" (
    curl -L -o "%GITHUB_WORKSPACE%\%php_dir%\%php_zip%" "%php_url%"
)
if not exist "%GITHUB_WORKSPACE%\%php_dir%\php.ini" (
    pushd "%GITHUB_WORKSPACE%\%php_dir%"
    tar -xf "%GITHUB_WORKSPACE%\%php_dir%\%php_zip%"
    copy /y /b "php.ini-production" "php.ini"
    popd
)
set "path=%GITHUB_WORKSPACE%\%php_dir%;%path%"
goto:eof

:test_batch
rem Run as batch and check return code:
echo|set /p="Batch output: "
call bggp.bat
echo.Return code:  %errorlevel%
echo.
rem Check that the file "4" was created:
dir bggp.bat,4
rem Get sha256:
powershell -Command "Get-FileHash bggp.bat;Get-FileHash 4"
rem Remove the file "4" at end of run:
del 4
goto:eof

:test_php
rem Run as php and check return code:
echo|set /p="PHP output:   "
php -r "ob_start();include 'bggp.bat';"
echo.Return code:  %errorlevel%
echo.
rem Check that the file "4" was created:
dir bggp.bat,4
rem Get sha256:
powershell -Command "Get-FileHash bggp.bat;Get-FileHash 4"
rem Remove the file "4" when done:
del 4
goto:eof
