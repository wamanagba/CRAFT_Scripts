


library(sp)
library(raster)
library(rgeos)
library(rgdal)
library(sf)


Schema = function(source_folder){
  
  # Record the start time
  start_time <- Sys.time()
  
  ## define the location of the file (absolute　path)
  fileloc <- paste0(source_folder)
  ##make projection of Shape file as defaulted projection in r
  projs <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
  ## define cellid for the whole world in 5 arc-min
  rwrd <- raster(res = 1/12) 
  rwrd[] <- 1:ncell(rwrd)
  

  dt = data.frame()

  ## from now on, do schema generation Level by Level
  for (i in 1:3) { ## note 3 is the Levels of Shape file you have
    ## set working directory here for the Level 'i'
    
    cat("Schema generation in-progress: Attempting to generate schema for Level ", i,"\n")
    #Message_start(i)
    setwd(paste0(fileloc, "/Level", i))
    
    # Check if the folder have a shape file or if the folder shape exist
    #CheckFolder(source_folder,i)
    if(CheckFolder(source_folder,i)==1){
      
      ## read the shp file
      tmp <- shapefile(paste0("Shape/",list.files(path = "Shape/", pattern = "*.shp$")))
      if(i==3){ tmp@data$Level3Name = paste(tmp@data$Level2Name, tmp@data$Level3Name, sep = "_")}
      
      ## spatial projection
      tmp <- spTransform(tmp, CRSobj = projs)
      ## attribute of Level names, here by the define of sname, we can select shp in just one district
      sname <- paste0("Level",1:i,"Name")
      ## make loops for all the polygon in for Level 'i'
      #j=1
      cpt=0
      for (j in 1:nrow(tmp@data)) {
        ## return name of the attribute
        rname <- tmp@data[j,sname[i]]
        ## return of name ahead of the selected Level, this is used to name the result and write it out
        if(i==3){
          tname <- tmp@data[j, sname[1:(i - 2)]]
          tname <- paste(tname,collapse = "_")
        }else{
          tname <- tmp@data[j, sname[1:(i - 1)]]
          tname <- paste(tname,collapse = "_")
        }
        
        
        if (i == 1) { tname <- NULL}
        ## select
        tmp2 <- tmp[tmp@data[,sname[i]] == rname,]
        ## build a raster for this polygon, and give cell ids 
        rlay <- raster(xmn = floor(xmin(tmp2)), xmx = ceiling(xmax(tmp2)), ymn = floor(ymin(tmp2)), ymx = ceiling(ymax(tmp2)), res = 1/12)
        rlay <- crop(rwrd,rlay)
        
        ## build fishnet
        fishnet <- rasterToPolygons(rlay)

        fishnet <- spTransform(fishnet, CRSobj = proj4string(tmp2))
        fish <- intersect(tmp2,fishnet)
        fishfine <- fishnet[fishnet@data$layer %in% fish@data$layer,]
        
        plot(fish)
        ##### New code
        # Order fish according to layer
        order_fish <- order(fish@data$layer)
        fish <- fish[order_fish, ]
        # Order fishfine according to layer
        order_fishfine <- order(fishfine@data$layer)
        fishfine <- fishfine[order_fishfine, ]
        
        
        ## the share percent was calculated by the area of fish/fishfine,
        share <- round(area(fish)/area(fishfine)*100,2)
        schema <- data.frame(CELLID = fishfine@data$layer,SHAREPERCENT = share)
        schema <- schema[order(schema[,1], decreasing = TRUE),]
        ## save schema to a relevant file
        if(is.null(tname)){fileout <- paste0(getwd(), "/Schema/", "5m", tname,"_", rname, ".txt") }else{fileout <- paste0(getwd(), "/Schema/", "5m_", tname,"_", rname, ".txt")}
        dir.create(paste0(getwd(), "/Schema/"), recursive = TRUE,showWarnings = FALSE)
        write.table(schema, file = fileout, row.names = FALSE, col.names = TRUE,quote = FALSE,sep = "\t")
        cpt=cpt+1
      }
      dt = File(dt,i,cpt)
      output_file <- "C:/CCAFSToolkit/Schema_By_R/SchemaGenerationDetails.csv"
      # Write the 'data' dataframe to the CSV file
      write.table(dt, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE)
      
    }else{
      cat("No shape file on the Level",i ,".   Check in the folder Shape \n" )
    }
    cat("Schema generation in-progress: Schema generation Successful for Level ",i, "\n")
    #Message_End(i)
  }
  
  
}

source_folder <- "C:/CCAFSToolkit/CRAFT_Schema/"
Schema(source_folder)