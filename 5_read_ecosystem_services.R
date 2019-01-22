# read �kosystemleistungen

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/�SL/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

ess <- read.csv(list.files(main, pattern=".csv", full.names=T))
gem_he <- readOGR(paste0(datapath, "Gemeinden_Hessen_clean.shp"))

gem_he$GEN_G <- as.character(gem_he$GEN_G)
gem_he$GEN_G[gem_he$AGS_G=="06440015"] <- "Muenzenberg"
gem_he$GEN_G[gem_he$AGS_G=="06440004"] <- "Buedingen"
gem_he$GEN_G[gem_he$AGS_G=="06440018"] <- "Ober-Moerlen"
gem_he$GEN_G[gem_he$AGS_G=="06440023"] <- "Rosbach_v_d_Hoehe"
gem_he$GEN_G[gem_he$AGS_G=="06440024"] <- "Woelfersheim"
gem_he$GEN_G[gem_he$AGS_G=="06440025"] <- "Woellstadt"
gem_he$GEN_G[gem_he$AGS_G=="06440008"] <- "Friedberg"
gem_he$GEN_G[gem_he$AGS_G=="06535011"] <- "Lauterbach"
gem_he$GEN_G[gem_he$AGS_G=="06440021"] <- "Reichelsheim"

ess$Name <- as.character(ess$Name)
ess$Name[ess$Name=="Gemünden"] <- "Gemuenden"
ess$Name[ess$Name=="Mücke"] <- "Muecke" 
ess$Name[ess$Name=="Münzenberg"] <- "Muenzenberg" 
ess$Name[ess$Name=="Ober-Mörlen"] <- "Ober-Moerlen" 
ess$Name[ess$Name=="Wöllstadt"] <- "Woellstadt" 
ess$Name[ess$Name=="Büdingen"] <- "Buedingen" 
ess$Name[ess$Name=="Wölfersheim"] <- "Woelfersheim" 
ess$Name[ess$Name=="Rosbach"] <- "Rosbach_v_d_Hoehe" 


# which are no match?
nonamemh <- which(is.na(match(ess$Name, gem_he$GEN_G)))
ess$Name[nonamemh]

writeOGR(gem_he, dsn=paste0(datapath, "Gemeinden_Hessen_clean.shp"), driver="ESRI Shapefile",
         layer="Gemeinden_Hessen_clean", overwrite=T)
writeOGR(gem_he, dsn=paste0(datapath, "ecosystem_services_clean.shp"), driver="ESRI Shapefile",
         layer="ecosystem_services_clean", overwrite=T)


# merge when all names are cleared
mess <- merge(gem_he@data, ess, by.x="GEN_G", by.y="Name", all.x=T)
messord <- mess[order(mess$AGS_G),] # bring into correct order for shapefiles
sum(!is.na(match(gem_he$AGS_G, messord$AGS_G))) # works!!
gem_he@data <- messord

writeOGR(gem_he, dsn=paste0(datapath, "ecosystem_services_gemeinden.shp"), driver="ESRI Shapefile",
         layer="ecosystem_services_gemeinden", overwrite=T, layer_options = "RESIZE=YES")



# DISPLAY 
library(sf)
library(tmap)
library(viridis)
library(ggplot2)
library(broom)
library(mapview)
# input  
ee <- st_read(paste0(datapath, "GemMiHe_EEnergieproduktion.shp"))
ee <- gem_he

# with mapview
map <- mapview(ee, zcol="TotalES_index", burst=F, label=ee$GEN_G, na.color="#e5e4e2",
                  legend=T, layer.name="Index Ecosystem Services")

## create standalone .html
mapshot(map, url = paste0(datapath, "/Index_ecosystem_services.html"))

