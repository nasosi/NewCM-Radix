# NewCM-Radix

NewCM-Radix is a collection of the New Computer Modern font for Windows(R) and use with Radical Pie™.

## Quick Installation

If you have Windows version 10 1803 or later you can install easily with:
1. Open a Command Prompt
2. Execute the following command:
```
(if exist "%temp%\NewCMRadixInst" rmdir /s /q "%temp%\NewCMRadixInst") && md "%temp%\NewCMRadixInst" && curl -L -o "%temp%\NewCMRadixInst\main.zip" "https://github.com/nasosi/NewCM-Radix/archive/refs/heads/main.zip" && powershell -Command "Expand-Archive -Path '%temp%\NewCMRadixInst\main.zip' -DestinationPath '%temp%\NewCMRadixInst' -Force" && cd /d "%temp%\NewCMRadixInst\NewCM-Radix-main" && call Install.bat && cd /d "%temp%" && rmdir /s /q "%temp%\NewCMRadixInst"
```

## Regular Installation
1. Download the repository and extract the .zip file.
2. Inside the extracted folder, double click "Install" (or "Install.bat" depending on your configuration).
3. Inspect the report for any potential issues.
4. Delete the zip file and the folder you created.

Alternative to step 2, you can open a command prompt and execute Install.bat in the extracted folder.

## Description of the project

I started developing NewCM-Radix to enable use of the New Computer Modern for Radical Pie™ equation editor and Word. I soon realized that the document look can be greatly improved if it was using the same fonts for both the text and the equations. I made NewCM-Radix to allow for setting up this configuration easily.

The software comes with an installer and an uninstaller. To uninstall execute the following in a Command Prompt:
```
%localappdata%\NewCM-Radix\Uninstall.bat
```

The NewCM-Radix installer performs the following actions:
1. Installs a subset of the New Computer Modern fonts into the user fonts folder: ```%localappdata%\Microsoft\Windows\Fonts```.
2. Updates the user registry such that Windows programs can recognize the fonts.
3. Installs .slug fonts for use by Radical Pie into ```%localappdata%\RadicalPie```.
4. Installs Radical Pie design files into ```%appdata%\RadicalPie\DesignFiles```.
5. Installs Word templates into the user's  ```PersonalTemplates``` templates path. You may have set this path in Word from the Menu item sequency: File->Options->Save [Default personal templates location]. If not NewCM-Radix will set it to the default.

The uninstaller will remove all items above except the items in 4.

## Examples
Examples can be found in : xxxxxxxxxxxxxxxx

## License
The software comes with two different licenses, one for the scripts and code and one for the Fonts. Please refer to the respective files and folders for details.


