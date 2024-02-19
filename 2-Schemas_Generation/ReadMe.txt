
Schema Generation Script


This script automates the process of generating geographic schemas based on shapefiles for different administrative levels.
Utilizing a suite of R libraries including sp, raster, rgeos, rgdal, and sf, it performs spatial operations to create detailed schema mappings. 
This README outlines the purpose, prerequisites, and usage instructions for the script.

Prerequisites
	R Programming Language
	R Libraries: sp, raster, rgeos, rgdal, sf
	Installation command: install.packages(c("sp", "raster", "rgeos", "rgdal", "sf"))

Script Features
	- Multi-Level Processing: Capable of handling shapefiles across different administrative levels.
	- Automatic Schema Generation: Generates schemas that include cell IDs and their corresponding percentage shares within the geographic boundaries.
	- Spatial Operations: Performs cropping, overlay, and area calculation operations on spatial data.
	- Output Customization: Saves the generated schemas to text files, organized by administrative levels and geographic names.

Configure Script Parameters:
	- source_folder: Specify the absolute path to the directory containing the shapefiles organized by administrative levels.

Output:
	- Schema files are saved in the Schema subdirectory within each level's folder, named according to the geographic area they represent.
	- A summary CSV file (SchemaGenerationDetails.csv) is generated, detailing the number of schemas created per level.

Considerations
	- Ensure your shapefiles are correctly projected (WGS84) and organized by administrative levels before running the script.
	- The script is designed for flexibility and can be modified to accommodate different spatial resolutions or administrative structures.