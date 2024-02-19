
This script is designed to perform several tasks related to downloading, organizing, and processing shapefiles for geographic information systems (GIS). 
Here's a breakdown of its components and functionalities:

Downloading Shapefiles:
The function DownloadShape takes an ISO country code as input (ISO) and downloads a shapefile from the GADM database corresponding to that country.
It saves the zip file to a specified location (C:/CCAFSToolkit/CRAFT_Schema/), extracts its contents, and then deletes the zip file to clean up. 
This process requires an active internet connection.

Organizing Shapefiles by Level:
The function CreateLevel organizes the shapefiles into folders based on their "Level." 
Levels are determined by the last character of the shapefile's name, indicating its administrative division level. 
The function supports multiple file extensions and ensures files are moved to the appropriate "Level" folder within the source directory.

Processing Shapefiles for CRAFT Schema:
The function ShapeProcessing performs further processing on the shapefiles,
including renaming, removing unnecessary columns, and writing the processed shapefiles to new directories based on their levels.
It uses the sf package to handle spatial data and ensures that the output is compatible with the needs of the CRAFT schema.

Cleaning Up:
The function DeleteOldFolder deletes specific folders (e.g., "Level4", "Level5", "Level6") from the source directory, 
typically used for cleanup purposes after reorganizing shapefiles.

The function DeleteOldFiles deletes old shapefiles from the "Level1", "Level2", and "Level3" folders based on specified file extensions. 
This is useful for ensuring that only the latest, processed files are kept.

Overall, this script streamlines the process of managing geographic data for users needing to download, 
organize, and process shapefiles for GIS applications, specifically tailored for use within the CRAFT schema context.
 Users should have R and necessary packages (e.g., utils, sf) installed