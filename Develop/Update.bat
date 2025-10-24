:: NewCM-Radix: An installer of the New Computer Font for Windows and use
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

if /i not "%1"=="/n" (

    python Download.py
) else (

    echo Skipping download step due to /n argument.
)

echo.

set "FontForgePath=C:\Program Files (x86)\FontForgeBuilds\" 

if not defined FF_PATH_ADDED (
    
    set "PATH=%FontForgePath%;%FontForgePath%\bin;%PATH:"=%"
    set FF_PATH_ADDED=TRUE
)
for /F "tokens=* USEBACKQ" %%f IN (`dir /b "%FontForgePath%lib\python*"`) do (
set "PYTHONPATH=%FontForgePath%lib\%%f"
)

ffpython Convert.py

exit /b 0 

endlocal & exit /b 0
