:: NewCM-Radix: A collection of the New Computer Font for Windows and use
:: with Radical Pie 
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
setlocal enableextensions

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
echo WARNING: This installer may erase font files with identical paths, or other
echo files pretaining to the installation, and will uninstall previous versions of
echo NewCM-Radix. 
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

set "TAB=    "
set "ttfStatus=0"
set "slugStatus=0"
set "desginFilesStatus=2"
set "templateStatus=0"
set "slugDestDir=%localappdata%\RadicalPie"

echo.
echo Setting up NewCM-Radix ------------------------------------------
call :SetupNewCMRadix "%~dp0Fonts\NewCMFontList.txt"
if errorlevel 2 (

    echo Operation cancelled by user choice.
    endlocal & exit /b 0
)

echo.
echo Installing New Computer Modern ttf fonts ------------------------
call :InstallTtfFonts "%~dp0Fonts\Ttf" "%~dp0Fonts\NewCMFontList.txt"
set "ttfStatus=%errorlevel%"

echo.
echo Installing New Computer Modern slug fonts -----------------------
call :InstallAllSlugFonts "%~dp0Fonts\Ttf" "%slugDestDir%"
set "slugStatus=%errorlevel%"

echo.
echo Installing Templates -----------------------
call :InstallTemplates
set "templateStatus=%errorlevel%"

if not %slugStatus%==2 (

    echo.
    echo Installing Design Files -----------------------------------------
    call :InstallDesignFiles
    set "desginFilesSuccess=%errorlevel%"
)

echo.
echo Installation Report ---------------------------------------------
echo.

set "success=0"

if %ttfStatus%==1 (

    echo %TAB%- [Warning]: Some ttf fonts were not installed. Some process may be locking their destination files. 
    echo %TAB%             Restarting your computer and reexecuting this installer may resolve this issue.
    set "success=1"
)

if %slugStatus%==2 (

    echo.
    echo %TAB%- [Warning]: %slugDestDir% or slugfont.exe
    echo %TAB%  do not exist. Radical Pie fonts and design files were not installed. 
    echo %TAB%  This is not an issue if you are not planning to use Radical Pie.
)

if %slugStatus%==1 (

    echo.
    echo %TAB%- [Warning]: Could not install one or more slug fonts for Radical Pie.
    echo %TAB%             This is not an issue if you are not planning to use Radical Pie.
)

if %desginFilesStatus%==1 (

    echo.
    echo %TAB%- [Warning]: Could not install the design Files. You will need to setup the styles manually.
    set "success=1"
    
) else (

    if not %slugStatus%==2 (
    
        echo.
        echo %TAB%- To access the NewCM-Radix desgin from Radical Pie, go to "Settings" - "Load Design from Equation,"
        echo %TAB%  and load any desired design from:
        echo.
        echo %TAB%%TAB%  %appdata%\RadicalPie\DesignFiles
        echo.
        echo %TAB%  Subsequently you can set it as your default design by selecting:
        echo.
        echo %TAB%%TAB%  "Settings" - "Save User Default Design."
    )
)

if %templateStatus% equ 0 (

    echo.
    echo %TAB%- Templates can be accessed in the main MS Word screen - "More Templates" - "Personal".
    
) else (

    echo.
    echo %TAB%- There was an issue installing the document templates.
)

echo.
echo %TAB%- To uninstall the fonts installed by NewCM-Radix, execute the following from a command prompt:
echo.
echo %TAB%%TAB%  %localappdata%\NewCM-Radix\Uninstall.bat
echo.

if %success%==0 (

    echo.
    echo %TAB%- Installation completed successfully.
)

echo.
pause

exit /b 0


:SetupNewCMRadix

setlocal enabledelayedexpansion

set "TAB=    "
set "fontListFile=%~1"
set "newCMRadixLocalAppdata=%localappdata%\NewCM-Radix"
set "newCMRadixUninstallBat=%newCMRadixLocalAppdata%\Uninstall.bat"
    
if exist "%newCMRadixUninstallBat%" (
    
    echo %TAB%- Running uninstall
    call "%newCMRadixUninstallBat%" /y
    
    :: Wait for filesystem to clear Uninstall.bat and the NewCM-Radix folder
    timeout /t 2 /nobreak > nul
)

if not exist "%newCMRadixLocalAppdata%" (

    mkdir %newCMRadixLocalAppdata%
)

echo %TAB%- Setting up the uninstaller

copy /Y "%fontListFile%" "%newCMRadixLocalAppdata%">nul
copy /Y "Develop\Uninstall.bat" "%newCMRadixLocalAppdata%">nul

endlocal & exit /b 0


:InstallTtfFonts

setlocal enabledelayedexpansion

set "fontDir=%~1%
set "fontListFile=%~2"

set "userFontDir=%localappdata%\Microsoft\Windows\Fonts"
set "atLeastOneFailure=0"


if not exist "%fontListFile%" (
    echo !TAB!- [ERROR] Font list file not found: %fontListFile%
    exit /b 1
)

if not exist "%userFontDir%" (
    md "%userFontDir%"
)


for /f "usebackq tokens=1,* delims=," %%A in ("%fontListFile%") do (

    set "fontFile=%%A.ttf"
    set "fontName=%%B"

    set "fontPath=%fontDir%\!fontFile!"

    if not exist "!fontPath!" (

        echo !TAB!- [ERROR] Font file not found: !fontPath!
        set "atLeastOneFailure=1"
        goto :continue

    )

    echo !TAB!Installing "!fontName!" from "!fontFile!"

    reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts" /v "!fontName! (TrueType)" >nul 2>&1
    if !errorlevel! == 0 (

        echo !TAB!!TAB!- Removing old registry entry.
        reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts" /v "!fontName! (TrueType)" /f >nul
    )

    echo !TAB!!TAB!- Copying to user font folder.
    copy /Y "!fontPath!" "%userFontDir%\!fontFile!" >nul
    if errorlevel 1 (

        echo !TAB!!TAB!- [ERROR] Failed to copy font file.
        set "atLeastOneFailure=1"
        goto :continue
    )

    echo !TAB!!TAB!- Registering in user registry "!fontName!" : "%userFontDir%\!fontFile!" .
    reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts" ^
        /v "!fontName! (TrueType)" ^
        /t REG_SZ ^
        /d "%userFontDir%\!fontFile!" ^
        /f >nul
    if errorlevel 1 (

        echo !TAB!!TAB!- [ERROR] Failed to register font.
        set "atLeastOneFailure=1"
        goto :continue
    )

    echo !TAB!!TAB!- Installed: !fontName!

    :continue
    echo.
)

endlocal & exit /b %atLeastOneFailure%



:InstallAllSlugFonts

setlocal enabledelayedexpansion

echo.

set "slugfontExe=C:\Program Files\RadicalPie\slugfont.exe"
set "slugDestDir=%~2"

if not exist "%slugDestDir%" (

    echo !TAB!- [Warning]: %slugDestDir% does not exist; Slug fonts and design files will not be installed.

    endlocal & exit /b 2
)

if not exist "%slugfontExe%" (

    echo !TAB!- [Warning]: %slugfontExe% does not exist; Slug fonts and design files will not be installed.
    
    endlocal & exit /b 2
)

set "tempDir=%temp%\NewCMSlugConverted"

if exist "%tempDir%" (

    rd /S /Q "%tempDir%"
)
md "%tempDir%"

set "ttfDir=%~1"

for %%F in (%ttfDir%\*.ttf) do (

    set "fullPath=%%~fF"
    set "fileName=%%~nF"

    echo !TAB!Processing %%F...
    echo !TAB!!TAB!- Temporary output: "%tempDir%\!fileName!.slug"

    "%slugfontExe%" "!fullPath!" -o "%tempDir%\!fileName!.slug" -contours -math

    if errorlevel 1 (
    
        echo !TAB!!TAB!- ERROR: Failed to process %%F
        
        rd /S /Q "%tempDir%"
        
        endlocal & exit /b 1
        
    ) else (
    
        echo !TAB!!TAB!- Success: !fileName!.slug created
        
    )

    echo.
)

    copy "%tempDir%\*.slug" "%slugDestDir%" /Y >nul
    rd /S /Q "%tempDir%"
    
endlocal & exit /b %errorlevel%


:InstallDesignFiles

setlocal enabledelayedexpansion

echo.

set "dstDir=%appdata%\RadicalPie\DesignFiles"

echo !TAB!- Destination: %dstDir%

if not exist "%dstDir%" (

    mkdir "%dstDir%"
)

copy /Y "Designs\*.pie" "%dstDir%" >nul

endlocal & exit /b %errorlevel%


:InstallTemplates

setlocal enabledelayedexpansion enableextensions

for /f "tokens=2,*" %%A in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Word\Options" /v PersonalTemplates 2^>nul') do (

    call set "personalTemplatesPath=%%B"
)

if not defined personalTemplatesPath (

    echo !TAB!- [Warning]: Personal *templates* path could not be retrieved from registry. Using fallback.

    for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal 2^>nul') do (

        set "personalPath=%%B"
    )

    if not defined personalPath (

        echo !TAB!!TAB!- [Warning]: Personal path could not be retrieved from registry. Using fallback.

        set "personalPath=%userprofile%\Documents"
    )

    call set "personalTemplatesPath=!personalPath!\Custom Office Templates  
    
    echo !TAB!- Setting MS Word Personal Templates path in registry to:
    echo !TAB!  !personalTemplatesPath!
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Word\Options" ^
        /v "PersonalTemplates" ^
        /t REG_SZ ^
        /d "!personalTemplatesPath!" ^
        /f >nul
)

echo !TAB!- Copying .dotx files to the user's template folder:
echo !TAB!- !personalTemplatesPath!

if not exist "!personalTemplatesPath!" (

    md "!personalTemplatesPath!" >nul
)

robocopy "%~dp0Templates" "!personalTemplatesPath!">nul

endlocal & exit /b %errorlevel%