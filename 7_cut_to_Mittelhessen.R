
# cut all shapes to 6 Kreise

library(rgdal)
library(raster)
library(rgeos)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
opp <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"


# make a template with study area
kreise <- readOGR(paste0(main, "Kreisgrenzen_HE.shp"))
kreise <- spTransform(kreise, crs(newproj))
kreise <- kreise[!is.na(kreise$name),]
writeOGR(kreise, dsn=paste0(opp, "relevante_Kreise.shp"), driver="ESRI Shapefile",
         layer="relevante_Kreise", overwrite=T)

## crop and mask corine
corine <- raster(paste0(main, "corine_hessen_proj.tif"))
r2 <- crop(corine, extent(kreise))
corinem <- mask(r2, kreise)
writeRaster(corinem, paste0(opp, "corine.tif"), format="GTiff")


# ## ATKIS
# atkis <- readOGR(paste0(main, "ATKIS_Polygone.shp"))
# clip <- gIntersection(kreise, atkis, byid = F, drop_lower_td = F)


## NATIS
pfm <- readOGR(paste0(main, "natis_plantfishmolusca.shp"))
pfmclip <- gIntersection(kreise, pfm, byid=T, drop_lower_td=F)




