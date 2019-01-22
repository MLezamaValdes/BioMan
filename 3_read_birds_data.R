# read energy data

library(raster)
library(rgeos)
library(rgdal)
library(maptools)
library(sp)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
gem_he <- readOGR(paste0(datapath, "GemMiHe_EEnergieproduktion.shp"))


bbdat <- read.csv(paste0(main, "Survey_CommonBreedingBirds_Hessen.csv"), sep=";", dec=",")
testproj <- crs(newproj)
#utm <- "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
gausskr <- "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
bbsh <- SpatialPointsDataFrame(bbdat[,15:16],
                               bbdat,    #the R object to convert
                               proj4string = crs(gausskr))   # assign a CRS 
mapview::mapview(bbsh)
# Shapefile reprojection
bbshutm <- spTransform(bbsh, crs(newproj))
writeOGR(bbshutm, paste0(datapath, "breeding_birds.shp"), driver="ESRI Shapefile", 
         layer="breeding_birds")
