
SPAM Data Processing Script

Description:
	- This script is designed to process geospatial data, specifically to generate grid shapefiles based on specific shape files and
	  to extract crop mask data from GeoTIFF raster files. The script performs the following operations:
		- Generation of grid shapefiles if they do not already exist for a given region.
		- Extraction and summation of raster values for each polygon in the grid shapefile, corresponding to crop mask data.

Prerequisites:
	- R and R packages such as raster, sf, rgdal, and sp.
	- Specific input data, including GeoTIFF raster files for crops and a folder containing the necessary shape files.
	- Write access to the specified directories for the output of processed data.

Inputs:
	- Crop: The full path to the GeoTIFF raster file representing specific crop data.
	- source_folder: The path of the folder containing the necessary shape files for grid generation.

Outputs:
	- Grid shapefiles (Shape.shp) for specific regions, if they do not already exist.
	- Text files containing extracted crop mask data (crop*.txt), with summed values for each grid cell.

Usage: The script is structured around three main functions:
	- Grid_shape(source_folder): Generates a grid shapefile for a given region from the provided shape files.
	- Name(Crop): Extracts a meaningful name from the path of a crop GeoTIFF raster file.
	- SpamData_Data(rname, Crop, source_folder): Coordinates the overall process, including checking for the existence of grid shapefiles, 
	  generating grid files if necessary, and extracting/summing crop mask data.



Example of function call
r

Crop = "path/to/file/spam2020_v0r1_global_A_WHEA_R.tif"
source_folder = "path/to/shape/files"
rname = "RegionName"

SpamData_Data(rname, Crop, source_folder)