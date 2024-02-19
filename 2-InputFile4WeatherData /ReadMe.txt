
This R script is designed to process geographic data, focusing on the intersection of shapefiles with a specified grid (fishnet) and the extraction of 
relevant geographic coordinates.


Features:
	- Reads shapefiles from a specified source directory.
	- Projects shapefiles to a standard geographic projection (WGS84).
	- Creates a global raster grid at a resolution of 5 arc-minutes.
	- Intersects the fishnet with the target shapefile to identify relevant grid cells.
	- Extracts and saves the latitude and longitude coordinates of the intersected grid cells.


Requirements:
	- R (version 3.6.0 or higher recommended)
	- R packages:
		raster: For creating and manipulating raster data.
		rgdal: For reading and writing shapefiles and other spatial data formats.
		sp: For handling spatial data.

Input: Use the path of CRAFT_Scheam(source_folder <- "C:/CCAFSToolkit/CRAFT_Schema/")