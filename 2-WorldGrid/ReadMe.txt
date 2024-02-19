
WorldGrid Shapefile Generation
	This concise guide covers the use of the WorldGrid function, designed to generate a grid overlay 
	on a specified shapefile and save the resulting grid as a new shapefile. 
	This function is particularly useful for geographical analyses that require dividing a region into a uniform grid for sampling or data collection purposes.


Features:
	- Projects input shapefiles to WGS84 projection.
	- Creates a 5 arc-minute resolution grid covering the extent of the input shapefile.
	- Calculates centroids for each grid cell.
	- Saves the resulting grid as a shapefile with latitude and longitude attributes for each grid cell.

Prerequisites
	R (version 3.6.0 or newer recommended).
	R packages: raster, rgdal, sp


Input: "C:/CCAFSToolkit/CRAFT_Schema/



Output:
	- The grid is saved as a shapefile in C:/CCAFSToolkit/WorldGridData/ with the filename "WorldGrid.shp". 
	- It includes attributes for each grid cell's centroid latitude and longitude.