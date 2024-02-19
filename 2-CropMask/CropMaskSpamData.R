

Grid_shape = function(source_folder){
  fileloc <- paste0(source_folder)
  projs <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
  ## define cellid for the whole world in 5 arc-min
  rwrd <- raster(res = 1/12) 
  rwrd[] <- 1:ncell(rwrd)
  
  start_time <- Sys.time()
  dt = data.frame()
  i=1
  j=1
  setwd(paste0(fileloc, "/Level", 1))
  ## read the shp file
  tmp <- shapefile(paste0("Shape/",list.files(path = "Shape/", pattern = "*.shp$")))
  #plot(tmp)
  ## spatial projection
  tmp <- spTransform(tmp, CRSobj = projs)
  ## attribute of Level names, here by the define of sname, we can select shp in just one district
  sname <- paste0("Level",1:i,"Name")
  ## return name of the attribute
  rname <- tmp@data[j,sname[i]]
  ## select
  tmp2 <- tmp[tmp@data[,sname[i]] == rname,]
  ## build a raster for this polygon, and give cell ids 
  rlay <- raster(xmn = floor(xmin(tmp2)), xmx = ceiling(xmax(tmp2)), ymn = floor(ymin(tmp2)), ymx = ceiling(ymax(tmp2)), res = 1/12)
  rlay <- crop(rwrd,rlay)
  ## build fishnet
  fishnet <- rasterToPolygons(rlay)
  #plot(fishnet)
  fishnet <- spTransform(fishnet, CRSobj = proj4string(tmp2))
  fish <- intersect(tmp2,fishnet)
  fishfine <- fishnet[fishnet@data$layer %in% fish@data$layer,]
  #plot(fish)
  order_fish <- order(fish@data$layer)
  fish <- fish[order_fish, ]
  # Order fishfine according to layer
  order_fishfine <- order(fishfine@data$layer)
  fishfine <- fishfine[order_fishfine, ]
  plot(fishfine)
  fish_sf <- st_as_sf(fish, coords = c("lon", "lat"), crs = st_crs(projs))
  columns_to_remove = c("Level1Name", "Id", "ObjectID")
  fish_sf <- fish_sf[, !(names(fish_sf) %in% columns_to_remove)]
  names(fish_sf)[names(fish_sf) == "layer"] <- "CellID"
  # Define the path and file name for your shapefile
  output_shapefile <-paste0("C:/CCAFSToolkit/Grid_Shape/",rname,"/Shape.shp")
  output_shapefil <-paste0("C:/CCAFSToolkit/Grid_Shape/",rname)
  dir.create(output_shapefil, recursive = TRUE,showWarnings = FALSE)
  st_write(fish_sf, output_shapefile,append=FALSE)
  return(rname)
}



Name = function(Crop){
  filename <- basename(Crop)
  matches1 <- regmatches(filename, regexec("(.*)global(.*)\\.tif", filename))
  word_before_extension1 <- matches1[[1]][3]
  
  path_without_filename <- dirname(Crop)
  matches <- regmatches(path_without_filename, regexec(".*[\\/](.*)$", path_without_filename))
  matches <- regmatches(matches[[1]][2], regexec("(.*)global(.*)", matches[[1]][2]))
  last_word_in_path <- matches[[1]][3]
  word = paste0(word_before_extension1,last_word_in_path)
  return(word)
}


SpamData_Data <- function(rname,Crop,source_folder) {
  
  shp_path <- paste0("C:/CCAFSToolkit/Grid_Shape/", rname, "/Shape.shp")
  name =Name(Crop)
  if (file.exists(shp_path)) {
    print("The grid shape fille file already exists. Let's skip the grid shape file generation.")
  } else {
    print(paste0("There is no grid file for the ", rname," generating the grid shape file."))
    print("let's start generating the grid shapefile, It will take about 1 and 6 minutes")
    rname=Grid_shape(source_folder)
  }
  
  # Load the shapefile
  shp <- st_read(dsn = shp_path)
  # Load raster data
  S1 <- stack(paste0(Crop))
  
  # Extract and sum raster values for each polygon in the shapefile
  extracted_values <- raster::extract(S1, shp, fun = sum, na.rm = TRUE)
  
  # Convert the extracted vector into a dataframe, adjusting column names accordingly
  M <- data.frame(CellID = shp$CellID, Crop_Mask = extracted_values)
  
  dir.create(paste0("C:/CCAFSToolkit/CRopMask/",rname,"/"), recursive = TRUE,showWarnings = FALSE)
  
  write.table(M, file = paste0("C:/CCAFSToolkit/CRopMask/",rname,"/crop",name,".txt"), row.names = FALSE, col.names = TRUE,quote = FALSE,sep = "\t")
  
  #return(M)
}




#################################################
Crop = "C:/CCAFSToolkit/GeoTIFFmaps/spam2020V0r1_global_physical_area/spam2020_v0r1_global_A_WHEA_R.tif"
source_folder <- "C:/CCAFSToolkit/CRAFT_Schema/"
rname = "Turkey"

start <- Sys.time()
SpamData_Data(rname,Crop,source_folder)
end <- Sys.time()
print(end-start)
