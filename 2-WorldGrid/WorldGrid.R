

WorldGrid = function(fileloc){
  j=1
  i=1
  ##make projection of Shape file as defaulted projection in r
  projs <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
  ## define cellid for the whole world in 5 arc-min
  rwrd <- raster(res = 1/12) 
  ## equals to 
  ## rwrd <- raster(res = 5/60)
  rwrd[] <- 1:ncell(rwrd)
  
  ## set working directory here for the level 1
  setwd(paste0(fileloc, "/Level", i))
  ## read the shp file
  tmp <- shapefile(paste0("shape/",list.files(path = "Shape/", pattern = "*.shp$")))
  ## spatial projection
  tmp <- spTransform(tmp, CRSobj = projs)
  ## attribute of level names, here by the define of sname, we can select shp in just one district
  sname <- paste0("Level",1:i,"Name")
  
  ## return name of the attribute
  rname <- tmp@data[j,sname[i]]
  ## return of name ahead of the selected level, this is used to name the result and write it out
  tname <- tmp@data[j, sname[1:(i - 1)]]
  tname <- paste(tname,collapse = "_")
  if (i == 1) { tname <- NULL}
  ## select
  tmp2 <- tmp[tmp@data[,sname[i]] == rname,]
  ## build a raster for this polygon, and give cell ids 
  rlay <- raster(xmn = (xmin(tmp2))-1/12, xmx = (xmax(tmp2))+1/12, ymn = (ymin(tmp2))-1/12, ymx = (ymax(tmp2))+1/12, res = 1/12)
  rlay <- crop(rwrd,rlay)
  
  # Convert the raster layer to polygons
  fishnet_polygons <- rasterToPolygons(rlay)
  # Assuming 'fishnet' is your polygon layer
  centroid_coords <- coordinates(fishnet_polygons)
  # Add the cell ID information to the polygons
  names(fishnet_polygons)[names(fishnet_polygons) == "layer"] <- "CELLID"
  fishnet_polygons$id <- 0
  
  # Add separate columns for LAT and LON
  fishnet_polygons$LAT <- centroid_coords[, 2]  # Assuming the latitude is in the second column of centroid_coords
  fishnet_polygons$LON <- centroid_coords[, 1]  # Assuming the longitude is in the first column of centroid_coords
  
  # Define the file path where you want to save the shapefile
  shapefile_path <- "C:/CCAFSToolkit/WorldGridData/"
  # Save the polygons as a shapefile
  dir.create(paste0(shapefile_path), recursive = TRUE,showWarnings = FALSE)
  writeOGR(fishnet_polygons, dsn = shapefile_path, layer = "WorldGrid", driver = "ESRI Shapefile",overwrite = TRUE)
  
  # close all files
  closeAllConnections()
  
}

