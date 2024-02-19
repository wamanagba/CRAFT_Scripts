

The tool is specifically tailored to generate area for each grid cells from shapefiles at the administrative level1, calculate area,
and attach relevant attributes including centroid coordinates, elevation, and land use.

Features:
	- Processes shapefiles to generate schema files 
	- Calculates the area for each polygon within the shapefiles.
	- Attaches centroid coordinates, default elevation, and land use information to each polygon.
	- Supports shapefiles located within nested directory structures.
	- Provides execution time for the schema generation process.

Prerequisites
Before running the script, ensure you have the following:
		R environment 
		Required R packages: raster, rgdal, sp, sf. Install them using R's package manager.
		Your shapefiles organized in the expected directory structure ([source_folder]/Level[i]/Shape/).