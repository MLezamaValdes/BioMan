
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


## ATKIS
atkis <- readOGR(paste0(main, "ATKIS_Polygone.shp"))
atkisclip <- intersect(atkis, kreise)

## NATIS
pfm <- readOGR(paste0(main, "natis_plantfishmolusca.shp"))
pfmclip <- intersect(pfm, kreise)
writeOGR(pfmclip, dsn=paste0(opp, "natis_plantfishmolusca_mh.shp"), driver="ESRI Shapefile",
         layer="natis_plantfishmolusca_mh", overwrite=T)

anim <- readOGR(paste0(main, "natisffh_animals.shp"))
animclip <- intersect(anim, kreise)
writeOGR(animclip, dsn=paste0(opp, "natisffh_animals_mh.shp"), driver="ESRI Shapefile",
         layer="natisffh_animals_mh", overwrite=T)

## BREEDING BIRDS
brids <- readOGR(paste0(main, "breeding_birds.shp"))
birdsclip <- intersect(brids, kreise)
writeOGR(birdsclip, dsn=paste0(opp, "breeding_birds_mh.shp"), driver="ESRI Shapefile",
         layer="breeding_birds_mh", overwrite=T)

## energy production
enp <- readOGR(paste0(main, "GemMiHe_EEnergieproduktion.shp"))
enpclip <- intersect(enp, kreise)
writeOGR(enpclip, dsn=paste0(opp, "GemMiHe_EEnergieproduktion_mh.shp"), driver="ESRI Shapefile",
         layer="GemMiHe_EEnergieproduktion_mh", overwrite=T)

## tourism
t <- readOGR(paste0(main, "GemHe_Tourismus.shp"))
tclip <- intersect(t, kreise)
writeOGR(tclip, dsn=paste0(opp, "GemHe_Tourismus.shp"), driver="ESRI Shapefile",
         layer="GemHe_Tourismus_mh", overwrite=T)

## bevölkerung: NO DATA!!! DO AGAIN
bev <- readOGR(paste0(main, "GemHe_Bevölkerung.shp"))
bevclip <- intersect(bev, kreise)
writeOGR(bevclip, dsn=paste0(opp, "GemHe_Beschaeftigte_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Beschaeftigte_mh", overwrite=T)

## BESCHÄFTIGTE
bes <- readOGR(paste0(main, "GemHe_Beschaeftigte.shp"))
besclip <- intersect(bes, kreise)
# replace , with . and save as numeric
for(i in seq(6)){
  besclip@data[,29+i] <- as.numeric(gsub(",", '.', besclip@data[,29+i], fixed = T))
}
besclip@data[,36:42] <- NULL
writeOGR(besclip, dsn=paste0(opp, "GemHe_Beschaeftigte_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Beschaeftigte_mh", overwrite=T)


## FLÄCHENNUTZUNG
fln <- readOGR(paste0(main, "GemHe_Flaechennutzung.shp"))
flnclip <- intersect(fln, kreise)
# replace , with . and save as numeric
for(i in seq(15)){
  flnclip@data[,29+i] <- as.numeric(gsub(",", '.', flnclip@data[,29+i], fixed = T))
}
writeOGR(flnclip, dsn=paste0(opp, "GemHe_Flaechennutzung_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Flaechennutzung_mh", overwrite=T)

## LANDWIRTSCHAFT
lws <- readOGR(paste0(main, "GemHe_LWS.shp"))
lwsclip <- intersect(lws, kreise)
# replace , with . and save as numeric
for(i in seq(31)){
  lwsclip@data[,29+i] <- as.numeric(gsub(",", '.', lwsclip@data[,29+i], fixed = T))
}
writeOGR(lwsclip, dsn=paste0(opp, "GemHe_LWS_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_LWS_mh", overwrite=T)

