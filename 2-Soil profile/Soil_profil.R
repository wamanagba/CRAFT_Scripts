

library(geosphere)
library(dplyr)



temps_execution <- system.time({
data = rio::import("G:/BF.txt")


colnames(data)[1]="ID"


data_filtered <- data %>%
  filter(grepl("^\\*|^ @SITE|^-99", ID))


colnames(data_filtered)[2:4]=c("Country","LAT","LONG")
data_filtered$Lat <- c(tail(data_filtered$LAT, -1),NA)
data_filtered$Lon <- c(tail(data_filtered$LONG, -1),NA)

data_filtered <- data_filtered %>%
  filter(grepl("^\\*", ID))
DATA <- data_filtered[, c("ID","Country" ,"Lat", "Lon")]


DD = rio::import( "C:/Users/youedraogo/Desktop/Yacoub/Verification/Burkina Faso/CRAFT_Schema_ByR/Level1/Schema/5m_Burkina Faso.txt")


DD$Lat <- sprintf("%.3f", DD$LAT)
DD$Lon <- sprintf("%.3f", DD$LONG)
merged_data <- merge(DATA, DD, by = c("Lat","Lon"), all = T)


data_A =DD
data_B = DATA

data_A$Lon <- as.numeric(as.character(data_A$Lon))
data_A$Lat <- as.numeric(as.character(data_A$Lat))
data_B$Lon <- as.numeric(as.character(data_B$Lon))
data_B$Lat <- as.numeric(as.character(data_B$Lat))


# Création the matrix distance
dist_matrix <- geosphere::distm(data_A[, c("Lon", "Lat")], data_B[, c("Lon", "Lat")])

# Find the index (index for minimal distances   )
closest_B_indices <- apply(dist_matrix, 01, which.min)

data_A$SoilID <- data_B$ID[closest_B_indices]  
Last = data_A
Last <- Last[, !(names(Last) %in% c("Lat", "Lon"))]


fileout <- paste0("C:/CCAFSToolkit/SoilProfil/5m_soilProfil.txt") 
#dir.create(paste0(getwd(), "/Schema/"), recursive = TRUE,showWarnings = FALSE)
write.table(Last, file = fileout, row.names = FALSE, col.names = TRUE,quote = FALSE,sep = "\t")
})[3]

cat("Time", round(temps_execution, 2), "secondes.\n")

