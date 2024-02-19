

##################################################################################################

#This script downloads a shapefile from the GADM online site in the form of a ZIP file, 
#extracts its contents into the "CRAFT_Schema" folder, and deletes the downloaded ZIP file upon completion. 
#Users must ensure they have an active internet connection. 
#If the destination folder "C:/CCAFSToolkit/CRAFT_Schema/" does not exist, 
#it will be created automatically before running the script. 
#This script takes the "ISO" as a parameter, which represents the ISO code of 
#the country from which you want to extract the SCHEMA.

rm(list = ls())
#ISO = "BFA"

DownloadShape = function(ISO){
  # Define the URL of the ZIP file you want to download
  url <- paste0("https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_",ISO,"_shp.zip")
  
  # Define the path where you want to save the ZIP file
  destination <- paste0("C:/CCAFSToolkit/CRAFT_Schema/gadm41_",ISO,"_shp.zip")
  
  # Define the destination folder where you want to extract the files
  source_folder <- "C:/CCAFSToolkit/CRAFT_Schema/"
  dir.create(source_folder, recursive = TRUE,showWarnings = FALSE)
  
  # Download the ZIP file
  download.file(url, destination, mode = "wb")
  
  # Unzip the ZIP file into the destination folder
  unzip(destination, exdir = source_folder)
  
  # Remove the downloaded ZIP file to clean up
  file.remove(destination)
  
  # Print a message to indicate that the download and extraction are complete
  cat("Download and extraction completed.\n")
  
}






##########################################################################################
"This script organizes Shapefile files into separate folders based on their 'Level.' 
It scans a source folder containing Shapefiles, and for each Shapefile, 
it determines the 'Level' based on the last character of the filename. 
It then moves each Shapefile to a corresponding folder named 'Level1,' 'Level2,' or 'Level3' 
depending on its 'Level.' The script considers Shapefiles with different extensions
such as '.shp,' '.shx,' and '.dbf' and ensures they are placed in the appropriate folders."

##################################################################################


CreateLevel= function(source_folder){
  # Path to the source folder where your Shapefiles are located
  Country= "Shape"
  
  # Create the three folders Level1, Level2, and Level3
  for (i in 1:6) {
    dir.create(file.path(source_folder, paste0("Level", i)), showWarnings = FALSE)
  }
  
  # List of file extensions to consider (shp, shx, dbf,cpg,prj,)
  extensions <- c("shp", "shx", "dbf","cpg","prj","csv")
  
  # Loop through the extensions
  for (ext in extensions) {
    # List of files with the current extension in the source folder
    files <- list.files(path = source_folder, pattern = paste0("\\.", ext, "$"), full.names = TRUE)
    
    # Loop through the files and move them to the appropriate folders
    for (file in files) {
      # Get the file name without extension
      file_name <- tools::file_path_sans_ext(basename(file))
      
      # Get the last character of the file name (0, 1, or 2)
      last_character <- substr(file_name, nchar(file_name), nchar(file_name))
      
      # Calculate the destination folder based on the last character
      last_character <- as.numeric(last_character) + 1
      destination_folder <- file.path(source_folder, paste0("Level", last_character))
      
      # Move the file to the destination folder with the current extension
      file.rename(file, file.path(destination_folder, paste0(file_name, ".", ext)))
    }
  }
  
  
}





##########################################

ShapeProcessing = function(source_folder){
  library(utils)
  library(sf)
  Country= "Shape"
  setwd(source_folder)
  # Create the three folders Level1, Level2, and Level3
  CRAFT_folder <- paste0(source_folder)
  
  # Check if the CRAFT directory exists, if not, create it
  if (!file.exists(CRAFT_folder)) {
    dir.create(CRAFT_folder, recursive = TRUE)
  }
  
  for (i in 1:3) {
    dir.create(paste0(CRAFT_folder, paste0("Level", i)), showWarnings = FALSE)
  }
  
  # All the variable that we don't need
  columns_to_remove = c("GID_1", "GID_0", "VARNAME_1", "NL_NAME_1", "TYPE_1", "ENGTYPE_1", 
                        "CC_1", "HASC_1", "ISO_1","GID_0","ID_0", "ISO",  "OBJECTID_1", "ISO3",     
                        "NAME_ENGLI", "NAME_ISO",   "NAME_FAO",   "NAME_LOCAL", "NAME_OBSOL",
                        "NAME_VARIA", "NAME_NONLA", "NAME_FRENC", "NAME_SPANI", "NAME_RUSSI",
                        "NAME_ARABI", "NAME_CHINE", "WASPARTOF" , "CONTAINS"   ,"SOVEREIGN" ,
                        "ISO2"       ,"WWW"    ,    "FIPS"   ,    "ISON"    ,   "VALIDFR"   ,
                        "VALIDTO" ,   "POP2000"  ,  "SQKM"  ,     "POPSQKM"  ,  "UNREGION1" ,
                        "UNREGION2" , "DEVELOPING", "CIS"   ,     "Transition", "OECD"      ,
                        "WBREGION",   "WBINCOME" ,  "WBDEBT" ,    "WBOTHER"    ,"CEEAC"     ,
                        "CEMAC" ,     "CEPLG" ,     "COMESA" ,    "EAC"      ,  "ECOWAS"    ,
                        "IGAD"  ,     "IOC"   ,     "MRU"    ,    "SACU"       ,"UEMOA"     ,
                        "UMA"  ,      "PALOP"  ,    "PARTA" ,     "CACM"   ,    "EurAsEC"   ,
                        "Agadir" ,    "SAARC" ,     "ASEAN" ,     "NAFTA"  ,    "GCC"       ,
                        "CSN"  ,      "CARICOM",    "EU"     ,    "CAN"     ,   "ACP"       ,
                        "Landlocked" ,"AOSIS" ,     "SIDS"    ,   "Islands"  ,  "LDC",
                        "GID_2", "GID_0",   "GID_1", "NL_NAME_1","CC_2",   "HASC_2", "VARNAME_2",
                        "NL_NAME_2",   "TYPE_2", "ENGTYPE_2","ID_1","ID_2")
  
  
  # Extract the Level 1
  directory_path=file.path(source_folder, paste0("Level", 1))
  # List all Shapefiles in the directory
  Shapefile_list <- list.files(directory_path, pattern = "\\.shp$", full.names = TRUE)
  
  # Check if any Shapefiles were found
  if (length(Shapefile_list) > 0) {
    # Read the first Shapefile in the list
    Shape <- st_read(Shapefile_list[1])
    Level1 =paste0(Country)
    names(Shape)[names(Shape) == "COUNTRY"] <- "Level1Name"
    names(Shape)[names(Shape) == "NAME_0"] <- "Level1Name"
    
    # delete column
    Shape <- Shape[, !(names(Shape) %in% columns_to_remove)]
    Shape$ObjectID = 1
    
    Shape$Level1Name <- iconv(Shape$Level1Name, to = "ASCII//TRANSLIT")
    
    dir.create(paste0(CRAFT_folder, paste0("Level", 1),"/Shape"), showWarnings = FALSE)
    st_write(Shape,paste0(CRAFT_folder,"Level1/Shape/",Level1,"_01.shp"), delete_layer = T)
    
  } else {cat("No Shapefiles found in the Level 1 folder \n")}
  
  
  
  
  # Extract the Level 2
  directory_path=file.path(source_folder, paste0("Level", 2))
  # List all Shapefiles in the directory
  Shapefile_list <- list.files(directory_path, pattern = "\\.shp$", full.names = TRUE)
  # Check if any Shapefiles were found
  if (length(Shapefile_list) > 0) {
    # Read the first Shapefile in the list
    Shape <- st_read(Shapefile_list[1])
    # delete some column
    Shape <- Shape[, !(names(Shape) %in% columns_to_remove)]
    # Renommer la colonne 'Level3Name' en 'Level2Name'
    names(Shape)[names(Shape) == "NAME_1"] <- "Level2Name"
    names(Shape)[names(Shape) == "COUNTRY"] <- "Level1Name"
    names(Shape)[names(Shape) == "NAME_0"] <- "Level1Name"
    
    Shape$ObjectID = 0
    
    Shape$Level1Name <- iconv(Shape$Level1Name, to = "ASCII//TRANSLIT")
    Shape$Level2Name <- iconv(Shape$Level2Name, to = "ASCII//TRANSLIT")
    
    dir.create(paste0(CRAFT_folder, paste0("Level", 2),"/Shape"), showWarnings = FALSE)
    st_write(Shape,paste0(CRAFT_folder,"Level2/Shape/",Level1,"_02.shp"), delete_layer = T)
    
  } else {cat("No Shapefiles found in the Level 2 folder.\n")}
  
  
  
  
  # Extract the Level 3
  directory_path=file.path(source_folder, paste0("Level", 3))
  # List all Shapefiles in the directory
  Shapefile_list <- list.files(directory_path, pattern = "\\.shp$", full.names = TRUE)
  
  # Check if any Shapefiles were found
  if (length(Shapefile_list) > 0) {
    # Read the first Shapefile in the list
    Shape <- st_read(Shapefile_list[1])
    # delete some column
    Shape <- Shape[, !(names(Shape) %in% columns_to_remove)]
    # Rename the columns
    names(Shape)[names(Shape) == "NAME_2"] <- "Level3Name"
    names(Shape)[names(Shape) == "NAME_1"] <- "Level2Name"
    names(Shape)[names(Shape) == "COUNTRY"] <- "Level1Name"
    names(Shape)[names(Shape) == "NAME_0"] <- "Level1Name"
    Shape$ObjectID = 0
    
    Shape$Level1Name <- iconv(Shape$Level1Name, to = "ASCII//TRANSLIT")
    Shape$Level2Name <- iconv(Shape$Level2Name, to = "ASCII//TRANSLIT")
    Shape$Level3Name <- iconv(Shape$Level3Name, to = "ASCII//TRANSLIT")
    
    dir.create(paste0(CRAFT_folder, paste0("Level", 3),"/Shape"), showWarnings = FALSE)
    st_write(Shape,paste0(CRAFT_folder,"Level3/Shape/",Level1,"_03.shp"), delete_layer = T)
    
  } else {cat("No Shapefiles found in the Level 3 folder. \n")}
  
}



####################################  Delete the firts Shape file in the folder
DeleteOldFolder = function(source_folder){
  # List of directory names to delete
  directories_to_delete <- c("Level4","Level5","Level6")
  
  # Loop through the directories and delete them
  for (dir_name in directories_to_delete) {
    directory_path <- file.path(source_folder, dir_name)
    
    if (file.exists(directory_path)) {
      # Delete the directory and its contents recursively
      unlink(directory_path, recursive = TRUE)
      cat("Deleted directory:", directory_path, "\n")
    } else {
      cat("Directory does not exist:", directory_path, "\n")
    }
  }
}









DeleteOldFiles <- function(){
  
  
  # Specify the folders Level1, Level2, and Level3
  folders <- c("Level1", "Level2", "Level3")
  
  # File extensions to delete
  extensions <- c("shp", "shx", "dbf", "cpg", "prj", "csv")
  
  # Loop through the folders
  for (folder in folders) {
    # Create the full path of the folder
    folder_path <- file.path(source_folder, folder)
    
    # List all files in the folder
    files <- list.files(path = folder_path, full.names = TRUE)
    
    # Filter files with the specified extensions
    files_to_delete <- files[grep(paste(extensions, collapse = "|"), files, ignore.case = TRUE)]
    
    # Delete the files
    if (length(files_to_delete) > 0) {
      file.remove(files_to_delete)
      cat("Files deleted in folder", folder, ":", length(files_to_delete), "file(s)\n")
    } else {
      cat("No files to delete in folder", folder, "\n")
    }
  }
}
