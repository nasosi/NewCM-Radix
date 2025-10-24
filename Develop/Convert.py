# NewCM-Radix: An installer of the New Computer Font for Windows and use
# with Radical Pie 
# Copyright (C) 2025 Athanasios Iliopoulos

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# Fonts included in this installer are licensed under Gust Font License.
# See http://tug.org/fonts/licenses/GUST-FONT-LICENSE.txt


import fontforge
import os

import FontSpecification

inputFolder = os.path.join("..", "Fonts", "Otf")
outputFolder = os.path.join("..", "Fonts", "Ttf")
scriptFolder = os.path.dirname(os.path.abspath(__file__))
listFilePath = os.path.join(scriptFolder, "..", "Fonts", "NewCMFontList.txt")

def GetStyleName(weight, style):
    weightLower = weight.lower()
    styleLower = style.lower()

    if weightLower == "bold":
        if "italic" in styleLower:
            return "Bold Italic"
        if "oblique" in styleLower:
            return "Bold Oblique"
        return "Bold"

    if weightLower == "book":
        if "italic" in styleLower:
            return "Book Italic"
        if "oblique" in styleLower:
            return "Book Oblique"
        return "Book"

    if "italic" in styleLower:
        return "Italic"
    if "oblique" in styleLower:
        return "Oblique"

    return "Regular"

def OtfToTtf(specification):
    inputFolder = os.path.join("..", "Fonts", "Otf")
    outputFolder = os.path.join("..", "Fonts", "Ttf")
    os.makedirs(outputFolder, exist_ok=True)

    first = True

    with open(listFilePath, "w", encoding="utf-8") as listFile:

        for entry in specification:
            psName, familyName, styleDesc, weight, fullName, pfmFamily, italicAngle, stylemap = entry

            otfPath = os.path.join(inputFolder, psName + ".otf")
            ttfPath = os.path.join(outputFolder, psName + ".ttf")

            if not os.path.exists(otfPath):

                print(f"Missing OTF: {otfPath}")
                continue


            print(f"Processing {psName}.otf → .ttf")

            font = fontforge.open(otfPath)

            # Basic font names
            font.familyname = familyName
            font.fullname = fullName
            font.fontname = psName
            font.weight = weight

            # SFNT name entries
            font.appendSFNTName("English (US)", "Preferred Family", familyName)
            font.appendSFNTName("English (US)", "Preferred Styles", styleDesc)
            font.appendSFNTName("English (US)", "Compatible Full", fullName)
            font.appendSFNTName("English (US)", "SubFamily", GetStyleName(weight, styleDesc))
            font.appendSFNTName("English (US)", "WWS Family", familyName)
            font.appendSFNTName("English (US)", "WWS Subfamily", styleDesc)

            italicAngleFloat = float(italicAngle)
            if abs(italicAngleFloat) < 90:

                font.italicangle = italicAngleFloat


            font.os2_stylemap  = int(stylemap)

            font.generate(ttfPath)
            font.close()

            if (not first):

                listFile.write( "\n" )

            else:

                first = False

            listFile.write(f"{psName},{fullName}")

    print("All fonts processed successfully.")



def RemapGlyphRange(srcFont, dstFont, sourceStart, targetStart, glyphCount):

    remapped = 0
    for i in range(glyphCount):
    
        srcCode = sourceStart + i
        dstCode = targetStart + i
        if srcCode in srcFont:
        
            print(f"Remapping U+{srcCode:04X} -> U+{dstCode:04X}")
            srcFont.selection.none()
            srcFont.selection.select(srcCode)
            srcFont.copy()

            dstFont.createChar(dstCode)
            dstFont.selection.none()
            dstFont.selection.select(dstCode)
            dstFont.paste()
            remapped += 1
            
        else:
        
            print(f"Skipping missing glyph U+{srcCode:04X}")
            
            
    return remapped


def RemapGreek(inputFontPath, outputDir, psFamily, fontStyle):



    srcFont = fontforge.open(inputFontPath)

    newFont = fontforge.font()
    newFont.encoding = 'UnicodeFull'
    newFont.fontname = psFamily + "-" + fontStyle
    newFont.familyname = "New Computer Modern Math Radical Pie Greek"
    newFont.fullname = "New Computer Modern Math Radical Pie Greek " + fontStyle
    newFont.em = srcFont.em

    outputFontPath = os.path.join(outputDir, newFont.fontname) + ".ttf"

    numRemapped = 0
    numRemapped += RemapGlyphRange(srcFont, newFont, 0x1D6E2, 0x0391, 17)
    numRemapped += RemapGlyphRange(srcFont, newFont, 0x1D6F4, 0x03A3, 7)
    numRemapped += RemapGlyphRange(srcFont, newFont, 0x1D6FC, 0x03B1, 25)


    copyrightText = " Copyright (C) 2025-Athanasios Iliopoulos. This work is released under the GUST Font License -- see http://tug.org/fonts/licenses/GUST-FONT-LICENSE.txt for details.";
    newNames = []
    foundCopyright = False
    for lang, nameId, value in newFont.sfnt_names:
    
        if nameId == "Copyright" and lang == "English (US)":
        
            newNames.append(("English (US)", "Copyright", copyrightText))
            foundCopyright = True
            
        else:
        
            newNames.append((lang, nameId, value))

    if not foundCopyright:
    
        newNames.append(("English (US)", "Copyright", copyrightText))
        
    newFont.sfnt_names = tuple(newNames)
    
    if numRemapped > 0:
    
        newFont.generate(outputFontPath)
        print(f"\nNew font with {numRemapped} remapped glyph(s) saved to: {outputFontPath}")
        
    else:
    
        print("\nNo glyphs were remapped. Output font not saved.")

    with open(listFilePath, "a", encoding="utf-8") as listFile:

        listFile.write(f"\n{newFont.fontname},{newFont.fullname}")

    srcFont.close()
    newFont.close()

# Main execution

OtfToTtf( FontSpecification.specification );


RemapGreek("../Fonts/Otf/NewCMMath-Book.otf", "../Fonts/Ttf", "NewCMMath-RadicalPieGreek", "Book")
RemapGreek("../Fonts/Otf/NewCMMath-Bold.otf", "../Fonts/Ttf", "NewCMMath-RadicalPieGreek", "Bold")