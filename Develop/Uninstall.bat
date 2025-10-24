:: NewCM-Radix: A collection of the New Computer Font for Windows and use
:: with Radical Pie.
:: Copyright (C) 2025 Athanasios Iliopoulos

:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.

:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.

:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <https://www.gnu.org/licenses/>.
:: Fonts included in this installer are licensed under Gust Font License.
:: See http://tug.org/fonts/licenses/GUST-FONT-LICENSE.txt


@echo off
setlocal enabledelayedexpansion enableextensions

set "TAB=    "

if /i "%1"=="/y" (

    goto :Proceed
) 

echo.
echo NewCM-Radix v0.8.0: A collection of the New Computer Font for Windows and use with Radical Pie 
echo ----------------------------------------------------------------------------------------------
echo.
echo This program is distributed in the hope that it will be useful,
echo but WITHOUT ANY WARRANTY; without even the implied warranty of
echo MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
echo GNU General Public License for more details.
echo.
echo You should have received a copy of the GNU General Public License
echo along with this program. If not, see https://www.gnu.org/licenses/.
echo Fonts included in this installer are licensed under Gust Font License.
echo See http://tug.org/fonts/licenses/GUST-FONT-LICENSE.txt
echo.
echo.
echo WARNING: This uninstaller may erase files pretaining to NewCM-Radix that have been modified 
echo          by you or are in use by you. Some of these files include the New Computer Modern 
echo          fonts from the user font folder.
echo.

:AskConfirm

set /p "userChoice=Do you want to continue? (y/n): "

if /i "%userChoice%"=="n" (

        echo Operation cancelled by user choice.
        endlocal & exit /b 0
        
) else if /i not "%userChoice%"=="y" (

    echo Please type y or n.
    goto AskConfirm
)

:Proceed

set "thisFolder=%~dp0"
set "fontListFile=%~dp0NewCMFontList.txt"
set "userFontDir=%localappdata%\Microsoft\Windows\Fonts"
set "atLeastOneFailure=0"
set "slugDir=%localappdata%\RadicalPie"
set "thisFile=%~dp0Uninstall.bat"
set "designFilesDir=%appdata%\RadicalPie\DesignFiles"
set "userTemplateDir=%appdata%\Microsoft\Templates"

for /f "usebackq tokens=1,* delims=," %%A in ("!fontListFile!") do (

    set "ttfFile=%%A.ttf"
    set slugFile=%%A.slug"
    set "fontName=%%B"

    echo !TAB!Uninstalling "!ttfFile!"

    reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts" /v "!fontName! (TrueType)" >nul 2>&1
    if !errorlevel! == 0 (

        echo !TAB!!TAB!- Removing old registry entry.
        reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts" /v "!fontName! (TrueType)" /f >nul
    )

    echo !TAB!!TAB!- Deleting file from user font folder.
    del "!userFontDir!\!ttfFile!" >nul
    if errorlevel 1 (

        echo !TAB!!TAB!- [ERROR] Failed to delete ttf font file.
        set "atLeastOneFailure=1"
        goto :continue
    )
    
    if exist "!slugDir!\!slugFile!" (
    
        del "!slugDir!\!slugFile!" >nul
        if errorlevel 1 (

            echo !TAB!!TAB!- [ERROR] Failed to delete slug font file.
            set "atLeastOneFailure=1"
            goto :continue
        )
    )
    
    echo !TAB!!TAB!- Processed: !fontName!

    :continue
    echo.
)


for /f "tokens=2,*" %%A in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Word\Options" /v PersonalTemplates 2^>nul') do (

    set "personalTemplatesPath=%%B"
)

if not defined personalTemplatesPath (

    echo !TAB!- [Warning]: Personal *templates* path could not be retrieved from registry. Any installed NewCM-Radix templates will not be removed.
    
) else (

    if exist "%personalTemplatesPath%\NewCM-Radix-Minimal.dotx" (

        del /f "!personalTemplatesPath!\NewCM-Radix-Minimal.dotx"
    ) 
)

if !atLeastOneFailure!==0 (

    echo !TAB!- NewCM-Radix uninstall succesfull.
    
) else (

    echo !TAB!- At least one font failed to properly uninstall.
)

del /f !fontListFile!>nul

if /i not "%1"=="/y" (

    pause

) 

start /b "" cmd /c "del /f %~f0>nul & robocopy %~dp0 %~dp0 /s /move>nul & endlocal & exit /b 0"