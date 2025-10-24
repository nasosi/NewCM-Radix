import requests
import os

import FontSpecification

def DownloadNewCM( fontSpecificationList ):

    destDir = "../Fonts/Otf"
    os.makedirs(destDir, exist_ok=True)

    for fontSpecification in fontSpecificationList:

        fontfileName = fontSpecification[0] + ".otf"

        fontfileUrl = FontSpecification.baseUrl + fontfileName;

        fontFilePath = os.path.join( destDir, fontfileName )

        try:

            response = requests.get( fontfileUrl )
            response.raise_for_status( ); 

            with open(fontFilePath, 'wb') as f:

                f.write(response.content)

            print(f"Downloaded: {fontfileName}")

        except requests.HTTPError as e:

            print(f"Failed to download {fontfileName}: {e}")

DownloadNewCM( FontSpecification.specification )