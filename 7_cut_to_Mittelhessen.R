
# cut all shapes to 6 Kreise

library(rgdal)
library(raster)
library(rgeos)
library(sp)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
opp <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"


# make a template with study area
kreise <- readOGR(paste0(main, "Kreisgrenzen_HE.shp"))
kreise <- spTransform(kreise, crs(newproj))
kreise <- kreise[!is.na(kreise$name),]
kreise_comp <- aggregate(kreise)
df <- data.frame(f=1, name="relevant shapefiles")
kreise_comp <- SpatialPolygonsDataFrame(kreise_comp, df)
writeOGR(kreise, dsn=paste0(opp, "relevante_Kreise.shp"), driver="ESRI Shapefile",
         layer="relevante_Kreise", overwrite=T)
kreise <- kreise_comp
writeOGR(kreise_comp, dsn=paste0(opp, "Kreise_comp.shp"), driver="ESRI Shapefile",
         layer="Kreise_comp", overwrite=T)

## crop and mask corine
corine <- raster(paste0(main, "corine_hessen_proj.tif"))
r2 <- crop(corine, extent(kreise))
corinem <- mask(r2, kreise)
writeRaster(corinem, paste0(opp, "corine.tif"), format="GTiff")


# ## ATKIS
# atkis <- readOGR(paste0(main, "ATKIS_Polygone.shp"))
# atkisclip <- intersect(atkis, kreise)

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
# which are smaller than smallest Gemeinde? 
pos <- which(area(enpclip)<area(enpclip[enpclip$GEN_G=="Heuchelheim",]))
realclip <- enpclip[is.na(match(seq(nrow(enpclip)), pos)),]
writeOGR(realclip, dsn=paste0(opp, "GemMiHe_EEnergieproduktion_mh.shp"), driver="ESRI Shapefile",
         layer="GemMiHe_EEnergieproduktion_mh", overwrite=T)

## tourism
t <- readOGR(paste0(main, "GemHe_Tourismus.shp"))
tclip <- intersect(t, kreise)
# which are smaller than smallest Gemeinde? 
pos <- which(area(tclip)<area(tclip[tclip$GEN_G=="Heuchelheim",]))
realclip <- tclip[is.na(match(seq(nrow(tclip)), pos)),]
writeOGR(realclip, dsn=paste0(opp, "GemHe_Tourismus.shp"), driver="ESRI Shapefile",
         layer="GemHe_Tourismus_mh", overwrite=T)


# BEVÖLKERUNG
path <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/HessischeGemeindestatistik/"
gem_he_path <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/old/Hessen_shapes/"
gem_he <- readOGR(paste0(gem_he_path, "Gemeinden_Hessen_clean.shp"))
bev <- read.csv(list.files(path, pattern="_Bevoelkerung_2.csv", full.names = T),
                sep=";", stringsAsFactors = F)
# replace , with . and save as numeric
for(i in seq(17)){
  bev[,2+i] <- as.numeric(gsub(".", '', bev[,2+i], fixed = T))
  bev[,2+i] <- as.numeric(gsub(",", '.', bev[,2+i], fixed = T))
}
bev$AGS <- as.factor(paste0("06",bev$AGS)) # add 06 for Hessen to code
# which position do codes have in two datasets?
match(gem_he$AGS_G, bev$AGS) # works!!
gem_he@data <- merge(gem_he@data, bev, by.x="AGS_G", by.y="AGS")

#clip to mh
bevclip <- intersect(gem_he, kreise)
# which are smaller than smallest Gemeinde? 
pos <- which(area(bevclip)<area(bevclip[bevclip$GEN_G=="Heuchelheim",]))
realclip <- bevclip[is.na(match(seq(nrow(bevclip)), pos)),]
writeOGR(realclip, dsn=paste0(opp, "GemHe_Bevoelkerung_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Bevoelkerung_mh", overwrite=T)

## BESCHÄFTIGTE
bes <- readOGR(paste0(main, "GemHe_Beschaeftigte.shp"))
besclip <- intersect(bes, kreise)
# replace , with . and save as numeric
for(i in seq(6)){
  besclip@data[,29+i] <- as.numeric(gsub(".", '', besclip@data[,29+i], fixed = T))
  besclip@data[,29+i] <- as.numeric(gsub(",", '.', besclip@data[,29+i], fixed = T))
}
besclip@data[,36:42] <- NULL
# which are smaller than smallest Gemeinde? 
pos <- which(area(besclip)<area(besclip[besclip$GEN_G=="Heuchelheim",]))
realclip <- besclip[is.na(match(seq(nrow(besclip)), pos)),]
writeOGR(realclip, dsn=paste0(opp, "GemHe_Beschaeftigte_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Beschaeftigte_mh", overwrite=T)


## FLÄCHENNUTZUNG
fln <- readOGR(paste0(main, "GemHe_Flaechennutzung.shp"))
flnclip <- intersect(fln, kreise)
# replace , with . and save as numeric
for(i in seq(15)){
  flnclip@data[,29+i] <- as.numeric(gsub(".", '', flnclip@data[,29+i], fixed = T))
  flnclip@data[,29+i] <- as.numeric(gsub(",", '.', flnclip@data[,29+i], fixed = T))
}
# which are smaller than smallest Gemeinde? 
pos <- which(area(flnclip)<area(flnclip[flnclip$GEN_G=="Heuchelheim",]))
realclip <- flnclip[is.na(match(seq(nrow(flnclip)), pos)),]
writeOGR(realclip, dsn=paste0(opp, "GemHe_Flaechennutzung_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Flaechennutzung_mh", overwrite=T)

## LANDWIRTSCHAFT
lws <- readOGR(paste0(main, "GemHe_LWS.shp"))
lwsclip <- intersect(lws, kreise)
# replace , with . and save as numeric
for(i in seq(31)){
  lwsclip@data[,29+i] <- as.numeric(gsub(".", '', lwsclip@data[,29+i], fixed = T))
  lwsclip@data[,29+i] <- as.numeric(gsub(",", '.', lwsclip@data[,29+i], fixed = T))
}
# which are smaller than smallest Gemeinde? 
pos <- which(area(lwsclip)<area(lwsclip[lwsclip$GEN_G=="Heuchelheim",]))
realclip <- lwsclip[is.na(match(seq(nrow(lwsclip)), pos)),]
writeOGR(realclip, dsn=paste0(opp, "GemHe_LWS_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_LWS_mh", overwrite=T)

